# Azure App Service Plan for Functions Module

This Terraform module creates an Azure App Service Plan specifically designed for Function Apps. This is a decoupled module that creates only the App Service Plan, allowing you to manage Function Apps separately for greater flexibility and cost optimization.

## Features

- **Restricted SKUs**: Only EP1, EP2, and EP3 (Elastic Premium) SKUs allowed - these are the approved SKUs for production use
- **Cross-Platform Support**: Supports both Linux and Windows operating systems
- **Elastic Premium Benefits**: Pre-warmed instances, unlimited execution time, VNET integration support
- **Cost Optimization**: One App Service Plan can host multiple Function Apps
- **Flexible Scaling**: Configurable maximum elastic worker count
- **Resource Tagging**: Full support for Azure resource tags

## ⚠️ Important: Approved SKUs Only

**This module is restricted to EP1, EP2, and EP3 (Elastic Premium) SKUs only.** These are the approved SKUs for production Function App workloads and provide:

- No cold start delays
- Predictable performance
- VNET integration capabilities
- Unlimited execution time
- Pre-warmed instances

## Quick Start

```hcl
module "function_app_service_plan" {
  source  = "app.terraform.io/azure-policy-cloud/app-service-plan-function/azurerm"
  version = "1.0.0"

  resource_group_name = "rg-example"
  location           = "East US"
  environment        = "dev"
  workload           = "myapp"

  # Only EP1, EP2, or EP3 are allowed
  sku_name = "EP1"
  os_type  = "Linux"  # or "Windows"

  tags = {
    Environment = "dev"
    Project     = "example"
  }
}
```

## Usage

### Basic Linux Example

```hcl
module "function_app_service_plan" {
  source = "app.terraform.io/azure-policy-cloud/app-service-plan-function/azurerm"
  version = "1.0.0"

  # Required variables
  resource_group_name = "rg-example"
  location           = "East US"
  workload           = "myapp"
  environment        = "dev"

  # Configuration
  sku_name = "EP1"
  os_type  = "Linux"

  tags = {
    Environment = "dev"
    Project     = "example"
  }
}
```

### Windows Example with Scaling Configuration

```hcl
module "function_app_service_plan" {
  source = "app.terraform.io/azure-policy-cloud/app-service-plan-function/azurerm"
  version = "1.0.0"

  # Required variables
  resource_group_name = "rg-example"
  location           = "East US"
  workload           = "myapp"
  environment        = "prod"
  
  # Configuration
  sku_name = "EP2"
  os_type  = "Windows"
  
  # Scaling configuration
  maximum_elastic_worker_count = 10

  tags = {
    Environment = "prod"
    Project     = "example"
    Tier        = "Premium"
  }
}
```

### Using the App Service Plan with Function Apps

After creating the App Service Plan, you can create Function Apps that use it:

```hcl
# Create the App Service Plan
module "function_app_service_plan" {
  source = "app.terraform.io/azure-policy-cloud/app-service-plan-function/azurerm"
  version = "1.0.0"

  resource_group_name = "rg-example"
  location           = "East US"
  workload           = "myapp"
  environment        = "dev"
  sku_name           = "EP1"
  os_type            = "Linux"

  tags = local.common_tags
}

# Create Function Apps using the plan
resource "azurerm_linux_function_app" "api" {
  name                = "func-myapp-api-dev-001"
  resource_group_name = "rg-example"
  location            = "East US"
  service_plan_id     = module.function_app_service_plan.app_service_plan_id

  storage_account_name       = azurerm_storage_account.functions.name
  storage_account_access_key = azurerm_storage_account.functions.primary_access_key

  site_config {
    application_stack {
      python_version = "3.11"
    }
  }

  tags = local.common_tags
}

resource "azurerm_linux_function_app" "worker" {
  name                = "func-myapp-worker-dev-001"
  resource_group_name = "rg-example"
  location            = "East US"
  service_plan_id     = module.function_app_service_plan.app_service_plan_id

  storage_account_name       = azurerm_storage_account.functions.name
  storage_account_access_key = azurerm_storage_account.functions.primary_access_key

  site_config {
    application_stack {
      python_version = "3.11"
    }
  }

  tags = local.common_tags
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
| [azurerm_service_plan.functions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| workload | The workload name | `string` | n/a | yes |
| environment | The environment name | `string` | n/a | yes |
| resource_group_name | The name of the resource group | `string` | n/a | yes |
| location | The Azure region | `string` | n/a | yes |
| subnet_id | The subnet ID for VNET integration (required for App Service Plan) | `string` | n/a | yes |
| os_type | The operating system type for the App Service Plan (Linux or Windows) | `string` | `"Linux"` | no |
| sku_name | The SKU name for the App Service Plan (EP1, EP2, or EP3 for Elastic Premium) | `string` | `"EP1"` | no |
| maximum_elastic_worker_count | Maximum number of elastic workers for Elastic Premium SKUs | `number` | `3` | no |
| tags | A map of tags to assign to the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| app_service_plan_id | The ID of the App Service Plan |
| app_service_plan_name | The name of the App Service Plan |
| app_service_plan_kind | The kind of App Service Plan |
| app_service_plan_sku | The SKU of the App Service Plan |
| app_service_plan_os_type | The operating system type of the App Service Plan |

## Examples

- [Basic](examples/basic/) - Minimal configuration for Linux App Service Plan
- [Complete](examples/complete/) - Full configuration with Windows and scaling options

## SKU Options (Approved Only)

This module restricts SKU options to Elastic Premium tiers only to ensure consistent performance and security:

### EP1 (Elastic Premium - Small) ⭐ Recommended for Development
- **Use Case**: Development, testing, small production workloads
- **vCPU**: 1 vCPU
- **Memory**: 3.5 GB RAM  
- **Benefits**: No cold start, VNET integration support, unlimited execution time

### EP2 (Elastic Premium - Medium) ⭐ Recommended for Production
- **Use Case**: Production workloads with moderate compute requirements
- **vCPU**: 2 vCPU
- **Memory**: 7 GB RAM
- **Benefits**: No cold start, VNET integration support, unlimited execution time

### EP3 (Elastic Premium - Large)
- **Use Case**: Production workloads with intensive compute requirements
- **vCPU**: 4 vCPU
- **Memory**: 14 GB RAM
- **Benefits**: No cold start, VNET integration support, unlimited execution time

## Operating System Support

### Linux (Default)
- Supports Python, Node.js, .NET, Java, PowerShell runtimes
- Generally lower cost
- Better performance for containerized workloads

### Windows
- Supports .NET Framework, PowerShell, Node.js, Python runtimes
- Required for .NET Framework applications
- Better integration with Windows-specific services

## Naming Conventions

The App Service Plan is named using the pattern: `asp-{workload}-functions-{environment}-001`

Example: `asp-myapp-functions-dev-001`

## Benefits of This Decoupled Approach

1. **Cost Optimization**: Multiple Function Apps can share the same App Service Plan
2. **Separation of Concerns**: Plan management is separate from Function App management
3. **Flexibility**: Different Function Apps can have different configurations while sharing compute resources
4. **Easier Scaling**: Scale the plan independently of individual Function Apps
5. **Resource Management**: Better control over compute resources and costs

## Migration from Previous Version

If you were using the previous version that created Function Apps directly, you'll need to:

1. Create storage accounts separately for your Function Apps
2. Create Application Insights separately if needed
3. Handle VNET integration at the Function App level
4. Update your Terraform configurations to use this plan with separate Function App resources

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
| [azurerm_service_plan.functions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The Azure region | `string` | n/a | yes |
| <a name="input_maximum_elastic_worker_count"></a> [maximum\_elastic\_worker\_count](#input\_maximum\_elastic\_worker\_count) | Maximum number of elastic workers for Elastic Premium SKUs | `number` | `3` | no |
| <a name="input_os_type"></a> [os\_type](#input\_os\_type) | The operating system type for the App Service Plan (Linux or Windows) | `string` | `"Linux"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | The SKU name for the App Service Plan (EP1, EP2, or EP3 for Elastic Premium) | `string` | `"EP1"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resource | `map(string)` | `{}` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | The workload name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_service_plan_id"></a> [app\_service\_plan\_id](#output\_app\_service\_plan\_id) | The ID of the App Service Plan |
| <a name="output_app_service_plan_kind"></a> [app\_service\_plan\_kind](#output\_app\_service\_plan\_kind) | The kind of App Service Plan |
| <a name="output_app_service_plan_name"></a> [app\_service\_plan\_name](#output\_app\_service\_plan\_name) | The name of the App Service Plan |
| <a name="output_app_service_plan_os_type"></a> [app\_service\_plan\_os\_type](#output\_app\_service\_plan\_os\_type) | The operating system type of the App Service Plan |
| <a name="output_app_service_plan_sku"></a> [app\_service\_plan\_sku](#output\_app\_service\_plan\_sku) | The SKU of the App Service Plan |
<!-- END_TF_DOCS -->
