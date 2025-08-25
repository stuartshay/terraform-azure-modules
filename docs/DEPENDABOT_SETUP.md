# Dependabot Configuration for Private Terraform Modules

This document explains how to configure Dependabot for automatic dependency updates in a private repository with Terraform Cloud integration.

## Overview

Dependabot is configured to automatically check for Terraform provider updates across all modules in this repository. Since this is a private repository that may reference private Terraform modules, additional configuration is required.

## Current Configuration

The `.github/dependabot.yml` file is configured to scan the following modules weekly:
- `modules/app-service-function`
- `modules/app-service-web`
- `modules/monitoring`
- `modules/networking`
- `modules/storage-account`

## Private Registry Access Setup

### 1. Dependabot Secrets Configuration

For Dependabot to access private Terraform modules from Terraform Cloud, you need to configure Dependabot secrets (separate from GitHub Actions secrets):

1. Go to your repository settings
2. Navigate to **Secrets and variables** → **Dependabot**
3. Add the following secrets:

| Secret Name | Description | Value |
|-------------|-------------|-------|
| `TF_API_TOKEN` | Terraform Cloud API token | Your Terraform Cloud API token |

### 2. Terraform Cloud API Token

To create a Terraform Cloud API token:

1. Log in to [Terraform Cloud](https://app.terraform.io/)
2. Go to **User Settings** → **Tokens**
3. Create a new API token with appropriate permissions
4. Copy the token and add it as a Dependabot secret

### 3. Registry Configuration (if using private modules)

If your modules reference other private modules from Terraform Cloud, you may need to add registry configuration to your Dependabot configuration:

```yaml
# Example addition to .github/dependabot.yml
version: 2
registries:
  terraform-cloud:
    type: terraform-registry
    url: https://app.terraform.io
    token: ${{secrets.TF_API_TOKEN}}

updates:
  - package-ecosystem: 'terraform'
    directory: '/modules/app-service-function'
    registries:
      - terraform-cloud
    # ... rest of configuration
```

## Module Versioning Strategy

### Local Development
For local development and testing, modules reference each other using relative paths:
```hcl
module "storage_account" {
  source = "../storage-account"
  # ... configuration
}
```

### Production Deployments
For production deployments, modules should reference published versions from Terraform Cloud:
```hcl
module "storage_account" {
  source  = "app.terraform.io/YOUR_ORG/storage-account/azure"
  version = "~> 1.0"
  # ... configuration
}
```

## Dependabot Behavior

### Update Schedule
- **Frequency**: Weekly (every Monday)
- **Pull Request Limit**: 5 open PRs per module
- **Assignee**: stuartshay
- **Labels**: `dependencies`, `terraform`

### Commit Messages
Dependabot will create commits with the format:
```
chore(scope): update terraform provider version
```

### Pull Request Management
- Dependabot will automatically create PRs for provider updates
- PRs will include detailed information about the changes
- You can configure auto-merge for minor updates if desired

## Troubleshooting

### Common Issues

1. **Authentication Errors**
   - Ensure `TF_API_TOKEN` is correctly set in Dependabot secrets
   - Verify the token has appropriate permissions in Terraform Cloud

2. **Module Not Found**
   - Check that the module is published to Terraform Cloud
   - Verify the module source URL is correct

3. **Version Constraints**
   - Ensure version constraints in modules allow for updates
   - Use `~>` for compatible updates, `>=` for minimum versions

### Debugging Steps

1. Check Dependabot logs in the repository's **Insights** → **Dependency graph** → **Dependabot**
2. Verify secrets are correctly configured
3. Test Terraform Cloud access manually with the API token

## Best Practices

1. **Version Pinning**: Use semantic versioning with appropriate constraints
2. **Testing**: Always test Dependabot PRs in a development environment
3. **Review**: Review provider updates for breaking changes
4. **Documentation**: Keep module documentation updated with version requirements

## Related Documentation

- [GitHub Dependabot Documentation](https://docs.github.com/en/code-security/supply-chain-security/keeping-your-dependencies-updated-automatically)
- [Terraform Cloud API Documentation](https://www.terraform.io/cloud-docs/api-docs)
- [Terraform Provider Versioning](https://www.terraform.io/language/providers/requirements#version-constraints)
