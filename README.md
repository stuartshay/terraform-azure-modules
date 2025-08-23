# Terraform Azure Modules

[![Pre-commit](https://github.com/stuartshay/terraform-azure-modules/actions/workflows/pre-commit.yml/badge.svg)](https://github.com/stuartshay/terraform-azure-modules/actions/workflows/pre-commit.yml)

[![Deploy to Terraform Cloud](https://github.com/stuartshay/terraform-azure-modules/actions/workflows/terraform-cloud-deploy.yml/badge.svg)](https://github.com/stuartshay/terraform-azure-modules/actions/workflows/terraform-cloud-deploy.yml)

A collection of reusable Terraform modules for Azure infrastructure components.

## Available Modules

### App Service Module - Web

Azure App Service resources including App Service Plan and Web App with VNET integration and restricted SKU options.

- **Path**: `modules/app-service-web`
- **Provider**: `azurerm`
- **Version**: `>= 4.40`

#### Features

- **Restricted SKUs**: Only S1 and S2 SKUs allowed for enhanced security and performance
- **VNET Integration**: App Service deployed with VNET integration for network isolation
- **Security**: HTTPS-only, FTP disabled, HTTP/2 enabled
- **Performance**: Always-on enabled for better performance
- Linux Web App with Python runtime
- Configurable app settings
- Resource tagging support

#### Quick Start

```hcl
module "app_service" {
  source  = "app.terraform.io/azure-policy-cloud/app-service-web/azurerm"
  version = "1.0.0"

  resource_group_name = "rg-example"
  location           = "East US"
  environment        = "dev"
  workload           = "myapp"
  subnet_id          = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/subnet-app-service"

  # SKU must be S1 or S2
  sku_name = "S1"

  tags = {
    Environment = "dev"
    Project     = "example"
  }
}
```

### App Service Module - Function

Azure Function App resources including Storage Account, App Service Plan, and Function App with VNET integration and restricted SKU options.

- **Path**: `modules/app-service-function`
- **Provider**: `azurerm`
- **Version**: `>= 4.40`

#### Features

- **Restricted SKUs**: Only Y1 (Consumption) and EP1 (Elastic Premium) SKUs allowed for cost control and performance
- **VNET Integration**: Function App deployed with VNET integration for network isolation
- **Security**: HTTPS-only, secure storage account configuration, network isolation
- **Performance**: Configurable scaling with always-ready instances for EP1
- **Monitoring**: Optional Application Insights integration
- **Storage**: Dedicated storage account with security configurations
- Linux Function App with Python runtime
- Configurable app settings
- Resource tagging support

#### Quick Start

```hcl
module "function_app" {
  source  = "app.terraform.io/azure-policy-cloud/app-service-function/azurerm"
  version = "1.0.0"

  resource_group_name = "rg-example"
  location           = "East US"
  environment        = "dev"
  workload           = "myapp"
  subnet_id          = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/subnet-functions"

  # SKU must be Y1 or EP1
  sku_name = "EP1"

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
- **Module selection** (app-service-web, app-service-function, or monitoring)
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
3. Select module (app-service-web, app-service-function, or monitoring)
4. Optionally adjust major/minor version (defaults to 1.0)
5. Choose dry run for testing or uncheck to publish

**Auto-Versioning**: Versions are automatically generated based on the branch:
- **Master/Main branch**: `{major}.{minor}.{github_run_id}` (e.g., `1.1.5`)
- **Other branches**: `{major}.{minor}.{github_run_id}-beta` (e.g., `1.1.5-beta`)

This ensures unique versions every time while clearly distinguishing production releases from development/beta versions.

For detailed instructions, see [Terraform Cloud Deployment Guide](docs/TERRAFORM_CLOUD_DEPLOYMENT.md).

### Published Modules

Once deployed, modules are available at:

```hcl
module "app_service" {
  source  = "app.terraform.io/azure-policy-cloud/app-service-web/azurerm"
  version = "1.0.0"
  # configuration...
}

module "function_app" {
  source  = "app.terraform.io/azure-policy-cloud/app-service-function/azurerm"
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

This repository uses semantic versioning with branch-specific formatting to distinguish between production and development releases.

### Version Format

- **Production (master/main branch)**: `MAJOR.MINOR.PATCH` (e.g., `1.1.5`)
- **Development (other branches)**: `MAJOR.MINOR.PATCH-beta` (e.g., `1.1.5-beta`)

### How It Works

1. **Major/Minor versions** are manually specified when running the deployment workflow (defaults to 1.1)
2. **Patch version** is automatically generated using the GitHub run number, ensuring uniqueness
3. **Branch detection** automatically applies the appropriate format:
   - Master/main branches produce stable versions for production use
   - All other branches (develop, feature branches, etc.) produce beta versions

### Git Tags

Each successful deployment creates a Git tag in the format: `{module-name}-v{version}`

Examples:
- `app-service-web-v1.1.5` (production release from master)
- `monitoring-v1.1.5-beta` (beta release from develop branch)

### Usage Examples

**Production version (from master branch):**
```hcl
module "app_service" {
  source  = "app.terraform.io/your-org/app-service-web/azurerm"
  version = "1.1.5"  # Stable production release
}
```

**Beta version (from develop branch):**
```hcl
module "app_service" {
  source  = "app.terraform.io/your-org/app-service-web/azurerm"
  version = "1.1.5-beta"  # Pre-release for testing
}
```

This approach ensures clear separation between stable production releases and development versions while maintaining semantic versioning compliance.

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Support

For issues and questions:

1. Check the module documentation
2. Review the examples
3. Open an issue in this repository

---

**Note**: These modules are designed for Azure infrastructure and require appropriate Azure subscriptions and permissions.
