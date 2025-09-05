# Complete App Service Example

This example demonstrates all available configuration options for the app-service-plan-web module.

## Features

This example creates:
- App Service Plan with P1v3 SKU (Premium v3 tier) for production workloads
- Linux Web App with Python 3.11
- HTTPS only enabled for security
- Always on enabled for better performance
- HTTP/2 enabled for latest version
- FTP disabled for security
- Comprehensive app settings for a production application
- Detailed tagging strategy for governance and cost management

## Configuration Highlights

- **Premium SKU**: Uses P1v3 for better performance and features
- **Custom Python Version**: Demonstrates version specification
- **Production App Settings**: Includes common settings for:
  - Application Insights integration
  - Database connections
  - Redis caching
  - Storage account integration
  - API configurations
  - Logging and worker settings
- **Comprehensive Tagging**: Shows enterprise-level tagging strategy

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which cost money (Premium tier). Run `terraform destroy` when you don't need these resources.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5 |
| azurerm | ~> 4.40 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 4.40 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| app_service | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| azurerm_resource_group.example | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| app_service_id | The ID of the App Service |
| app_service_name | The name of the App Service |
| app_service_default_hostname | The default hostname of the App Service |
| app_service_plan_id | The ID of the App Service Plan |
| app_service_url | The HTTPS URL of the App Service |

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.13.1 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.42.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.42.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_app_service"></a> [app\_service](#module\_app\_service) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.app_service](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_service_default_hostname"></a> [app\_service\_default\_hostname](#output\_app\_service\_default\_hostname) | The default hostname of the App Service |
| <a name="output_app_service_id"></a> [app\_service\_id](#output\_app\_service\_id) | The ID of the App Service |
| <a name="output_app_service_name"></a> [app\_service\_name](#output\_app\_service\_name) | The name of the App Service |
| <a name="output_app_service_plan_id"></a> [app\_service\_plan\_id](#output\_app\_service\_plan\_id) | The ID of the App Service Plan |
| <a name="output_app_service_url"></a> [app\_service\_url](#output\_app\_service\_url) | The HTTPS URL of the App Service |
<!-- END_TF_DOCS -->
