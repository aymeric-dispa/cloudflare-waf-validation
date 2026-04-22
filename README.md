# Cloudflare WAF Validation with OPA

A demonstration of policy-as-code for Cloudflare WAF management using Terraform, GitHub Actions, and Open Policy Agent (OPA).

## Overview

Cloudflare WAF rules are managed as code via Terraform. An OPA policy automatically detects sensitive changes (managed ruleset overrides, exceptions, or custom skip rules) and gates them behind a mandatory security review before the PR can be merged.

## How It Works

1. **Pull Request** — GitHub Actions runs `terraform plan` and evaluates the plan JSON with OPA
2. **OPA check** — if the plan contains a managed ruleset override, exception, or custom skip rule, an approval is required
3. **Push to main** — GitHub Actions runs `terraform apply` via Terraform Cloud, which re-plans and applies the changes to Cloudflare

## Approval Gates

| Change type | Gate |
|---|---|
| New block/log/challenge rule | None — merges normally |
| Managed ruleset override or exception | `waf-security-review` environment approval required on PR |
| Custom skip rule | `waf-security-review` environment approval required on PR |

## Project Structure

```
.
├── main.tf                    # Cloudflare WAF ruleset configuration
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── terraform.tf               # Terraform and provider config
├── .github/
│   └── workflows/
│       └── terraform.yml      # CI/CD pipeline
└── policies/
    ├── waf_required.rego      # OPA policy (requires_approval)
    └── waf_required_test.rego # OPA policy unit tests
```

## Setup

### Terraform Cloud

- Create a workspace and set `TF_VAR_cloudflare_api_token` and `TF_VAR_cloudflare_zone_id` as workspace variables (sensitive)

### GitHub

- Add `TF_API_TOKEN` (Terraform Cloud token) as a repository secret
- Create two environments: `waf-security-review` and `production`, each with required reviewers configured

### Local testing

```bash
# Run OPA unit tests
opa test policies/ -v

# Evaluate policy against a plan
terraform plan -out=tfplan.binary
terraform show -json tfplan.binary > tfplan.json
opa eval -i tfplan.json -d policies/waf_required.rego "data.terraform.requires_approval"
```

---


```
THIS REPOSITORY IS PROVIDED BY CLOUDFLARE "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL CLOUDFLARE BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES  (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```
