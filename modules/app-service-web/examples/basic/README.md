# Basic App Service Example

This example demonstrates the minimal configuration required for the app-service-web module.

## Features

This example creates:
- App Service Plan with B1 SKU (Basic tier)
- Linux Web App with Python 3.13
- HTTPS only enabled for security
- Always on enabled for better performance
- HTTP/2 enabled for latest version
- FTP disabled for security

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which cost money. Run `terraform destroy` when you don't need these resources.

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
<!-- END_TF_DOCS -->
