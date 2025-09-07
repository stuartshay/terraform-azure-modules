# GitHub Copilot Environment Setup

This document explains the GitHub Copilot environment setup for the Terraform Azure modules repository.

## Overview

The `.github/workflows/copilot-setup-steps.yml` workflow is designed to run during the Copilot setup phase (before firewall restrictions are enabled) to install and configure all necessary tools and dependencies.

## Problem Addressed

The workflow resolves the firewall blocking issues mentioned in issue #91:

- **app.terraform.io** - Terraform Cloud private registry access
- **checkpoint-api.hashicorp.com** - Terraform telemetry 
- **esm.ubuntu.com** - Ubuntu package management
- **GitHub API endpoints** - Tool installation from releases

## Required Secrets

The following repository secrets must be configured for the Copilot environment:

### Terraform Cloud Secrets
- `TF_API_TOKEN` - Terraform Cloud API token for private module access
- `TF_CLOUD_ORGANIZATION` - Terraform Cloud organization name

### Azure Authentication Secrets  
- `ARM_CLIENT_ID` - Azure service principal client ID
- `ARM_CLIENT_SECRET` - Azure service principal client secret
- `ARM_SUBSCRIPTION_ID` - Azure subscription ID
- `ARM_TENANT_ID` - Azure tenant ID

## Setup Process

The workflow performs the following setup steps:

### 1. Secret Validation ✅
- Validates all required secrets are available
- Provides detailed feedback on missing secrets
- Fails early if critical secrets are not configured

### 2. System Dependencies ✅
- jq (JSON processor)
- yq (YAML processor) 
- shellcheck (shell script linter)
- zip/unzip utilities
- curl/wget for downloads

### 3. Terraform Installation ✅
- Installs tfenv (Terraform version manager)
- Installs Terraform 1.13.1 (from .terraform-version)
- Configures Terraform Cloud authentication
- Sets up CLI credentials for private registry access

### 4. Development Tools ✅
- **TFLint** - Terraform linting
- **terraform-docs** - Documentation generation
- **tfsec** - Security scanning
- **Checkov** - Additional security scanning
- **pre-commit** - Git hooks framework

### 5. Environment Configuration ✅
- Sets up Terraform Cloud authentication
- Configures Azure environment variables
- Initializes TFLint with repository configuration
- Installs and configures pre-commit hooks

### 6. Module Initialization ✅
- Initializes all Terraform modules for documentation
- Handles modules requiring private registry access
- Cleans up temporary files to save space

### 7. Validation ✅
- Runs complete pre-commit validation
- Tests all installed tools
- Provides comprehensive environment summary

## Usage

### Manual Trigger
The workflow can be manually triggered from the GitHub Actions tab:

1. Go to **Actions** tab in the repository
2. Select **Copilot Environment Setup**
3. Click **Run workflow**

### Automatic Integration
The workflow is designed to be triggered automatically by GitHub Copilot during environment setup.

## Expected Output

The workflow provides comprehensive logging including:

- ✅ Secret validation results
- ✅ Tool installation confirmations  
- ✅ Terraform Cloud authentication status
- ✅ Pre-commit validation results
- ✅ Environment summary with available commands

## Commands Available After Setup

Once the setup is complete, the following commands are available:

```bash
# Format Terraform code
terraform fmt -recursive .

# Validate all modules  
make validate-all

# Run Terraform tests
make terraform-test

# Run all pre-commit checks
pre-commit run --all-files

# Run security scanning
make security-scan
```

## Troubleshooting

### Missing Secrets
If secrets are missing, the workflow will fail with clear instructions:

```
❌ Missing required secrets:
  - TF_API_TOKEN
  - ARM_CLIENT_ID

Please add these secrets to your repository:
1. Go to Settings → Secrets and variables → Actions
2. Click 'New repository secret'
3. Add each missing secret with its appropriate value
```

### Authentication Issues
If Terraform Cloud authentication fails:
- Verify TF_API_TOKEN is valid and not expired
- Ensure TF_CLOUD_ORGANIZATION matches your organization name
- Check token has appropriate permissions for the organization

### Tool Installation Failures
The workflow includes caching to handle temporary network issues:
- System packages are cached between runs
- Binary tools are cached with version-specific keys
- Python packages are cached separately

## Integration with Existing Workflows

The Copilot setup workflow complements existing workflows:
- **pre-commit.yml** - Comprehensive validation in CI/CD
- **terraform.yml** - Module validation and security scanning
- **terraform-cloud-deploy.yml** - Module publishing

All workflows share the same tool versions and configurations for consistency.

## Testing

A test script is available to verify the setup locally:

```bash
# Test the environment setup
./scripts/test-copilot-setup.sh
```

The test validates:
- Secret validation logic
- YAML syntax
- Pre-commit configuration
- Basic Terraform operations
- Module initialization

## Security Considerations

- Secrets are only available to authorized repository maintainers
- Terraform Cloud credentials are scoped to specific organization
- Azure credentials follow principle of least privilege
- All secrets are encrypted at rest in GitHub Actions

## Maintenance

- Tool versions are pinned for reproducibility
- Caching reduces setup time and external dependencies
- Regular updates should be coordinated across all workflows
- Test any changes in a fork or feature branch first

## Support

For issues with the Copilot environment setup:

1. Check workflow run logs for specific errors
2. Verify all required secrets are configured  
3. Test locally using the provided test script
4. Review this documentation for troubleshooting steps