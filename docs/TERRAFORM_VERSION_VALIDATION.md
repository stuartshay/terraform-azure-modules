# Terraform Version Validation

This document describes the Terraform version validation system implemented in this repository to ensure consistency across all modules and workflows.

## Overview

The validation system ensures that:
1. All modules use consistent Terraform and provider versions
2. All example files use consistent Terraform and provider versions
3. The `.terraform-version` file matches module requirements
4. GitHub Actions workflows use the same Terraform version
5. Provider versions meet minimum security and feature requirements

## Current Requirements

- **Terraform Version**: `>= 1.13.1`
- **AzureRM Provider**: `>= 4.42.0`

## Validation Script

The main validation script is located at `scripts/validate-terraform-version.sh` and performs the following checks:

### 1. Terraform Version Consistency
- Reads the version from `.terraform-version`
- Validates all `modules/*/versions.tf` files have compatible `required_version`
- Ensures GitHub Actions workflows use the same version

### 2. Example File Validation
- Validates all `modules/*/examples/*/main.tf` files have compatible `required_version`
- Ensures example files use the required AzureRM provider version
- Checks consistency between module and example version requirements

### 3. Provider Version Validation
- Checks that all modules use the required AzureRM provider version
- Validates provider configuration consistency across modules and examples

### 4. Workflow Integration
- Validates `TF_VERSION` environment variables in GitHub Actions
- Checks `terraform_version` in `setup-terraform` actions

## Pre-commit Integration

The validation runs automatically as a pre-commit hook when you modify:
- `.terraform-version` file
- Any `modules/*/versions.tf` file
- Any `modules/*/examples/*/main.tf` file
- GitHub Actions workflow files (`.github/workflows/*.yml`)

### Manual Execution

You can run the validation manually:

```bash
# Run the validation script
bash scripts/validate-terraform-version.sh

# Or use pre-commit
pre-commit run terraform-version-validation --all-files
```

## Example Output

### Successful Validation
```
🔍 Validating .terraform-version consistency
Project Terraform version: 1.13.1
  ✓ GitHub Actions (terraform): 1.13.1
  ✓ app-service-plan-web: Terraform >= 1.13.1
  ✓ app-service-plan-web: azurerm >= 4.42.0
  ✓ container-instances: Terraform >= 1.13.1
  ✓ container-instances: azurerm >= 4.42.0
🔍 Validating example files
  ✓ app-service-plan-web/examples/basic: Terraform >= 1.13.1
  ✓ app-service-plan-web/examples/basic: azurerm >= 4.42.0
  ✓ container-instances/examples/basic: Terraform >= 1.13.1
  ✓ container-instances/examples/basic: azurerm >= 4.42.0
✅ All version requirements are consistent with .terraform-version
```

### Failed Validation
```
🔍 Validating .terraform-version consistency
Project Terraform version: 1.13.1
  ✓ GitHub Actions (terraform): 1.13.1
  ✓ networking: Terraform >= 1.13.1
  ✓ networking: azurerm >= 4.42.0
🔍 Validating example files
❌ Found inconsistent example version requirements:
  • storage-account/examples/basic: terraform version '>= 1.5', expected '>= 1.13.1'
  • storage-account/examples/basic: azurerm version '~> 4.40', expected '>= 4.42.0'
  • networking/examples/complete: terraform version '>= 1.5', expected '>= 1.13.1'
💡 To fix: Update version requirements in modules, examples, and/or workflow files to match project standards
```

## Fixing Version Inconsistencies

### 1. Update Module versions.tf

Ensure each module's `versions.tf` follows this pattern:

```hcl
terraform {
  required_version = ">= 1.13.1"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.42.0"
    }
  }
}
```

### 2. Update .terraform-version

The root `.terraform-version` file should contain:
```
1.13.1
```

### 3. Update Example Files

Ensure each example's `main.tf` follows this pattern:

```hcl
terraform {
  required_version = ">= 1.13.1"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.42.0"
    }
  }
}
```

### 4. Update GitHub Actions Workflows

Ensure workflows use the environment variable:

```yaml
env:
  TF_VERSION: '1.13.1'

steps:
  - uses: hashicorp/setup-terraform@v3
    with:
      terraform_version: ${{ env.TF_VERSION }}
```

## Configuration

The validation script uses these configurable values:

```bash
# In scripts/validate-terraform-version.sh
REQUIRED_AZURERM_VERSION=">= 4.42.0"
```

To update requirements:
1. Modify the script variables
2. Update this documentation
3. Update all module `versions.tf` files
4. Update `.terraform-version` if needed

## Integration with CI/CD

The validation is integrated into:

1. **Pre-commit hooks**: Runs on every commit
2. **GitHub Actions**: Validates on pull requests
3. **Manual testing**: Available via make targets

## Troubleshooting

### Common Issues

1. **Version mismatch**: Update the inconsistent files to match requirements
2. **Missing provider**: Add the required provider block to `versions.tf`
3. **Workflow inconsistency**: Update GitHub Actions to use environment variables

### Debug Mode

For detailed debugging, you can modify the script to add verbose output:

```bash
# Add to the beginning of validate-terraform-version.sh
set -x  # Enable debug mode
```

## Best Practices

1. **Always use version constraints**: Use `>= x.y.z` for minimum versions
2. **Keep versions current**: Regularly update to latest stable versions
3. **Test thoroughly**: Run validation before committing changes
4. **Document changes**: Update this file when changing requirements

## Related Files

- `scripts/validate-terraform-version.sh` - Main validation script
- `.pre-commit-config.yaml` - Pre-commit hook configuration
- `.terraform-version` - Project Terraform version
- `modules/*/versions.tf` - Module version requirements
- `.github/workflows/*.yml` - GitHub Actions workflows
