# Cloudflare WAF Validation with OPA

A simple demonstration using Terraform, GitHub Actions, and Open Policy Agent (OPA) to ensure Cloudflare WAF rules are always protecting against attack scores.

## Overview

This project demonstrates:
- **Infrastructure as Code**: Cloudflare WAF configuration managed via Terraform
- **Policy as Code**: OPA policies to enforce WAF rule requirements
- **Automated Pipeline**: Validation and deployment via GitHub Actions
- **State Management**: Terraform Cloud for remote state and execution

## Architecture

```
┌─────────────┐      ┌──────────────┐      ┌─────────────────┐
│   GitHub    │─────▶│ GitHub       │─────▶│ Terraform Cloud │
│   Commit    │      │ Actions      │      │                 │
└─────────────┘      └──────────────┘      └─────────────────┘
                            │                        │
                            ▼                        ▼
                     ┌──────────────┐      ┌─────────────────┐
                     │ OPA Policy   │      │   Cloudflare    │
                     │ Validation   │      │   WAF Rules     │
                     └──────────────┘      └─────────────────┘
```

## Prerequisites

- Cloudflare account with a zone
- Terraform Cloud account
- GitHub repository
- Cloudflare API Token with WAF permissions
- OPA CLI (for local testing)

## Setup

### 1. Terraform Cloud Configuration

1. Create a workspace in Terraform Cloud
2. Set workspace to "VCS-driven workflow" or "API-driven workflow"
3. Add environment variables:
   - `CLOUDFLARE_API_TOKEN` (sensitive)
   - `CLOUDFLARE_ZONE_ID`

### 2. GitHub Secrets

Add the following secrets to your GitHub repository:
- `TF_API_TOKEN`: Terraform Cloud API token
- `CLOUDFLARE_API_TOKEN`: Cloudflare API token
- `CLOUDFLARE_ZONE_ID`: Your Cloudflare zone ID

### 3. Local Development

```bash
# Install OPA
brew install opa

# Initialize Terraform
terraform init

# Test OPA policies locally
opa test policies/ -v

# Plan changes
terraform plan
```

## How It Works

### WAF Protection

The Terraform configuration creates a Cloudflare WAF rule that:
- Blocks requests with an attack score ≥ 50
- Applies to all incoming traffic
- Uses Cloudflare's managed threat intelligence

### OPA Policy Enforcement

The OPA policy (`policies/waf_required.rego`) ensures:
- At least one WAF rule exists protecting against attack scores
- The rule is enabled
- The action is set to "block" or "challenge"
- The rule applies to the correct zone

### Pipeline Workflow

1. **Developer** commits Terraform changes to a branch
2. **GitHub Actions** triggers on pull request:
   - Validates Terraform syntax
   - Runs OPA policy tests
   - Validates plan against OPA policies
   - Posts results as PR comment
3. **Merge** to main branch triggers:
   - Re-validation
   - Automatic apply via Terraform Cloud
4. **Terraform Cloud** applies changes to Cloudflare

## Project Structure

```
.
├── README.md
├── main.tf                    # Cloudflare WAF configuration
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── terraform.tf               # Terraform and provider config
├── .github/
│   └── workflows/
│       └── terraform.yml      # CI/CD pipeline
├── policies/
│   ├── waf_required.rego      # OPA policy
│   └── waf_required_test.rego # OPA policy tests
└── .gitignore
```

## Testing Changes

### Local Policy Testing

```bash
# Run OPA tests
opa test policies/ -v

# Evaluate policy against Terraform plan
terraform plan -out=tfplan.binary
terraform show -json tfplan.binary > tfplan.json
opa eval -i tfplan.json -d policies/waf_required.rego "data.terraform.deny"
```

### Pull Request Workflow

1. Create a feature branch
2. Modify Terraform configuration
3. Push and create a pull request
4. Review automated checks
5. Merge when all checks pass

## Example: Adding a New WAF Rule

```hcl
resource "cloudflare_ruleset" "waf_custom_rules" {
  zone_id     = var.cloudflare_zone_id
  name        = "Custom WAF Rules"
  description = "Custom WAF rules for enhanced protection"
  kind        = "zone"
  phase       = "http_request_firewall_custom"

  rules {
    action = "block"
    expression = "(cf.threat_score gt 50)"
    description = "Block high threat score requests"
    enabled = true
  }
}
```

## Security Considerations

- Never commit secrets to the repository
- Use Terraform Cloud for secure state storage
- Rotate API tokens regularly
- Review all changes via pull requests
- Monitor Cloudflare analytics for blocked requests

## Troubleshooting

### OPA Policy Fails

Check that your Terraform configuration includes:
- A WAF rule with attack score filtering
- The rule is enabled
- The action is "block" or "challenge"

### Terraform Apply Fails

Verify:
- Cloudflare API token has correct permissions
- Zone ID is correct
- No conflicting rules exist

## License

MIT
