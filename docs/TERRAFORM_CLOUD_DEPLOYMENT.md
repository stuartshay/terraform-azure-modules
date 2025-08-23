# Terraform Cloud Deployment Guide

This guide explains how to deploy Terraform modules to Terraform Cloud using the automated GitHub Actions workflow.

## Overview

The project includes an automated deployment workflow that can publish Terraform modules to your Terraform Cloud private registry. The workflow supports:

- **Manual deployment** via GitHub Actions workflow dispatch
- **Module selection** (app-service-web or monitoring)
- **Version management** with semantic versioning
- **Dry run mode** for validation without publishing
- **Automated validation** and packaging

## Prerequisites

### 1. GitHub Secrets Configuration

The following secrets must be configured in your GitHub repository:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `TF_API_TOKEN` | Terraform Cloud API token | `XuJVvKUKpjJLvQ.atlasv1.U2Q7EtNL...` |
| `TF_CLOUD_ORGANIZATION` | Terraform Cloud organization name | `azure-policy-cloud` |

#### Setting up GitHub Secrets

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each secret with the values from your `.env` file

### 2. Terraform Cloud Setup

Ensure you have:
- A Terraform Cloud account
- An organization created (e.g., `azure-policy-cloud`)
- An API token with appropriate permissions

## Available Modules

The workflow currently supports these modules:

- **app-service-web**: Azure App Service resources including App Service Plan and Web App
- **monitoring**: Comprehensive monitoring solution with Log Analytics, Application Insights, and Azure Monitor

## Using the Deployment Workflow

### 1. Manual Deployment via GitHub Actions

1. Go to your GitHub repository
2. Navigate to **Actions** tab
3. Select **Deploy to Terraform Cloud** workflow
4. Click **Run workflow**
5. Fill in the parameters:
   - **Module to deploy**: Choose `app-service-web` or `monitoring`
   - **Module version**: Enter semantic version (e.g., `1.0.0`)
   - **Dry run**: Check for validation only, uncheck to publish

### 2. Workflow Parameters

| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|
| `module_name` | Module to deploy | Yes | `app-service-web` |
| `major_version` | Major version number | No | `1` |
| `minor_version` | Minor version number | No | `0` |
| `dry_run` | Validate only, don't publish | No | `false` |

**Auto-Generated Version**: The workflow automatically generates versions using the pattern `{major}.{minor}.{github_run_id}`, ensuring unique versions for every deployment.

### 3. Version Management

Use semantic versioning (MAJOR.MINOR.PATCH):
- **MAJOR**: Incompatible API changes
- **MINOR**: Backward-compatible functionality additions
- **PATCH**: Backward-compatible bug fixes

Examples:
- `1.0.0` - Initial release
- `1.1.0` - New features added
- `1.1.1` - Bug fixes
- `2.0.0` - Breaking changes

## Workflow Steps

The deployment workflow performs these steps:

1. **Validation**
   - Validates input parameters
   - Checks module directory exists
   - Verifies required files are present

2. **Terraform Validation**
   - Installs dependencies (jq, rsync)
   - Sets up Terraform Cloud credentials
   - Validates Terraform configuration
   - Checks formatting

3. **Package Creation**
   - Creates temporary directory
   - Copies module files (excludes examples)
   - Creates compressed tarball

4. **Publishing** (if not dry run)
   - Checks organization exists
   - Creates module if it doesn't exist
   - Creates new version
   - Uploads module package
   - Verifies deployment

5. **Results**
   - Displays deployment summary
   - Provides usage instructions
   - Shows registry URLs

## Local Testing

Before using the GitHub Actions workflow, you can test locally:

### 1. Test Module Validation

```bash
# Test app-service-web module
./scripts/test-publish-module.sh app-service-web 1.0.0

# Test monitoring module
./scripts/test-publish-module.sh monitoring 1.0.0
```

### 2. Publish to Terraform Cloud

```bash
# Publish app-service-web module
./scripts/publish-to-terraform-cloud.sh app-service-web 1.0.0

# Publish monitoring module
./scripts/publish-to-terraform-cloud.sh monitoring 1.0.0
```

## Using Published Modules

Once published, you can use the modules in your Terraform configurations:

### App Service Module

```hcl
module "app_service" {
  source  = "app.terraform.io/azure-policy-cloud/app-service-web/azurerm"
  version = "1.0.0"

  resource_group_name = "rg-example"
  location           = "East US"
  environment        = "dev"
  workload           = "myapp"

  tags = {
    Environment = "dev"
    Project     = "myapp"
  }
}
```

### Monitoring Module

```hcl
module "monitoring" {
  source  = "app.terraform.io/azure-policy-cloud/monitoring/azurerm"
  version = "1.0.0"

  resource_group_name = "rg-example"
  location           = "East US"
  workload           = "myapp"
  environment        = "dev"
  location_short     = "eastus"
  subscription_id    = "12345678-1234-1234-1234-123456789012"

  notification_emails = {
    admin = "admin@company.com"
  }

  tags = {
    Environment = "dev"
    Project     = "myapp"
  }
}
```

## Registry URLs

After deployment, modules are available at:

- **Public Registry**: `https://app.terraform.io/azure-policy-cloud/modules/{module-name}/azurerm/{version}`
- **Private Registry**: `https://app.terraform.io/azure-policy-cloud/registry/modules/private/azure-policy-cloud/{module-name}/azurerm`

## Troubleshooting

### Common Issues

1. **Organization not found**
   - Verify `TF_CLOUD_ORGANIZATION` secret is correct
   - Ensure you have access to the organization

2. **Authentication failed**
   - Check `TF_API_TOKEN` secret is valid
   - Verify token has appropriate permissions

3. **Module validation failed**
   - Check Terraform syntax in module files
   - Ensure all required files are present
   - Run local validation first

4. **Version already exists**
   - Use a new version number
   - Check existing versions in Terraform Cloud

### Getting Help

1. Check workflow logs in GitHub Actions
2. Review local test script output
3. Verify Terraform Cloud organization settings
4. Ensure all required secrets are configured

## Security Considerations

- Never commit `.env` file to version control
- Use GitHub Secrets for sensitive information
- Regularly rotate API tokens
- Review organization permissions in Terraform Cloud

## Best Practices

1. **Version Management**
   - Use semantic versioning consistently
   - Tag releases in Git to match module versions
   - Document changes in release notes

2. **Testing**
   - Always test locally before using GitHub Actions
   - Use dry run mode for validation
   - Test modules in development environments

3. **Documentation**
   - Keep module README files up to date
   - Include usage examples
   - Document breaking changes

4. **Security**
   - Review module code before publishing
   - Use least privilege for API tokens
   - Monitor access logs in Terraform Cloud
