# Contributing Guide

## Making Changes

### 1. Create a Feature Branch

```bash
git checkout -b feature/your-feature-name
```

### 2. Make Your Changes

Edit the Terraform files as needed. Common changes:

- Adjust WAF threshold in `variables.tf`
- Add new WAF rules in `main.tf`
- Update OPA policies in `policies/`

### 3. Test Locally

```bash
# Format code
terraform fmt -recursive

# Validate configuration
terraform init
terraform validate

# Run OPA tests
opa test policies/ -v

# Review plan
terraform plan
```

### 4. Commit and Push

```bash
git add .
git commit -m "feat: descriptive commit message"
git push origin feature/your-feature-name
```

### 5. Create Pull Request

1. Go to GitHub and create a PR
2. Wait for automated checks to complete
3. Review the Terraform plan in PR comments
4. Request review from team members

### 6. Merge

Once approved and all checks pass:
1. Merge the PR
2. Automatic deployment will trigger
3. Verify changes in Cloudflare Dashboard

## OPA Policy Development

### Writing New Policies

Add new policies to `policies/waf_required.rego`:

```rego
deny[msg] {
    # Your policy logic here
    msg := "POLICY VIOLATION: Description of violation"
}
```

### Testing Policies

Add tests to `policies/waf_required_test.rego`:

```rego
test_your_policy_name {
    # Test that should pass
    not deny[_] with input as { ... }
}

test_your_policy_fails {
    # Test that should fail
    deny[msg] with input as { ... }
    count(deny) > 0
}
```

Run tests:
```bash
opa test policies/ -v
```

## Commit Message Convention

Use conventional commits:

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `test:` Test changes
- `refactor:` Code refactoring
- `chore:` Maintenance tasks

Examples:
```
feat: add rate limiting rule
fix: correct WAF expression syntax
docs: update setup instructions
```

## Code Review Checklist

- [ ] Terraform code is formatted (`terraform fmt`)
- [ ] All OPA tests pass
- [ ] No secrets in code
- [ ] Documentation updated if needed
- [ ] Commit messages follow convention
- [ ] PR description explains the change
