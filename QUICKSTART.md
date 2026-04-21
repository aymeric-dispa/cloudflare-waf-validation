# Quick Start Guide

Get up and running in 5 minutes!

## Prerequisites Checklist

- [ ] Cloudflare account with a zone
- [ ] Terraform Cloud account (free tier works)
- [ ] GitHub account
- [ ] Git installed locally

## 5-Minute Setup

### 1. Get Cloudflare Credentials (2 min)

```bash
# Visit: https://dash.cloudflare.com
# 1. Copy your Zone ID from the Overview page
# 2. Create API Token: My Profile → API Tokens → Create Token
#    - Use "Edit zone DNS" template
#    - Add "Firewall Services: Edit" permission
```

### 2. Setup Terraform Cloud (1 min)

```bash
# Visit: https://app.terraform.io
# 1. Create organization
# 2. Create workspace: "cloudflare-waf-validation" (API-driven)
# 3. Add environment variables:
#    - CLOUDFLARE_API_TOKEN (sensitive)
#    - CLOUDFLARE_ZONE_ID
# 4. Get API token: Click profile picture → Account Settings → Tokens → Create
```

### 3. Configure This Project (1 min)

```bash
# Edit terraform.tf - update line 6:
organization = "your-actual-org-name"

# Commit changes
git add terraform.tf
git commit -m "chore: configure terraform cloud org"
```

### 4. Setup GitHub (1 min)

```bash
# Create repo and push code
git remote add origin https://github.com/YOUR-USERNAME/YOUR-REPO.git
git push -u origin main

# Add GitHub Secrets (Settings → Secrets → Actions):
# - TF_API_TOKEN
# - CLOUDFLARE_API_TOKEN  
# - CLOUDFLARE_ZONE_ID
```

### 5. Test It! (30 sec)

```bash
# Create test branch
git checkout -b test-deployment

# Make a small change
echo "# Test" >> README.md

# Push and create PR
git add README.md
git commit -m "test: verify pipeline"
git push origin test-deployment

# Go to GitHub and create PR
# Watch the automated checks run!
```

## What Happens Next?

1. **On Pull Request:**
   - ✅ Terraform validates your code
   - ✅ OPA checks WAF policies are enforced
   - ✅ Plan is generated and posted to PR
   - 👀 You review the changes

2. **On Merge to Main:**
   - 🚀 Terraform automatically applies to Cloudflare
   - 🛡️ WAF rules are deployed
   - ✅ Your site is protected!

## Verify It Worked

### Check Cloudflare Dashboard

```
1. Login to Cloudflare
2. Select your domain
3. Go to Security → WAF → Custom rules
4. You should see: "WAF Attack Score Protection"
```

### Check Terraform Cloud

```
1. Login to Terraform Cloud
2. Open your workspace
3. View the latest run
4. Confirm "Applied" status
```

## Common Issues

**Issue:** GitHub Actions fails with "No valid credential sources"
**Fix:** Add `TF_API_TOKEN` to GitHub Secrets

**Issue:** Terraform apply fails with "unauthorized"
**Fix:** Verify Cloudflare API token has "Firewall Services: Edit" permission

**Issue:** OPA policy fails
**Fix:** Ensure `main.tf` has a rule with `cf.threat_score` expression

## What's Protected?

Your Cloudflare zone now has:

- ✅ **Attack Score Protection**: Blocks requests with threat score ≥ 50
- ✅ **Managed WAF Rules**: Cloudflare's curated ruleset active
- ✅ **Policy Enforcement**: OPA ensures protection can't be removed
- ✅ **Audit Trail**: All changes tracked in Git

## Next Steps

- 📖 Read [SETUP.md](SETUP.md) for detailed configuration
- 🔧 Read [CONTRIBUTING.md](CONTRIBUTING.md) to make changes
- 📊 Monitor blocked requests in Cloudflare Analytics
- 🎯 Tune `waf_attack_score_threshold` based on your traffic

## Architecture at a Glance

```
Developer → Git Push → GitHub Actions → OPA Validation → Terraform Cloud → Cloudflare WAF
                              ↓
                         ✅ or ❌
                    (Policy enforced!)
```

**Key Point:** You cannot deploy WAF configuration that doesn't meet OPA policies. This ensures your site is always protected! 🛡️
