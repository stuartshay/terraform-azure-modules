# Basic Function App Example

This example demonstrates the minimal configuration required to deploy an Azure Function App using the function-app module.

## What This Example Creates

- **App Service Plan**: EP1 (Elastic Premium) plan for hosting the Function App
- **Function App**: Linux-based Function App with Python 3.11 runtime
- **Storage Account**: Dedicated storage account for the Function App
- **Application Insights**: Monitoring and telemetry for the Function App
- **Managed Identity**: System-assigned managed identity for secure access

## Features Demonstrated

- ✅ Minimal configuration with sensible defaults
- ✅ Python runtime configuration
- ✅ Basic app settings
- ✅ Automatic Application Insights integration
- ✅ System-assigned managed identity
- ✅ Secure HTTPS-only configuration

## Prerequisites

1. **Azure Subscription**: You need an active Azure subscription
2. **Resource Group**: An existing resource group where resources will be deployed
3. **Terraform**: Version >= 1.6
4. **Azure CLI**: For authentication (optional, can use other auth methods)

## Usage

### 1. Clone and Navigate

```bash
git clone <repository-url>
cd modules/function-app/examples/basic
```

### 2. Configure Variables

Create a `terraform.tfvars` file:

```hcl
workload            = "myapp"
environment         = "dev"
resource_group_name = "rg-myapp-dev-001"
```

### 3. Initialize and Deploy

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

### 4. Access Your Function App

After deployment, you can access your Function App at the URL provided in the outputs:

```bash
# Get the Function App URL
terraform output function_app_url
```

## Configuration

### Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| workload | The workload name | `string` | `"example"` | no |
| environment | The environment name | `string` | `"dev"` | no |
| resource_group_name | The name of the existing resource group | `string` | `"rg-example-dev-001"` | no |

### Outputs

| Name | Description |
|------|-------------|
| function_app_id | The ID of the Function App |
| function_app_name | The name of the Function App |
| function_app_default_hostname | The default hostname of the Function App |
| function_app_url | The URL of the Function App |
| storage_account_name | The name of the storage account |
| app_service_plan_id | The ID of the App Service Plan |
| app_service_plan_name | The name of the App Service Plan |
| application_insights_instrumentation_key | The Application Insights instrumentation key |
| function_app_principal_id | The principal ID of the Function App's managed identity |
| function_app_summary | Summary of the Function App deployment |

## Default Configuration

This example uses the following default settings:

- **OS Type**: Linux
- **Runtime**: Python 3.11
- **Functions Extension Version**: ~4
- **HTTPS Only**: Enabled
- **Always On**: Enabled (for EP1 plan)
- **Application Insights**: Enabled
- **Managed Identity**: System-assigned
- **TLS Version**: 1.2 minimum

## Customization

You can customize this example by modifying the module configuration in `main.tf`. For example:

### Change Runtime

```hcl
module "function_app" {
  source = "../../"

  # ... other configuration ...

  # Use Node.js instead of Python
  runtime_name    = "node"
  runtime_version = "18"
}
```

### Add Custom App Settings

```hcl
module "function_app" {
  source = "../../"

  # ... other configuration ...

  app_settings = {
    "ENVIRONMENT"     = var.environment
    "CUSTOM_SETTING"  = "my_value"
    "DEBUG_MODE"      = "false"
  }
}
```

### Enable VNet Integration

```hcl
# First, create or reference a subnet
data "azurerm_subnet" "functions" {
  name                 = "snet-functions"
  virtual_network_name = "vnet-example"
  resource_group_name  = var.resource_group_name
}

module "function_app" {
  source = "../../"

  # ... other configuration ...

  enable_vnet_integration    = true
  vnet_integration_subnet_id = data.azurerm_subnet.functions.id
}
```

## Next Steps

After deploying this basic example, you might want to:

1. **Deploy Function Code**: Use Azure Functions Core Tools or CI/CD pipelines to deploy your function code
2. **Configure Custom Domains**: Add custom domains and SSL certificates
3. **Set up Monitoring**: Configure alerts and dashboards in Application Insights
4. **Add Security**: Implement IP restrictions, authentication, or VNet integration
5. **Scale Configuration**: Adjust the App Service Plan SKU based on your needs

## Cleanup

To remove all resources created by this example:

```bash
terraform destroy
```

## Troubleshooting

### Common Issues

1. **Resource Group Not Found**: Ensure the resource group specified in `resource_group_name` exists
2. **Insufficient Permissions**: Ensure your Azure credentials have Contributor access to the resource group
3. **Name Conflicts**: If you get naming conflicts, try changing the `workload` variable

### Getting Help

- Check the [main module documentation](../../README.md)
- Review Azure Function App documentation
- Check Terraform Azure provider documentation

## Related Examples

- [Complete Example](../complete/) - Full-featured Function App with all options

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.40 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.40 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_app_service_plan"></a> [app\_service\_plan](#module\_app\_service\_plan) | app.terraform.io/azure-policy-cloud/app-service-plan-function/azurerm | 1.1.34 |
| <a name="module_function_app"></a> [function\_app](#module\_function\_app) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name | `string` | `"dev"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the existing resource group | `string` | `"rg-example-dev-001"` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | The workload name | `string` | `"example"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_service_plan_id"></a> [app\_service\_plan\_id](#output\_app\_service\_plan\_id) | The ID of the App Service Plan |
| <a name="output_app_service_plan_name"></a> [app\_service\_plan\_name](#output\_app\_service\_plan\_name) | The name of the App Service Plan |
| <a name="output_application_insights_instrumentation_key"></a> [application\_insights\_instrumentation\_key](#output\_application\_insights\_instrumentation\_key) | The Application Insights instrumentation key |
| <a name="output_function_app_default_hostname"></a> [function\_app\_default\_hostname](#output\_function\_app\_default\_hostname) | The default hostname of the Function App |
| <a name="output_function_app_id"></a> [function\_app\_id](#output\_function\_app\_id) | The ID of the Function App |
| <a name="output_function_app_name"></a> [function\_app\_name](#output\_function\_app\_name) | The name of the Function App |
| <a name="output_function_app_principal_id"></a> [function\_app\_principal\_id](#output\_function\_app\_principal\_id) | The principal ID of the Function App's managed identity |
| <a name="output_function_app_summary"></a> [function\_app\_summary](#output\_function\_app\_summary) | Summary of the Function App deployment |
| <a name="output_function_app_url"></a> [function\_app\_url](#output\_function\_app\_url) | The URL of the Function App |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | The name of the storage account |
<!-- END_TF_DOCS -->
