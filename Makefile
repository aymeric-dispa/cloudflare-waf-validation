.PHONY: help init validate plan apply test fmt clean

help:
	@echo "Cloudflare WAF Validation - Available Commands:"
	@echo ""
	@echo "  make init      - Initialize Terraform"
	@echo "  make validate  - Validate Terraform configuration"
	@echo "  make plan      - Generate Terraform plan"
	@echo "  make apply     - Apply Terraform changes"
	@echo "  make test      - Run OPA policy tests"
	@echo "  make fmt       - Format Terraform code"
	@echo "  make clean     - Clean Terraform files"
	@echo "  make check     - Run all checks (fmt, validate, test)"
	@echo ""

init:
	@echo "🔧 Initializing Terraform..."
	terraform init

validate: init
	@echo "✅ Validating Terraform configuration..."
	terraform validate

plan: validate
	@echo "📋 Generating Terraform plan..."
	terraform plan

apply: validate
	@echo "🚀 Applying Terraform changes..."
	terraform apply

test:
	@echo "🧪 Running OPA policy tests..."
	opa test policies/ -v

fmt:
	@echo "🎨 Formatting Terraform code..."
	terraform fmt -recursive

check: fmt validate test
	@echo "✅ All checks passed!"

clean:
	@echo "🧹 Cleaning Terraform files..."
	rm -rf .terraform/
	rm -f .terraform.lock.hcl
	rm -f tfplan.binary
	rm -f tfplan.json
	rm -f terraform.tfstate
	rm -f terraform.tfstate.backup
