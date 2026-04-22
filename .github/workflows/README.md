# GitHub Actions Workflows

## terraform.yml

This workflow implements the automated pipeline for Cloudflare WAF management.

### Triggers

- **Pull Request** to `main` branch: Validates and plans changes
- **Push** to `main` branch: Applies changes to Cloudflare

### Jobs

#### 1. Validate Job (runs on all PRs and pushes)

**Steps:**
1. **Checkout**: Get the code
2. **Setup Terraform**: Install Terraform CLI with Cloud credentials
3. **Setup OPA**: Install Open Policy Agent
4. **Format Check**: Verify code formatting (`terraform fmt`)
5. **Init**: Initialize Terraform with Cloud backend
6. **Validate**: Validate Terraform syntax
7. **OPA Tests**: Run policy unit tests
8. **Plan**: Generate execution plan
9. **OPA Evaluation**: Validate plan against policies
10. **Post to PR**: Comment with results (PRs only)

**Policy Enforcement:**
- If OPA finds violations (`deny` rules), the workflow fails
- Warnings are displayed but don't block
- Plan must pass all security policies to proceed

#### 2. Apply Job (runs only on main branch pushes)

**Steps:**
1. **Checkout**: Get the code
2. **Setup Terraform**: Install Terraform CLI
3. **Init**: Initialize Terraform
4. **Apply**: Deploy changes to Cloudflare
5. **Output**: Display deployment results

**Safety:**
- Only runs after validation passes
- Only runs on main branch
- Requires all checks to pass first

### Environment Variables

Set these in GitHub Secrets:

| Secret | Description | Required |
|--------|-------------|----------|
| `TF_API_TOKEN` | Terraform Cloud API token | ✅ Yes |
| `CLOUDFLARE_API_TOKEN` | Cloudflare API token | ✅ Yes |
| `CLOUDFLARE_ZONE_ID` | Cloudflare Zone ID | ✅ Yes |

### Workflow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     Pull Request Created                     │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                      Validate Job Runs                       │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐            │
│  │ Terraform  │→ │    OPA     │→ │  Terraform │            │
│  │  Validate  │  │   Tests    │  │    Plan    │            │
│  └────────────┘  └────────────┘  └────────────┘            │
│                            ↓                                 │
│                   ┌────────────────┐                        │
│                   │  OPA Evaluate  │                        │
│                   │  Plan vs       │                        │
│                   │  Policies      │                        │
│                   └────────────────┘                        │
└─────────────────────────────────────────────────────────────┘
                            ↓
                    ┌───────────────┐
                    │  Pass or Fail │
                    └───────────────┘
                            ↓
                    ┌───────────────┐
                    │ Post Results  │
                    │   to PR       │
                    └───────────────┘
                            ↓
                    ┌───────────────┐
                    │ Developer     │
                    │ Reviews &     │
                    │ Merges        │
                    └───────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                    Push to Main Branch                       │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                  Validate Job Runs Again                     │
└─────────────────────────────────────────────────────────────┘
                            ↓
                    ┌───────────────┐
                    │   All Pass?   │
                    └───────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                       Apply Job Runs                         │
│                                                              │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐           │
│  │ Terraform  │→ │ Terraform  │→ │ Cloudflare │           │
│  │    Init    │  │   Apply    │  │    WAF     │           │
│  └────────────┘  └────────────┘  └────────────┘           │
└─────────────────────────────────────────────────────────────┘
                            ↓
                    ┌───────────────┐
                    │  WAF Rules    │
                    │   Deployed!   │
                    └───────────────┘
```

### Example PR Comment

When a PR is created, the workflow posts a comment like:

```
#### Terraform Format and Style 🖌 success
#### Terraform Initialization ⚙️ success
#### Terraform Validation 🤖 success
#### OPA Policy Tests 📋 success
#### OPA Policy Validation 🔒 success
#### Terraform Plan 📖 success

<details><summary>Show Plan</summary>

terraform
Terraform will perform the following actions:

  # cloudflare_ruleset.waf_attack_score_protection will be created
  + resource "cloudflare_ruleset" "waf_attack_score_protection" {
      + id          = (known after apply)
      + name        = "WAF Attack Score Protection"
      ...
    }

Plan: 1 to add, 0 to change, 0 to destroy.

</details>

**Pusher:** @username
**Action:** pull_request
**Workflow:** Cloudflare WAF Validation with OPA
```

### Customization

To modify the workflow:

1. **Change Terraform version**: Edit `terraform_version` in setup step
2. **Add more checks**: Add steps before the apply job
3. **Change OPA strictness**: Modify the evaluation logic
4. **Add notifications**: Add Slack/email notification steps

### Troubleshooting

**Workflow fails at OPA evaluation:**
- Check policy violations in the workflow logs
- Ensure WAF rules meet policy requirements
- Review `policies/waf_required.rego`

**Apply job doesn't run:**
- Verify you're pushing to `main` branch
- Check that validate job passed
- Ensure GitHub Actions has permissions

**Terraform Cloud connection fails:**
- Verify `TF_API_TOKEN` is set correctly
- Check organization and workspace names match
- Ensure token has correct permissions
