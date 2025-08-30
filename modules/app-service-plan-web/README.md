# App Service Module - Web

This module creates Azure App Service resources including App Service Plan and Web App with VNET integration and restricted SKU options.

## Features

- **Restricted SKUs**: Only S1 and S2 SKUs are allowed for enhanced security and performance
- **VNET Integration**: App Service is deployed with VNET integration for network isolation
- **Security**: HTTPS-only, FTP disabled, HTTP/2 enabled
- **Performance**: Always-on enabled for better performance

## Usage


```hcl
module "app_service" {
  source = "app.terraform.io/azure-policy-cloud/app-service-plan-web/azurerm"

  resource_group_name = "rg-example"
  location           = "East US"
  environment        = "dev"
  workload           = "azurepolicy"
  subnet_id          = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/subnet-app-service"

  # SKU must be S1 or S2
  sku_name = "S1"

  tags = {
    Environment = "dev"
    Project     = "azurepolicy"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5 |
| azurerm | ~> 4.40 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 4.40 |

## Resources

| Name | Type |
|------|------|
| azurerm_service_plan.main | resource |
| azurerm_linux_web_app.main | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| resource_group_name | Name of the resource group | `string` | n/a | yes |
| location | Azure region | `string` | n/a | yes |
| environment | Environment name | `string` | n/a | yes |
| workload | Workload name | `string` | n/a | yes |
| sku_name | App Service Plan SKU (S1 or S2 only) | `string` | `"S1"` | no |
| subnet_id | Subnet ID for VNET integration | `string` | n/a | yes |
| python_version | Python version | `string` | `"3.13"` | no |
| app_settings | App settings | `map(string)` | `{}` | no |
| tags | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| app_service_id | ID of the App Service |
| app_service_name | Name of the App Service |
| app_service_default_hostname | Default hostname of the App Service |
| app_service_plan_id | ID of the App Service Plan |

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.40 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.40.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_app_service_virtual_network_swift_connection.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_virtual_network_swift_connection) | resource |
| [azurerm_linux_web_app.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_web_app) | resource |
| [azurerm_service_plan.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_settings"></a> [app\_settings](#input\_app\_settings) | App settings for the web app | `map(string)` | `{}` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The Azure region | `string` | n/a | yes |
| <a name="input_python_version"></a> [python\_version](#input\_python\_version) | The Python version | `string` | `"3.13"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group | `string` | n/a | yes |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | The SKU name for the App Service Plan (S1 or S2 only) | `string` | `"S1"` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The subnet ID for VNET integration | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resource | `map(string)` | `{}` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | The workload name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_service_default_hostname"></a> [app\_service\_default\_hostname](#output\_app\_service\_default\_hostname) | The default hostname of the App Service |
| <a name="output_app_service_id"></a> [app\_service\_id](#output\_app\_service\_id) | The ID of the App Service |
| <a name="output_app_service_name"></a> [app\_service\_name](#output\_app\_service\_name) | The name of the App Service |
| <a name="output_app_service_plan_id"></a> [app\_service\_plan\_id](#output\_app\_service\_plan\_id) | The ID of the App Service Plan |
<!-- END_TF_DOCS -->
