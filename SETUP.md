# Setup Guide

This guide walks you through setting up the GitOps pipeline for Cloudflare WAF management.

## Step 1: Cloudflare Configuration

### Get Your Zone ID

1. Log in to [Cloudflare Dashboard](https://dash.cloudflare.com)
2. Select your domain
3. Scroll down on the Overview page to find your **Zone ID**
4. Copy the Zone ID for later use

### Create API Token

1. Go to **My Profile** → **API Tokens**
2. Click **Create Token**
3. Use the **Edit zone DNS** template or create a custom token with:
   - Permissions:
     - Zone → Firewall Services → Edit
     - Zone → Zone Settings → Read
   - Zone Resources:
     - Include → Specific zone → [Your Zone]
4. Copy the API token (you won't see it again!)

## Step 2: Terraform Cloud Setup

### Create Organization and Workspace

1. Sign up at [Terraform Cloud](https://app.terraform.io)
2. Create a new organization (or use existing)
3. Create a new workspace:
   - Choose **API-driven workflow**
   - Name it: `cloudflare-waf-gitops`

### Configure Workspace Variables

In your workspace settings, add these **Environment Variables**:

| Variable Name | Value | Sensitive |
|--------------|-------|-----------|
| `CLOUDFLARE_API_TOKEN` | Your Cloudflare API token | ✅ Yes |
| `CLOUDFLARE_ZONE_ID` | Your Cloudflare Zone ID | ❌ No |

Also add these **Terraform Variables** (optional, uses defaults if not set):

| Variable Name | Value | Type |
|--------------|-------|------|
| `waf_attack_score_threshold` | `50` | number |
| `waf_action` | `block` | string |

### Get Terraform Cloud API Token

1. Go to **User Settings** → **Tokens**
2. Click **Create an API token**
3. Name it: `GitHub Actions`
4. Copy the token

## Step 3: Update Terraform Configuration

Edit `terraform.tf` and update the cloud block:

```hcl
cloud {
  organization = "your-actual-org-name"  # Replace with your org name

  workspaces {
    name = "cloudflare-waf-gitops"
  }
}
```

## Step 4: GitHub Repository Setup

### Create Repository

1. Create a new GitHub repository
2. Push this code to the repository:

```bash
git init
git add .
git commit -m "Initial commit: GitOps WAF setup"
git branch -M main
git remote add origin https://github.com/your-username/your-repo.git
git push -u origin main
```

### Configure GitHub Secrets

Go to **Settings** → **Secrets and variables** → **Actions** and add:

| Secret Name | Value |
|-------------|-------|
| `TF_API_TOKEN` | Your Terraform Cloud API token |
| `CLOUDFLARE_API_TOKEN` | Your Cloudflare API token |
| `CLOUDFLARE_ZONE_ID` | Your Cloudflare Zone ID |

## Step 5: Test the Pipeline

### Local Testing (Optional)

```bash
# Install OPA
brew install opa

# Test OPA policies
opa test policies/ -v

# Initialize Terraform (requires TF Cloud token)
terraform login
terraform init

# Create a plan
export TF_VAR_cloudflare_api_token="your-token"
export TF_VAR_cloudflare_zone_id="your-zone-id"
terraform plan
```

### Test via Pull Request

1. Create a new branch:
   ```bash
   git checkout -b test-waf-rule
   ```

2. Make a small change (e.g., update description in `main.tf`)

3. Commit and push:
   ```bash
   git add .
   git commit -m "Test: Update WAF rule description"
   git push origin test-waf-rule
   ```

4. Create a Pull Request on GitHub

5. Watch the GitHub Actions workflow run:
   - ✅ Terraform format check
   - ✅ Terraform validation
   - ✅ OPA policy tests
   - ✅ Terraform plan
   - ✅ OPA policy validation
   - 📝 Plan posted as PR comment

6. If all checks pass, merge the PR

7. Watch the automatic apply to Cloudflare

## Step 6: Verify Deployment

### Check Terraform Cloud

1. Go to your workspace in Terraform Cloud
2. View the latest run
3. Confirm the apply completed successfully

### Check Cloudflare

1. Log in to Cloudflare Dashboard
2. Go to **Security** → **WAF**
3. Navigate to **Custom rules**
4. Verify you see:
   - "WAF Attack Score Protection" ruleset
   - Rule blocking traffic with threat score ≥ 50

## Troubleshooting

### OPA Policy Fails

**Error:** "No WAF rule found protecting against attack scores"

**Solution:** Ensure `main.tf` includes a `cloudflare_ruleset` with `cf.threat_score` in the expression.

### Terraform Apply Fails

**Error:** "Error creating ruleset"

**Solutions:**
- Verify API token has correct permissions
- Check Zone ID is correct
- Ensure no conflicting rules exist in Cloudflare

### GitHub Actions Fails

**Error:** "Error: No valid credential sources found"

**Solution:** Verify `TF_API_TOKEN` secret is set correctly in GitHub.

## Next Steps

- **Monitor**: Check Cloudflare Analytics for blocked requests
- **Tune**: Adjust `waf_attack_score_threshold` based on traffic patterns
- **Extend**: Add more WAF rules or rate limiting
- **Alert**: Set up notifications for policy violations

## Security Best Practices

✅ **DO:**
- Rotate API tokens regularly
- Use separate tokens for different environments
- Review all changes via pull requests
- Monitor Cloudflare security events

❌ **DON'T:**
- Commit secrets to the repository
- Bypass OPA policy checks
- Apply changes without review
- Use overly permissive API tokens
