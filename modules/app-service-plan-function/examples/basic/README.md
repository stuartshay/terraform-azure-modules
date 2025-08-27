# Basic App Service Function Example

This example demonstrates the minimal configuration required to deploy an Azure App Service Plan for Functions using the `app-service-plan-function` module.

## What This Example Creates

- **Resource Group**: Container for all resources
- **Virtual Network**: Network isolation for the Function App
- **Subnet**: Dedicated subnet with delegation for Function Apps
- **Function App Module**: Complete Function App setup including:
  - Storage Account for Function App state
  - App Service Plan with EP1 SKU (Elastic Premium)
  - Linux Function App with Python 3.13 runtime
  - VNet integration for network isolation
  - Application Insights for monitoring
  - Security configurations (HTTPS-only, etc.)

## Usage

1. **Initialize Terraform**:
   ```bash
   terraform init
   ```

2. **Plan the deployment**:
   ```bash
   terraform plan
   ```

3. **Apply the configuration**:
   ```bash
   terraform apply
   ```

4. **Clean up resources**:
   ```bash
   terraform destroy
   ```

## Configuration

This example uses:
- **SKU**: EP1 (Elastic Premium) for production readiness
- **Python Version**: 3.13 (default)
- **Location**: East US
- **VNet Integration**: Enabled with dedicated subnet
- **Application Insights**: Enabled for monitoring

## Outputs

After deployment, you'll get:
- Function App name and hostname
- Storage account name
- App Service Plan ID

## Next Steps

- Deploy your Python functions to the created Function App
- Configure custom app settings if needed
- Set up CI/CD pipelines for function deployment
- Monitor your functions through Application Insights

For more advanced configurations, see the [complete example](../complete/).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.40 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.41.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_function_app_service_plan"></a> [function\_app\_service\_plan](#module\_function\_app\_service\_plan) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.functions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_service_plan_id"></a> [app\_service\_plan\_id](#output\_app\_service\_plan\_id) | The ID of the App Service Plan |
| <a name="output_app_service_plan_name"></a> [app\_service\_plan\_name](#output\_app\_service\_plan\_name) | The name of the App Service Plan |
| <a name="output_app_service_plan_os_type"></a> [app\_service\_plan\_os\_type](#output\_app\_service\_plan\_os\_type) | The operating system type of the App Service Plan |
| <a name="output_app_service_plan_sku"></a> [app\_service\_plan\_sku](#output\_app\_service\_plan\_sku) | The SKU of the App Service Plan |
<!-- END_TF_DOCS -->
