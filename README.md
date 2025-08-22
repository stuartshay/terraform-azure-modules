# Terraform Azure Modules

[![Pre-commit](https://github.com/stuartshay/terraform-azure-modules/actions/workflows/pre-commit.yml/badge.svg)](https://github.com/stuartshay/terraform-azure-modules/actions/workflows/pre-commit.yml)

[![Deploy to Terraform Cloud](https://github.com/stuartshay/terraform-azure-modules/actions/workflows/terraform-cloud-deploy.yml/badge.svg)](https://github.com/stuartshay/terraform-azure-modules/actions/workflows/terraform-cloud-deploy.yml)

A collection of reusable Terraform modules for Azure infrastructure components.

## Available Modules

### App Service Module

Azure App Service resources including App Service Plan and Web App with configurable settings.

- **Path**: `modules/app-service`
- **Provider**: `azurerm`
- **Version**: `>= 4.40`

#### Features

- App Service Plan with configurable SKU
- Linux Web App with Python runtime
- Configurable app settings
- Resource tagging support

#### Quick Start

```hcl
module "app_service" {
  source = "github.com/stuartshay/terraform-azure-modules//modules/app-service?ref=v0.1.0"

  resource_group_name = "rg-example"
  location           = "East US"
  environment        = "dev"
  workload           = "myapp"

  tags = {
    Environment = "dev"
    Project     = "example"
  }
}
```

### Monitoring Module

Comprehensive Azure monitoring solution including Log Analytics Workspace, Application Insights, alerts, and monitoring configurations.

- **Path**: `modules/monitoring`
- **Provider**: `azurerm`
- **Version**: `>= 4.40`

#### Features

- Log Analytics Workspace with configurable retention and quotas
- Application Insights with workspace-based configuration
- Action Groups for notifications (email, SMS, webhooks)
- Comprehensive alerting for performance, availability, and errors
- Optional private endpoints for secure connectivity
- VM Insights and data collection rules
- Storage monitoring capabilities
- Security Center and Update Management solutions
- Custom workbooks for dashboards

#### Quick Start

```hcl
module "monitoring" {
  source = "github.com/stuartshay/terraform-azure-modules//modules/monitoring?ref=v0.1.0"

  # Required variables
  resource_group_name = "rg-example"
  location           = "East US"
  workload           = "myapp"
  environment        = "dev"
  location_short     = "eastus"
  subscription_id    = "your-subscription-id"

  # Notification configuration
  notification_emails = {
    admin = "admin@example.com"
  }

  tags = {
    Environment = "dev"
    Project     = "example"
  }
}
```

## Usage

### Module Reference

To use a module from this repository, reference it using the GitHub source with a specific version tag:

```hcl
module "module_name" {
  source = "github.com/stuartshay/terraform-azure-modules//modules/MODULE_NAME?ref=VERSION"

  # Module configuration
}
```

### Examples

Each module includes comprehensive examples:

- **Basic**: Minimal configuration for getting started
- **Complete**: Full configuration with all features enabled

See the `examples/` directory in each module for detailed usage examples.

## Requirements

- Terraform >= 1.5
- Azure Provider >= 4.40
- Appropriate Azure permissions for resource creation

## Terraform Cloud Deployment

This repository includes automated deployment to Terraform Cloud private registry via GitHub Actions.

### Features

- **Manual deployment** via workflow dispatch
- **Module selection** (app-service or monitoring)
- **Version management** with semantic versioning
- **Dry run mode** for validation without publishing
- **Automated validation** and packaging

### Required GitHub Secrets

To enable Terraform Cloud deployment, configure these repository secrets:

- `TF_API_TOKEN`: Terraform Cloud API token
- `TF_CLOUD_ORGANIZATION`: Terraform Cloud organization name

### Usage

1. Go to **Actions** → **Deploy to Terraform Cloud**
2. Click **Run workflow**
3. Select module and version
4. Choose dry run for testing or uncheck to publish

For detailed instructions, see [Terraform Cloud Deployment Guide](docs/TERRAFORM_CLOUD_DEPLOYMENT.md).

### Published Modules

Once deployed, modules are available at:

```hcl
module "app_service" {
  source  = "app.terraform.io/azure-policy-cloud/app-service/azurerm"
  version = "1.0.0"
  # configuration...
}

module "monitoring" {
  source  = "app.terraform.io/azure-policy-cloud/monitoring/azurerm"
  version = "1.0.0"
  # configuration...
}
```

## CI/CD: Required Azure Secrets for Validation

To enable Terraform validation in GitHub Actions, the following repository secrets must be set:

- `AZURE_CLIENT_ID`: Service principal client ID
- `AZURE_TENANT_ID`: Azure tenant ID
- `AZURE_SUBSCRIPTION_ID`: Azure subscription ID
- `AZURE_CLIENT_SECRET`: Service principal client secret

These are used by the workflow to authenticate with Azure using the `azure/login` action. Without these, validation of modules and examples that require provider authentication will fail.

For more information, see the [Azure/login GitHub Action documentation](https://github.com/Azure/login#configure-a-service-principal-with-a-secret).

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Ensure all tests pass
5. Submit a pull request

## Versioning

This repository uses semantic versioning. Each release is tagged with a version number (e.g., `v0.1.0`).

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Support

For issues and questions:

1. Check the module documentation
2. Review the examples
3. Open an issue in this repository

---

**Note**: These modules are designed for Azure infrastructure and require appropriate Azure subscriptions and permissions.
