# Project Summary: Cloudflare WAF Validation with OPA

## 📋 Overview

This project demonstrates an automated pipeline for managing Cloudflare Web Application Firewall (WAF) rules using:
- **Terraform** for infrastructure as code
- **Open Policy Agent (OPA)** for policy enforcement
- **GitHub Actions** for CI/CD automation
- **Terraform Cloud** for state management and execution

## 🎯 Key Features

### 1. Infrastructure as Code
- Cloudflare WAF rules defined in Terraform
- Version controlled configuration
- Reproducible deployments
- Declarative infrastructure management

### 2. Policy as Code
- OPA policies enforce security requirements
- Automated validation on every change
- Prevents deployment of non-compliant configurations
- Ensures WAF protection is always active

### 3. Automated Pipeline
- All changes via Git pull requests
- Automated testing and validation
- Peer review before deployment
- Complete audit trail

### 4. Automated Deployment
- GitHub Actions CI/CD pipeline
- Automatic plan on pull request
- Automatic apply on merge to main
- Results posted to pull requests

## 📁 Project Structure

```
cloudflare-waf-validation/
├── .github/
│   └── workflows/
│       ├── terraform.yml          # CI/CD pipeline
│       └── README.md              # Workflow documentation
├── policies/
│   ├── waf_required.rego          # OPA policy rules
│   └── waf_required_test.rego     # OPA policy tests
├── main.tf                        # Cloudflare WAF resources
├── variables.tf                   # Input variables
├── outputs.tf                     # Output values
├── terraform.tf                   # Terraform & provider config
├── terraform.tfvars.example       # Example variables file
├── .gitignore                     # Git ignore rules
├── Makefile                       # Convenience commands
├── README.md                      # Main documentation
├── QUICKSTART.md                  # 5-minute setup guide
├── SETUP.md                       # Detailed setup instructions
├── CONTRIBUTING.md                # Contribution guidelines
└── PROJECT_SUMMARY.md             # This file
```

## 🔒 Security Policies Enforced

The OPA policies ensure:

1. **WAF Protection Required**
   - At least one WAF rule protecting against attack scores must exist
   - Rule must filter on `cf.threat_score`

2. **Rules Must Be Enabled**
   - All WAF rules must have `enabled = true`
   - Disabled rules trigger policy violations

3. **Blocking Actions Required**
   - WAF rules must use `block`, `challenge`, or `managed_challenge`
   - Passive actions like `log` are not allowed

4. **Threshold Warnings**
   - Warns if attack score threshold is too high (> 50)
   - Encourages best practices

## 🚀 How It Works

### Development Flow

```
1. Developer creates feature branch
2. Developer modifies Terraform configuration
3. Developer pushes branch and creates PR
4. GitHub Actions runs automatically:
   ├── Validates Terraform syntax
   ├── Runs OPA policy tests
   ├── Generates Terraform plan
   ├── Validates plan against OPA policies
   └── Posts results as PR comment
5. Team reviews PR and plan
6. PR is merged to main
7. GitHub Actions applies changes to Cloudflare
8. WAF rules are live!
```

### Policy Enforcement Flow

```
Terraform Plan → OPA Evaluation → Pass/Fail
                       ↓
                  Deny Rules
                       ↓
              Policy Violations?
                    ↙    ↘
                 Yes      No
                  ↓        ↓
              Fail CI   Pass CI
                         ↓
                    Deploy to
                   Cloudflare
```

## 🛡️ WAF Rules Deployed

### 1. Attack Score Protection
- **Resource**: `cloudflare_ruleset.waf_attack_score_protection`
- **Purpose**: Block high-risk requests based on threat intelligence
- **Expression**: `(cf.threat_score ge 50)`
- **Action**: Block (configurable)
- **Phase**: Custom firewall rules

### 2. Managed WAF Rules
- **Resource**: `cloudflare_ruleset.waf_managed_rules`
- **Purpose**: Apply Cloudflare's curated security ruleset
- **Ruleset ID**: `efb7b8c949ac4650a09736fc376e9aee`
- **Phase**: Managed firewall rules

## 🔧 Configuration

### Required Secrets

**GitHub Secrets:**
- `TF_API_TOKEN` - Terraform Cloud API token
- `CLOUDFLARE_API_TOKEN` - Cloudflare API token
- `CLOUDFLARE_ZONE_ID` - Cloudflare Zone ID

**Terraform Cloud Variables:**
- `CLOUDFLARE_API_TOKEN` (environment, sensitive)
- `CLOUDFLARE_ZONE_ID` (environment)
- `waf_attack_score_threshold` (terraform, optional)
- `waf_action` (terraform, optional)

### Customizable Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `waf_attack_score_threshold` | `50` | Minimum threat score to trigger action |
| `waf_action` | `block` | Action to take (block/challenge/managed_challenge) |

## 📊 Testing

### OPA Policy Tests

Run locally:
```bash
opa test policies/ -v
```

Tests verify:
- ✅ Valid configurations pass
- ❌ Missing WAF rules fail
- ❌ Disabled rules fail
- ❌ Wrong actions fail
- ⚠️ High thresholds warn

### Terraform Validation

Run locally:
```bash
make check
```

Validates:
- Terraform syntax
- Provider configuration
- Resource definitions
- Variable types

## 🎓 Learning Outcomes

This project demonstrates:

1. **Pipeline Principles**
   - Git as single source of truth
   - Declarative infrastructure
   - Automated reconciliation

2. **Policy as Code**
   - Codified compliance requirements
   - Automated policy enforcement
   - Shift-left security

3. **CI/CD Best Practices**
   - Automated testing
   - Pull request workflows
   - Deployment automation

4. **Terraform Patterns**
   - Cloud backend usage
   - Module organization
   - Variable management

5. **Security Automation**
   - WAF management
   - Threat protection
   - Compliance enforcement

## 🔄 Typical Workflows

### Adding a New WAF Rule

1. Edit `main.tf` to add new rule
2. Update OPA policies if needed
3. Run `make test` locally
4. Create PR and review plan
5. Merge to deploy

### Adjusting Threat Threshold

1. Edit `variables.tf` default value
2. Run `make plan` to preview
3. Create PR
4. Review impact in plan
5. Merge to apply

### Updating OPA Policies

1. Edit `policies/waf_required.rego`
2. Add tests in `policies/waf_required_test.rego`
3. Run `opa test policies/ -v`
4. Create PR
5. Merge to enforce new policies

## 📈 Monitoring & Observability

### Cloudflare Dashboard
- View blocked requests in Analytics
- Monitor WAF rule effectiveness
- Review security events

### Terraform Cloud
- Track all infrastructure changes
- View apply history
- Monitor state changes

### GitHub
- Review all code changes
- Track policy violations
- Audit deployment history

## 🎯 Next Steps

### Enhancements
- Add rate limiting rules
- Implement IP reputation filtering
- Add custom rule exceptions
- Create environment-specific configs

### Advanced Features
- Multi-zone deployment
- Terraform modules
- Custom OPA policy library
- Slack notifications

### Production Readiness
- Add staging environment
- Implement blue/green deployments
- Add rollback procedures
- Set up monitoring alerts

## 📚 Documentation

- **[README.md](README.md)** - Project overview and architecture
- **[QUICKSTART.md](QUICKSTART.md)** - 5-minute setup guide
- **[SETUP.md](SETUP.md)** - Detailed setup instructions
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - How to contribute
- **[.github/workflows/README.md](.github/workflows/README.md)** - CI/CD details

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on:
- Making changes
- Writing policies
- Testing
- Code review process

## 📝 License

MIT License - Feel free to use this project as a template for your own WAF validation pipelines!

---

**Built with:** Terraform 1.6+ | OPA | GitHub Actions | Cloudflare | Terraform Cloud
