# Azure App Service Function Module

This Terraform module creates an Azure Function App with associated resources including Storage Account, App Service Plan, and optional Application Insights. The module is designed for production use with security best practices and VNET integration.

## Features

- **Restricted SKUs**: Only EP1, EP2, and EP3 (Elastic Premium) SKUs allowed for consistent performance and security
- **VNET Integration**: Function App deployed with VNET integration for network isolation
- **Security**: HTTPS-only, secure storage account configuration, network isolation
- **Performance**: Configurable scaling with always-ready instances for Elastic Premium
- **Monitoring**: Optional Application Insights integration
- **Storage**: Dedicated storage account with security configurations
- Linux Function App with Python runtime
- Configurable app settings
- Resource tagging support

#### Quick Start

```hcl
module "app-service-function" {
  source  = "app.terraform.io/azure-policy-cloud/app-service-function/azurerm"
  version = "1.0.0"

  resource_group_name = "rg-example"
  location           = "East US"
  environment        = "dev"
  workload           = "myapp"
  subnet_id          = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/subnet-functions"

  # SKU must be EP1, EP2, or EP3
  sku_name = "EP1"

  tags = {
    Environment = "dev"
    Project     = "example"
  }
}
```

## Usage

### Basic Example

```hcl
module "app-service-function" {
  source = "app.terraform.io/azure-policy-cloud/app-service-function/azurerm"
  version = "1.0.0"

  # Required variables
  resource_group_name = "rg-example"
  location           = "East US"
  workload           = "myapp"
  environment        = "dev"
  subnet_id          = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/subnet-functions"

  # SKU must be EP1, EP2, or EP3
  sku_name = "EP1"

  tags = {
    Environment = "dev"
    Project     = "example"
  }
}
```

### Complete Example with All Options

```hcl
module "app-service-function" {
  source = "app.terraform.io/azure-policy-cloud/app-service-function/azurerm"
  version = "1.0.0"

  # Required variables
  resource_group_name = "rg-example"
  location           = "East US"
  workload           = "myapp"
  environment        = "prod"
  subnet_id          = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/subnet-functions"

  # Performance configuration
  sku_name                     = "EP2"
  python_version               = "3.11"
  always_ready_instances       = 2
  maximum_elastic_worker_count = 10

  # Monitoring
  enable_application_insights = true

  # Custom app settings
  function_app_settings = {
    "ENVIRONMENT"                 = "prod"
    "FUNCTIONS_EXTENSION_VERSION" = "~4"
    "WEBSITE_RUN_FROM_PACKAGE"    = "1"
    "DATABASE_URL"                = "your-database-connection-string"
    "API_BASE_URL"                = "https://api.example.com"
    "LOG_LEVEL"                   = "INFO"
  }

  tags = {
    Environment = "prod"
    Project     = "example"
    Tier        = "Premium"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5 |
| azurerm | >= 4.40 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 4.40 |

## Resources

| Name | Type |
|------|------|
| [azurerm_storage_account.functions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_service_plan.functions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |
| [azurerm_linux_function_app.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app) | resource |
| [azurerm_app_service_virtual_network_swift_connection.functions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_virtual_network_swift_connection) | resource |
| [azurerm_application_insights.functions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| workload | The workload name | `string` | n/a | yes |
| environment | The environment name | `string` | n/a | yes |
| resource_group_name | The name of the resource group | `string` | n/a | yes |
| location | The Azure region | `string` | n/a | yes |
| subnet_id | The subnet ID for VNET integration | `string` | n/a | yes |
| sku_name | The SKU name for the App Service Plan (EP1, EP2, or EP3 for Elastic Premium) | `string` | `"EP1"` | no |
| python_version | The Python version | `string` | `"3.13"` | no |
| function_app_settings | Additional app settings for the Function App | `map(string)` | `{}` | no |
| enable_application_insights | Enable Application Insights for the Function App | `bool` | `true` | no |
| always_ready_instances | Number of always ready instances for Elastic Premium SKUs | `number` | `1` | no |
| maximum_elastic_worker_count | Maximum number of elastic workers for Elastic Premium SKUs | `number` | `3` | no |
| tags | A map of tags to assign to the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| function_app_id | The ID of the Function App |
| function_app_name | The name of the Function App |
| function_app_default_hostname | The default hostname of the Function App |
| app_service_plan_id | The ID of the App Service Plan |
| storage_account_name | The name of the Functions storage account |
| storage_account_id | The ID of the Functions storage account |
| application_insights_connection_string | Application Insights connection string |
| application_insights_instrumentation_key | Application Insights instrumentation key |
| application_insights_id | The ID of Application Insights |

## Examples

- [Basic](examples/basic/) - Minimal configuration for getting started
- [Complete](examples/complete/) - Full configuration with all features enabled

## SKU Options

This module restricts SKU options to Elastic Premium tiers only to ensure consistent performance and security:

### EP1 (Elastic Premium - Small)
- **Use Case**: Production workloads, development with production-like performance
- **vCPU**: 1 vCPU
- **Memory**: 3.5 GB RAM  
- **Billing**: Pre-warmed instances + additional scaling
- **Scaling**: Configurable pre-warmed instances with elastic scaling
- **Benefits**: No cold start, VNET integration, unlimited execution time

### EP2 (Elastic Premium - Medium)
- **Use Case**: Production workloads with higher compute requirements
- **vCPU**: 2 vCPU
- **Memory**: 7 GB RAM
- **Billing**: Pre-warmed instances + additional scaling
- **Scaling**: Configurable pre-warmed instances with elastic scaling
- **Benefits**: No cold start, VNET integration, unlimited execution time

### EP3 (Elastic Premium - Large)
- **Use Case**: Production workloads with intensive compute requirements
- **vCPU**: 4 vCPU
- **Memory**: 14 GB RAM
- **Billing**: Pre-warmed instances + additional scaling
- **Scaling**: Configurable pre-warmed instances with elastic scaling
- **Benefits**: No cold start, VNET integration, unlimited execution time

## Security Features

- **HTTPS Only**: All traffic forced to HTTPS
- **VNET Integration**: Required for network isolation
- **Storage Security**: Minimum TLS 1.2, disabled public blob access
- **Network Access**: Public network access disabled (VNET only)
- **SAS Policy**: 1-day expiration for storage access

## Monitoring

When `enable_application_insights` is true (default), the module creates:
- Application Insights workspace
- Automatic connection to Function App
- Performance and availability monitoring
- Custom telemetry support

## Naming Conventions

Resources are named using the pattern: `{resource-type}-{workload}-{component}-{environment}-001`

Examples:
- Storage Account: `stfuncmyappdev001`
- App Service Plan: `asp-myapp-functions-dev-001`
- Function App: `func-myapp-dev-001`
- Application Insights: `appi-myapp-functions-dev-001`

## Network Requirements

The Function App requires a dedicated subnet with delegation to `Microsoft.Web/serverFarms`. The subnet should have sufficient IP addresses for scaling requirements.

Example subnet configuration:
```hcl
resource "azurerm_subnet" "functions" {
  name                 = "subnet-functions"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "function-delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Ensure all tests pass
5. Submit a pull request

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](../../LICENSE) file for details.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.40 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.41.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_app_service_virtual_network_swift_connection.functions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_virtual_network_swift_connection) | resource |
| [azurerm_application_insights.functions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights) | resource |
| [azurerm_linux_function_app.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app) | resource |
| [azurerm_service_plan.functions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |
| [azurerm_storage_account.functions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_always_ready_instances"></a> [always\_ready\_instances](#input\_always\_ready\_instances) | Number of always ready instances for Elastic Premium SKUs | `number` | `1` | no |
| <a name="input_enable_application_insights"></a> [enable\_application\_insights](#input\_enable\_application\_insights) | Enable Application Insights for the Function App | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name | `string` | n/a | yes |
| <a name="input_function_app_settings"></a> [function\_app\_settings](#input\_function\_app\_settings) | Additional app settings for the Function App | `map(string)` | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region | `string` | n/a | yes |
| <a name="input_maximum_elastic_worker_count"></a> [maximum\_elastic\_worker\_count](#input\_maximum\_elastic\_worker\_count) | Maximum number of elastic workers for Elastic Premium SKUs | `number` | `3` | no |
| <a name="input_python_version"></a> [python\_version](#input\_python\_version) | The Python version | `string` | `"3.13"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | The SKU name for the App Service Plan (EP1, EP2, or EP3 for Elastic Premium) | `string` | `"EP1"` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The subnet ID for VNET integration | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resource | `map(string)` | `{}` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | The workload name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_service_plan_id"></a> [app\_service\_plan\_id](#output\_app\_service\_plan\_id) | The ID of the App Service Plan |
| <a name="output_application_insights_connection_string"></a> [application\_insights\_connection\_string](#output\_application\_insights\_connection\_string) | Application Insights connection string |
| <a name="output_application_insights_id"></a> [application\_insights\_id](#output\_application\_insights\_id) | The ID of Application Insights |
| <a name="output_application_insights_instrumentation_key"></a> [application\_insights\_instrumentation\_key](#output\_application\_insights\_instrumentation\_key) | Application Insights instrumentation key |
| <a name="output_function_app_default_hostname"></a> [function\_app\_default\_hostname](#output\_function\_app\_default\_hostname) | The default hostname of the Function App |
| <a name="output_function_app_id"></a> [function\_app\_id](#output\_function\_app\_id) | The ID of the Function App |
| <a name="output_function_app_name"></a> [function\_app\_name](#output\_function\_app\_name) | The name of the Function App |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | The ID of the Functions storage account |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | The name of the Functions storage account |
<!-- END_TF_DOCS -->
