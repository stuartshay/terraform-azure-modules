# basic

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_service_bus"></a> [service\_bus](#module\_service\_bus) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_service_bus_namespace_connection_string"></a> [service\_bus\_namespace\_connection\_string](#output\_service\_bus\_namespace\_connection\_string) | The primary connection string for the Service Bus namespace |
| <a name="output_service_bus_namespace_endpoint"></a> [service\_bus\_namespace\_endpoint](#output\_service\_bus\_namespace\_endpoint) | The endpoint URL for the Service Bus namespace |
| <a name="output_service_bus_namespace_id"></a> [service\_bus\_namespace\_id](#output\_service\_bus\_namespace\_id) | The ID of the Service Bus namespace |
| <a name="output_service_bus_namespace_name"></a> [service\_bus\_namespace\_name](#output\_service\_bus\_namespace\_name) | The name of the Service Bus namespace |
| <a name="output_service_bus_namespace_sku"></a> [service\_bus\_namespace\_sku](#output\_service\_bus\_namespace\_sku) | The SKU of the Service Bus namespace |
<!-- END_TF_DOCS -->
