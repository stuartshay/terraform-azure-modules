# Makefile for Terraform Azure Modules

# Variables
SHELL := /bin/bash
.DEFAULT_GOAL := help

# Colors for output
GREEN := \033[0;32m
YELLOW := \033[1;33m
NC := \033[0m

# Directories
MODULES_DIR := modules

# Help
.PHONY: help
help:
	@echo -e "${YELLOW}Available targets:${NC}"
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "} {printf "  ${GREEN}%-30s${NC} %s\n", $$1, $$2}'

# Format all Terraform files
.PHONY: terraform-fmt
terraform-fmt: ## Format all Terraform files
	terraform fmt -recursive .

# Validate all Terraform modules
.PHONY: terraform-validate
terraform-validate: ## Validate all Terraform modules
	@for dir in $(shell find $(MODULES_DIR) -maxdepth 2 -type d); do \
		if [ -f $$dir/versions.tf ]; then \
			cd $$dir && terraform init -backend=false && terraform validate; \
		fi; \
	done

# Run TFLint on all modules
.PHONY: tflint
 tflint: ## Run TFLint on all modules
	@for dir in $(shell find $(MODULES_DIR) -maxdepth 2 -type d); do \
		if [ -f $$dir/versions.tf ]; then \
			cd $$dir && tflint; \
		fi; \
	done

# Run Checkov on all modules
.PHONY: checkov
checkov: ## Run Checkov on all modules
	@for dir in $(shell find $(MODULES_DIR) -maxdepth 2 -type d); do \
		if [ -f $$dir/versions.tf ]; then \
			checkov -d $$dir; \
		fi; \
	done

# Run pre-commit hooks
.PHONY: pre-commit
pre-commit: ## Run pre-commit hooks
	pre-commit run --all-files

# Test all modules
.PHONY: terraform-test
terraform-test: ## Run Terraform tests for all modules
	@for dir in $(shell find $(MODULES_DIR) -maxdepth 2 -type d); do \
		if [ -d $$dir/tests ]; then \
			cd $$dir && terraform test; \
		fi; \
	done

# Test a specific module
.PHONY: terraform-test-module
terraform-test-module: ## Run Terraform tests for a specific module (MODULE=module-name)
	@if [ -z "$(MODULE)" ]; then \
		echo "Please specify MODULE variable, e.g., make terraform-test-module MODULE=app-service-plan-function"; \
		exit 1; \
	fi; \
	cd $(MODULES_DIR)/$(MODULE) && terraform test

# Test a specific test file in a module
.PHONY: terraform-test-file
terraform-test-file: ## Run Terraform test for a specific file (MODULE=module-name FILE=test-file)
	@if [ -z "$(MODULE)" ] || [ -z "$(FILE)" ]; then \
		echo "Please specify MODULE and FILE variables, e.g., make terraform-test-file MODULE=app-service-plan-function FILE=basic.tftest.hcl"; \
		exit 1; \
	fi; \
	cd $(MODULES_DIR)/$(MODULE) && terraform test tests/$(FILE)

# Publish module to Terraform Cloud (requires setup)
.PHONY: publish
publish: ## Publish module to Terraform Cloud
	./scripts/publish-to-terraform-cloud.sh

# Setup GitHub secrets for publishing
.PHONY: setup-github-secrets
setup-github-secrets: ## Setup GitHub secrets for publishing
	./scripts/setup-github-secrets.sh

# Run all tests (format, validate, lint, checkov, pre-commit, terraform-test)
.PHONY: test-all
test-all: terraform-fmt terraform-validate tflint checkov pre-commit terraform-test ## Run all tests

# Auto version bump
.PHONY: auto-version
auto-version: ## Auto version bump
	./scripts/auto-version.sh

# Pre-commit Terraform test
.PHONY: pre-commit-terraform-test
pre-commit-terraform-test: ## Run pre-commit Terraform test
	./scripts/pre-commit-terraform-test.sh
