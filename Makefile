# Terraform Azure Modules Development Makefile
#
# This Makefile provides a unified interface for Terraform module development,
# testing, validation, and publishing operations.

# Project Configuration
PROJECT_NAME := terraform-azure-modules
MODULES_PATH := modules
EXAMPLES_PATH := examples
DOCS_PATH := docs

# Colors for output (if terminal supports it)
ifneq (,$(findstring xterm,${TERM}))
	RED := $(shell tput -Txterm setaf 1)
	GREEN := $(shell tput -Txterm setaf 2)
	YELLOW := $(shell tput -Txterm setaf 3)
	BLUE := $(shell tput -Txterm setaf 4)
	RESET := $(shell tput -Txterm sgr0)
else
	RED := ""
	GREEN := ""
	YELLOW := ""
	BLUE := ""
	RESET := ""
endif

# Default target
.DEFAULT_GOAL := help

# Phony targets (targets that don't create files)
.PHONY: help setup clean install status \
	modules module-list module-validate module-test module-docs module-examples \
	terraform terraform-fmt terraform-validate terraform-init terraform-plan terraform-apply \
	terraform-fmt-check terraform-lint terraform-version terraform-docs \
	quality pre-commit pre-commit-install pre-commit-update lint lint-terraform \
	security security-scan security-tfsec security-checkov \
	cost cost-breakdown cost-diff \
	docs docs-generate docs-check docs-serve \
	test test-all test-examples test-module test-integration \
	validate validate-all validate-modules validate-examples validate-syntax \
	release version-bump tag-release changelog \
	ci ci-validate ci-test ci-security \
	dev dev-setup dev-validate dev-test

##@ General

help: ## Display this help message
	@echo "$(GREEN)Terraform Azure Modules Development Environment$(RESET)"
	@echo ""
	@echo "$(YELLOW)Usage: make <target>$(RESET)"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  $(BLUE)%-25s$(RESET) %s\n", $$1, $$2 } /^##@/ { printf "\n$(YELLOW)%s$(RESET)\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	@echo ""
	@echo "$(GREEN)Quick Start:$(RESET)"
	@echo "  make setup              # Initial environment setup"
	@echo "  make validate-all       # Validate all modules"
	@echo "  make test-all           # Test all modules"
	@echo "  make docs-generate      # Generate documentation"
	@echo ""

status: ## Show current project status
	@echo "$(GREEN)=== Project Status ===$(RESET)"
	@echo "Project: $(PROJECT_NAME)"
	@echo "Terraform: $(shell terraform --version 2>/dev/null | head -1 || echo 'Not installed')"
	@echo "tfenv: $(shell tfenv --version 2>/dev/null || echo 'Not installed')"
	@echo "tflint: $(shell tflint --version 2>/dev/null || echo 'Not installed')"
	@echo "tfsec: $(shell tfsec --version 2>/dev/null || echo 'Not installed')"
	@echo "terraform-docs: $(shell terraform-docs --version 2>/dev/null || echo 'Not installed')"
	@echo "checkov: $(shell checkov --version 2>/dev/null || echo 'Not installed')"
	@echo "infracost: $(shell infracost --version 2>/dev/null || echo 'Not installed')"
	@echo "pre-commit: $(shell pre-commit --version 2>/dev/null || echo 'Not installed')"
	@echo "GitHub CLI: $(shell gh --version 2>/dev/null | head -1 || echo 'Not installed')"
	@echo ""
	@echo "$(BLUE)Available modules:$(RESET)"
	@find $(MODULES_PATH) -maxdepth 1 -type d -not -path $(MODULES_PATH) | sed 's|$(MODULES_PATH)/|  - |' || echo "  No modules found"

setup: ## Complete environment setup
	@echo "$(GREEN)Setting up development environment...$(RESET)"
	@if [ ! -x "./install.sh" ]; then \
		echo "$(RED)Error: install.sh not found or not executable$(RESET)"; \
		echo "Please ensure install.sh exists and run: chmod +x install.sh"; \
		exit 1; \
	fi
	@echo "$(YELLOW)Running install script...$(RESET)"
	@./install.sh
	@echo "$(GREEN)Environment setup completed$(RESET)"

install: setup ## Install development dependencies (alias)

clean: ## Clean up generated files and caches
	@echo "$(YELLOW)Cleaning up generated files...$(RESET)"
	find . -name ".terraform" -type d -exec rm -rf {} + 2>/dev/null || true
	find . -name ".terraform.lock.hcl" -delete 2>/dev/null || true
	find . -name "terraform.tfstate*" -delete 2>/dev/null || true
	find . -name ".terragrunt-cache" -type d -exec rm -rf {} + 2>/dev/null || true
	rm -rf .tflint.d/ 2>/dev/null || true
	@echo "$(GREEN)Cleanup completed$(RESET)"

##@ Module Management

modules: module-list ## List all modules (alias)

module-list: ## List all available modules
	@echo "$(GREEN)Available Terraform Modules:$(RESET)"
	@find $(MODULES_PATH) -maxdepth 1 -type d -not -path $(MODULES_PATH) | while read -r module; do \
		module_name=$$(basename "$$module"); \
		if [ -f "$$module/main.tf" ]; then \
			echo "  $(BLUE)$$module_name$(RESET)"; \
			if [ -f "$$module/README.md" ]; then \
				description=$$(grep -m1 "^# " "$$module/README.md" 2>/dev/null | sed 's/^# //' || echo "No description"); \
				echo "    $$description"; \
			fi; \
			if [ -d "$$module/examples" ]; then \
				example_count=$$(find "$$module/examples" -maxdepth 1 -type d | wc -l); \
				echo "    Examples: $$((example_count - 1))"; \
			fi; \
		fi; \
	done

module-validate: ## Validate a specific module (usage: make module-validate MODULE=monitoring)
	@if [ -z "$(MODULE)" ]; then \
		echo "$(RED)Error: MODULE parameter required$(RESET)"; \
		echo "Usage: make module-validate MODULE=monitoring"; \
		exit 1; \
	fi
	@if [ ! -d "$(MODULES_PATH)/$(MODULE)" ]; then \
		echo "$(RED)Error: Module $(MODULE) not found$(RESET)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)Validating module: $(MODULE)$(RESET)"
	@cd $(MODULES_PATH)/$(MODULE) && terraform init -backend=false
	@cd $(MODULES_PATH)/$(MODULE) && terraform validate
	@cd $(MODULES_PATH)/$(MODULE) && terraform fmt -check
	@echo "$(GREEN)Module $(MODULE) validation completed$(RESET)"

module-test: ## Test a specific module's examples (usage: make module-test MODULE=monitoring)
	@if [ -z "$(MODULE)" ]; then \
		echo "$(RED)Error: MODULE parameter required$(RESET)"; \
		echo "Usage: make module-test MODULE=monitoring"; \
		exit 1; \
	fi
	@if [ ! -d "$(MODULES_PATH)/$(MODULE)" ]; then \
		echo "$(RED)Error: Module $(MODULE) not found$(RESET)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)Testing module examples: $(MODULE)$(RESET)"
	@if [ -d "$(MODULES_PATH)/$(MODULE)/examples" ]; then \
		find "$(MODULES_PATH)/$(MODULE)/examples" -maxdepth 1 -type d -not -path "$(MODULES_PATH)/$(MODULE)/examples" | while read -r example; do \
			example_name=$$(basename "$$example"); \
			echo "$(BLUE)Testing example: $$example_name$(RESET)"; \
			cd "$$example" && terraform init -backend=false && terraform validate; \
		done; \
	else \
		echo "$(YELLOW)No examples found for module $(MODULE)$(RESET)"; \
	fi
	@echo "$(GREEN)Module $(MODULE) testing completed$(RESET)"

module-docs: ## Generate documentation for a specific module (usage: make module-docs MODULE=monitoring)
	@if [ -z "$(MODULE)" ]; then \
		echo "$(RED)Error: MODULE parameter required$(RESET)"; \
		echo "Usage: make module-docs MODULE=monitoring"; \
		exit 1; \
	fi
	@if [ ! -d "$(MODULES_PATH)/$(MODULE)" ]; then \
		echo "$(RED)Error: Module $(MODULE) not found$(RESET)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)Generating documentation for module: $(MODULE)$(RESET)"
	@cd $(MODULES_PATH)/$(MODULE) && terraform-docs markdown table --output-file README.md --output-mode inject .
	@echo "$(GREEN)Documentation generated for module $(MODULE)$(RESET)"

module-examples: ## List examples for all modules
	@echo "$(GREEN)Module Examples:$(RESET)"
	@find $(MODULES_PATH) -path "*/examples/*" -name "main.tf" | while read -r example; do \
		module_path=$$(echo "$$example" | sed 's|/examples/.*||' | sed 's|$(MODULES_PATH)/||'); \
		example_path=$$(echo "$$example" | sed 's|.*/examples/||' | sed 's|/main.tf||'); \
		echo "  $(BLUE)$$module_path$(RESET)/$(YELLOW)$$example_path$(RESET)"; \
	done

##@ Terraform Operations

terraform-fmt: ## Format all Terraform files
	@echo "$(YELLOW)Formatting Terraform files...$(RESET)"
	@terraform fmt -recursive .
	@echo "$(GREEN)Terraform formatting completed$(RESET)"

terraform-fmt-check: ## Check Terraform formatting without making changes
	@echo "$(YELLOW)Checking Terraform formatting...$(RESET)"
	@terraform fmt -check -recursive .

terraform-validate: ## Validate all Terraform configurations
	@echo "$(YELLOW)Validating Terraform configurations...$(RESET)"
	@find $(MODULES_PATH) -name "main.tf" -exec dirname {} \; | sort -u | while read -r dir; do \
		echo "$(BLUE)Validating: $$dir$(RESET)"; \
		cd "$$dir" && terraform init -backend=false >/dev/null && terraform validate; \
	done
	@echo "$(GREEN)Terraform validation completed$(RESET)"

terraform-init: ## Initialize Terraform in all modules and examples
	@echo "$(YELLOW)Initializing Terraform configurations...$(RESET)"
	@find $(MODULES_PATH) -name "main.tf" -exec dirname {} \; | sort -u | while read -r dir; do \
		echo "$(BLUE)Initializing: $$dir$(RESET)"; \
		cd "$$dir" && terraform init -backend=false; \
	done
	@echo "$(GREEN)Terraform initialization completed$(RESET)"

terraform-plan: ## Plan Terraform changes for examples (usage: make terraform-plan MODULE=monitoring EXAMPLE=basic)
	@if [ -z "$(MODULE)" ] || [ -z "$(EXAMPLE)" ]; then \
		echo "$(RED)Error: MODULE and EXAMPLE parameters required$(RESET)"; \
		echo "Usage: make terraform-plan MODULE=monitoring EXAMPLE=basic"; \
		exit 1; \
	fi
	@if [ ! -d "$(MODULES_PATH)/$(MODULE)/examples/$(EXAMPLE)" ]; then \
		echo "$(RED)Error: Example $(EXAMPLE) not found for module $(MODULE)$(RESET)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)Planning Terraform changes for $(MODULE)/$(EXAMPLE)...$(RESET)"
	@cd $(MODULES_PATH)/$(MODULE)/examples/$(EXAMPLE) && terraform init -backend=false && terraform plan

terraform-apply: ## Apply Terraform changes for examples (usage: make terraform-apply MODULE=monitoring EXAMPLE=basic)
	@if [ -z "$(MODULE)" ] || [ -z "$(EXAMPLE)" ]; then \
		echo "$(RED)Error: MODULE and EXAMPLE parameters required$(RESET)"; \
		echo "Usage: make terraform-apply MODULE=monitoring EXAMPLE=basic"; \
		exit 1; \
	fi
	@if [ ! -d "$(MODULES_PATH)/$(MODULE)/examples/$(EXAMPLE)" ]; then \
		echo "$(RED)Error: Example $(EXAMPLE) not found for module $(MODULE)$(RESET)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)Applying Terraform changes for $(MODULE)/$(EXAMPLE)...$(RESET)"
	@cd $(MODULES_PATH)/$(MODULE)/examples/$(EXAMPLE) && terraform init -backend=false && terraform apply

terraform-lint: ## Lint Terraform files with tflint
	@echo "$(YELLOW)Linting Terraform files...$(RESET)"
	@if command -v tflint >/dev/null 2>&1; then \
		tflint --init >/dev/null 2>&1 || true; \
		find $(MODULES_PATH) -name "*.tf" -exec dirname {} \; | sort -u | while read -r dir; do \
			echo "$(BLUE)Linting: $$dir$(RESET)"; \
			cd "$$dir" && tflint; \
		done; \
	else \
		echo "$(RED)tflint not found. Run 'make setup' to install.$(RESET)"; \
		exit 1; \
	fi
	@echo "$(GREEN)Terraform linting completed$(RESET)"

terraform-version: ## Show Terraform version information
	@echo "$(YELLOW)Terraform Version Information:$(RESET)"
	@if [ -f .terraform-version ]; then \
		echo "Required version: $(shell cat .terraform-version)"; \
	fi
	@if command -v terraform >/dev/null 2>&1; then \
		echo "Installed version: $(shell terraform --version | head -1)"; \
	else \
		echo "$(RED)Terraform not installed$(RESET)"; \
	fi
	@if command -v tfenv >/dev/null 2>&1; then \
		echo "tfenv version: $(shell tfenv --version)"; \
		echo "Available versions: $(shell tfenv list | head -5 | tr '\n' ' ')"; \
	fi

terraform-docs: ## Generate Terraform documentation for all modules
	@echo "$(YELLOW)Generating Terraform documentation...$(RESET)"
	@find $(MODULES_PATH) -maxdepth 1 -type d -not -path $(MODULES_PATH) | while read -r module; do \
		module_name=$$(basename "$$module"); \
		echo "$(BLUE)Generating docs for: $$module_name$(RESET)"; \
		cd "$$module" && terraform-docs markdown table --output-file README.md --output-mode inject .; \
	done
	@echo "$(GREEN)Terraform documentation generation completed$(RESET)"

##@ Quality Assurance

quality: pre-commit lint security ## Run all quality checks

pre-commit: ## Run pre-commit hooks on all files
	@echo "$(YELLOW)Running pre-commit hooks...$(RESET)"
	@if command -v pre-commit >/dev/null 2>&1; then \
		pre-commit run --all-files; \
	else \
		echo "$(RED)pre-commit not found. Run 'make setup' to install.$(RESET)"; \
		exit 1; \
	fi

pre-commit-install: ## Install pre-commit hooks
	@echo "$(YELLOW)Installing pre-commit hooks...$(RESET)"
	@if command -v pre-commit >/dev/null 2>&1; then \
		pre-commit install; \
		pre-commit install-hooks; \
	else \
		echo "$(RED)pre-commit not found. Run 'make setup' to install.$(RESET)"; \
		exit 1; \
	fi
	@echo "$(GREEN)Pre-commit hooks installed$(RESET)"

pre-commit-update: ## Update pre-commit hooks to latest versions
	@echo "$(YELLOW)Updating pre-commit hooks...$(RESET)"
	@if command -v pre-commit >/dev/null 2>&1; then \
		pre-commit autoupdate; \
		pre-commit install; \
	else \
		echo "$(RED)pre-commit not found. Run 'make setup' to install.$(RESET)"; \
		exit 1; \
	fi
	@echo "$(GREEN)Pre-commit hooks updated$(RESET)"

lint: terraform-lint ## Run all linting (alias)

lint-terraform: terraform-lint ## Lint Terraform files (alias)

##@ Security

security: security-scan ## Run all security scans (alias)

security-scan: security-tfsec security-checkov ## Run all security scans

security-tfsec: ## Run tfsec security scanning
	@echo "$(YELLOW)Running tfsec security scan...$(RESET)"
	@if command -v tfsec >/dev/null 2>&1; then \
		tfsec . --soft-fail; \
	else \
		echo "$(RED)tfsec not found. Run 'make setup' to install.$(RESET)"; \
		exit 1; \
	fi

security-checkov: ## Run Checkov security scanning
	@echo "$(YELLOW)Running Checkov security scan...$(RESET)"
	@if command -v checkov >/dev/null 2>&1; then \
		checkov -d $(MODULES_PATH) --framework terraform --quiet; \
	else \
		echo "$(RED)Checkov not found. Run 'make setup' to install.$(RESET)"; \
		exit 1; \
	fi

##@ Cost Analysis

cost: cost-breakdown ## Run cost analysis (alias)

cost-breakdown: ## Generate cost breakdown for modules
	@echo "$(YELLOW)Generating cost breakdown...$(RESET)"
	@if command -v infracost >/dev/null 2>&1; then \
		find $(MODULES_PATH) -path "*/examples/*" -name "main.tf" -exec dirname {} \; | while read -r example; do \
			echo "$(BLUE)Cost analysis for: $$example$(RESET)"; \
			cd "$$example" && infracost breakdown --path . --format table || echo "$(YELLOW)Skipping $$example (no cost data)$(RESET)"; \
		done; \
	else \
		echo "$(RED)infracost not found. Run 'make setup' to install.$(RESET)"; \
		exit 1; \
	fi

cost-diff: ## Generate cost diff (usage: make cost-diff MODULE=monitoring EXAMPLE=basic)
	@if [ -z "$(MODULE)" ] || [ -z "$(EXAMPLE)" ]; then \
		echo "$(RED)Error: MODULE and EXAMPLE parameters required$(RESET)"; \
		echo "Usage: make cost-diff MODULE=monitoring EXAMPLE=basic"; \
		exit 1; \
	fi
	@echo "$(YELLOW)Generating cost diff for $(MODULE)/$(EXAMPLE)...$(RESET)"
	@if command -v infracost >/dev/null 2>&1; then \
		cd $(MODULES_PATH)/$(MODULE)/examples/$(EXAMPLE) && infracost diff --path .; \
	else \
		echo "$(RED)infracost not found. Run 'make setup' to install.$(RESET)"; \
		exit 1; \
	fi

##@ Documentation

docs: docs-generate ## Generate all documentation (alias)

docs-generate: terraform-docs ## Generate all documentation
	@echo "$(YELLOW)Generating project documentation...$(RESET)"
	@echo "$(GREEN)Documentation generation completed$(RESET)"

docs-check: ## Check documentation completeness
	@echo "$(YELLOW)Checking documentation completeness...$(RESET)"
	@find $(MODULES_PATH) -maxdepth 1 -type d -not -path $(MODULES_PATH) | while read -r module; do \
		module_name=$$(basename "$$module"); \
		if [ ! -f "$$module/README.md" ]; then \
			echo "$(RED)Missing README.md in $$module_name$(RESET)"; \
		else \
			echo "$(GREEN)✓ $$module_name has README.md$(RESET)"; \
		fi; \
		if [ ! -f "$$module/variables.tf" ]; then \
			echo "$(RED)Missing variables.tf in $$module_name$(RESET)"; \
		fi; \
		if [ ! -f "$$module/outputs.tf" ]; then \
			echo "$(RED)Missing outputs.tf in $$module_name$(RESET)"; \
		fi; \
	done

docs-serve: ## Serve documentation locally
	@echo "$(YELLOW)Documentation available in README.md files$(RESET)"
	@echo "$(BLUE)Main README: README.md$(RESET)"
	@find $(MODULES_PATH) -name "README.md" | while read -r readme; do \
		echo "$(BLUE)Module README: $$readme$(RESET)"; \
	done

##@ Testing

test: test-all ## Run all tests (alias)

test-all: validate-all test-examples ## Run all tests

test-examples: ## Test all module examples
	@echo "$(YELLOW)Testing all module examples...$(RESET)"
	@find $(MODULES_PATH) -path "*/examples/*/main.tf" -exec dirname {} \; | while read -r example; do \
		echo "$(BLUE)Testing example: $$example$(RESET)"; \
		cd "$$example" && terraform init -backend=false && terraform validate; \
	done
	@echo "$(GREEN)All example tests completed$(RESET)"

test-module: module-test ## Test a specific module (alias)

test-integration: ## Run integration tests
	@echo "$(YELLOW)Running integration tests...$(RESET)"
	@echo "$(BLUE)Integration tests would go here$(RESET)"
	@echo "$(GREEN)Integration tests completed$(RESET)"

##@ Validation

validate: validate-all ## Run all validations (alias)

validate-all: validate-modules validate-examples validate-syntax ## Run all validations

validate-modules: ## Validate all modules
	@echo "$(YELLOW)Validating all modules...$(RESET)"
	@find $(MODULES_PATH) -maxdepth 1 -type d -not -path $(MODULES_PATH) | while read -r module; do \
		module_name=$$(basename "$$module"); \
		echo "$(BLUE)Validating module: $$module_name$(RESET)"; \
		cd "$$module" && terraform init -backend=false >/dev/null && terraform validate; \
	done
	@echo "$(GREEN)All modules validated$(RESET)"

validate-examples: ## Validate all examples
	@echo "$(YELLOW)Validating all examples...$(RESET)"
	@find $(MODULES_PATH) -path "*/examples/*/main.tf" -exec dirname {} \; | while read -r example; do \
		echo "$(BLUE)Validating example: $$example$(RESET)"; \
		cd "$$example" && terraform init -backend=false >/dev/null && terraform validate; \
	done
	@echo "$(GREEN)All examples validated$(RESET)"

validate-syntax: ## Validate syntax of all files
	@echo "$(YELLOW)Validating file syntax...$(RESET)"
	@find . -name "*.tf" -exec terraform fmt -check {} \; || echo "$(RED)Terraform formatting issues found$(RESET)"
	@find . -name "*.json" -not -path "./.git/*" -exec jq empty {} \; || echo "$(RED)JSON syntax issues found$(RESET)"
	@find . -name "*.yaml" -o -name "*.yml" -not -path "./.git/*" | xargs -I {} sh -c 'python3 -c "import yaml; yaml.safe_load(open(\"{}\"))"' || echo "$(RED)YAML syntax issues found$(RESET)"
	@echo "$(GREEN)Syntax validation completed$(RESET)"

##@ Release Management

version-bump: ## Bump version (usage: make version-bump VERSION=0.2.0)
	@if [ -z "$(VERSION)" ]; then \
		echo "$(RED)Error: VERSION parameter required$(RESET)"; \
		echo "Usage: make version-bump VERSION=0.2.0"; \
		exit 1; \
	fi
	@echo "$(YELLOW)Bumping version to $(VERSION)...$(RESET)"
	@echo "$(VERSION)" > VERSION
	@git add VERSION
	@echo "$(GREEN)Version bumped to $(VERSION)$(RESET)"

tag-release: ## Create and push release tag (usage: make tag-release VERSION=0.2.0)
	@if [ -z "$(VERSION)" ]; then \
		echo "$(RED)Error: VERSION parameter required$(RESET)"; \
		echo "Usage: make tag-release VERSION=0.2.0"; \
		exit 1; \
	fi
	@echo "$(YELLOW)Creating release tag v$(VERSION)...$(RESET)"
	@git tag -a "v$(VERSION)" -m "Release v$(VERSION)"
	@git push origin "v$(VERSION)"
	@echo "$(GREEN)Release tag v$(VERSION) created and pushed$(RESET)"

changelog: ## Generate changelog
	@echo "$(YELLOW)Generating changelog...$(RESET)"
	@if command -v gh >/dev/null 2>&1; then \
		gh api repos/:owner/:repo/releases --jq '.[].tag_name' | head -10; \
	else \
		git tag --sort=-version:refname | head -10; \
	fi
	@echo "$(GREEN)Changelog information displayed$(RESET)"

##@ CI/CD

ci-validate: ## Run CI validation checks
	@echo "$(YELLOW)Running CI validation...$(RESET)"
	@$(MAKE) terraform-fmt-check
	@$(MAKE) validate-all
	@$(MAKE) terraform-lint
	@echo "$(GREEN)CI validation completed$(RESET)"

ci-test: ## Run CI tests
	@echo "$(YELLOW)Running CI tests...$(RESET)"
	@$(MAKE) test-all
	@echo "$(GREEN)CI tests completed$(RESET)"

ci-security: ## Run CI security checks
	@echo "$(YELLOW)Running CI security checks...$(RESET)"
	@$(MAKE) security-scan
	@echo "$(GREEN)CI security checks completed$(RESET)"

##@ Development

dev-setup: setup ## Setup development environment (alias)

dev-validate: ## Quick development validation
	@echo "$(YELLOW)Running development validation...$(RESET)"
	@$(MAKE) terraform-fmt
	@$(MAKE) validate-modules
	@$(MAKE) pre-commit
	@echo "$(GREEN)Development validation completed$(RESET)"

dev-test: ## Quick development testing
	@echo "$(YELLOW)Running development tests...$(RESET)"
	@$(MAKE) test-examples
	@echo "$(GREEN)Development tests completed$(RESET)"

##@ Utilities

env: ## Show environment information
	@echo "$(YELLOW)Environment Information:$(RESET)"
	@echo "PROJECT_NAME: $(PROJECT_NAME)"
	@echo "MODULES_PATH: $(MODULES_PATH)"
	@echo "PWD: $(shell pwd)"
	@echo "Git branch: $(shell git branch --show-current 2>/dev/null || echo 'Not a git repository')"
	@echo "Git remote: $(shell git remote get-url origin 2>/dev/null || echo 'No remote configured')"

tools: ## Show installed tool versions
	@echo "$(YELLOW)Installed Tools:$(RESET)"
	@echo "Terraform: $(shell terraform --version 2>/dev/null | head -1 || echo 'Not installed')"
	@echo "tfenv: $(shell tfenv --version 2>/dev/null || echo 'Not installed')"
	@echo "tflint: $(shell tflint --version 2>/dev/null || echo 'Not installed')"
	@echo "tfsec: $(shell tfsec --version 2>/dev/null || echo 'Not installed')"
	@echo "terraform-docs: $(shell terraform-docs --version 2>/dev/null || echo 'Not installed')"
	@echo "checkov: $(shell checkov --version 2>/dev/null || echo 'Not installed')"
	@echo "infracost: $(shell infracost --version 2>/dev/null || echo 'Not installed')"
	@echo "pre-commit: $(shell pre-commit --version 2>/dev/null || echo 'Not installed')"
	@echo "GitHub CLI: $(shell gh --version 2>/dev/null | head -1 || echo 'Not installed')"
	@echo "jq: $(shell jq --version 2>/dev/null || echo 'Not installed')"
	@echo "yq: $(shell yq --version 2>/dev/null || echo 'Not installed')"
