# complete

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.42.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_service_bus"></a> [service\_bus](#module\_service\_bus) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_log_analytics_workspace.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_private_dns_zone.servicebus](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.servicebus](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.private_endpoints](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_key_vault_id"></a> [key\_vault\_id](#output\_key\_vault\_id) | The ID of the Key Vault |
| <a name="output_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#output\_log\_analytics\_workspace\_id) | The ID of the Log Analytics workspace |
| <a name="output_private_dns_zone_id"></a> [private\_dns\_zone\_id](#output\_private\_dns\_zone\_id) | The ID of the private DNS zone |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group |
| <a name="output_service_bus_authorization_rules"></a> [service\_bus\_authorization\_rules](#output\_service\_bus\_authorization\_rules) | Map of created namespace authorization rules |
| <a name="output_service_bus_diagnostic_setting"></a> [service\_bus\_diagnostic\_setting](#output\_service\_bus\_diagnostic\_setting) | Diagnostic setting information |
| <a name="output_service_bus_key_vault_secrets"></a> [service\_bus\_key\_vault\_secrets](#output\_service\_bus\_key\_vault\_secrets) | Map of created Key Vault secrets |
| <a name="output_service_bus_namespace_endpoint"></a> [service\_bus\_namespace\_endpoint](#output\_service\_bus\_namespace\_endpoint) | The endpoint URL for the Service Bus namespace |
| <a name="output_service_bus_namespace_id"></a> [service\_bus\_namespace\_id](#output\_service\_bus\_namespace\_id) | The ID of the Service Bus namespace |
| <a name="output_service_bus_namespace_identity"></a> [service\_bus\_namespace\_identity](#output\_service\_bus\_namespace\_identity) | The managed identity of the Service Bus namespace |
| <a name="output_service_bus_namespace_name"></a> [service\_bus\_namespace\_name](#output\_service\_bus\_namespace\_name) | The name of the Service Bus namespace |
| <a name="output_service_bus_namespace_sku"></a> [service\_bus\_namespace\_sku](#output\_service\_bus\_namespace\_sku) | The SKU of the Service Bus namespace |
| <a name="output_service_bus_private_endpoint"></a> [service\_bus\_private\_endpoint](#output\_service\_bus\_private\_endpoint) | Private endpoint information |
| <a name="output_service_bus_private_endpoint_fqdn"></a> [service\_bus\_private\_endpoint\_fqdn](#output\_service\_bus\_private\_endpoint\_fqdn) | The FQDN of the private endpoint |
| <a name="output_service_bus_private_endpoint_ip"></a> [service\_bus\_private\_endpoint\_ip](#output\_service\_bus\_private\_endpoint\_ip) | The private IP address of the private endpoint |
| <a name="output_service_bus_queue_authorization_rules"></a> [service\_bus\_queue\_authorization\_rules](#output\_service\_bus\_queue\_authorization\_rules) | Map of created queue authorization rules |
| <a name="output_service_bus_queue_names"></a> [service\_bus\_queue\_names](#output\_service\_bus\_queue\_names) | Map of queue keys to their actual names |
| <a name="output_service_bus_queues"></a> [service\_bus\_queues](#output\_service\_bus\_queues) | Map of created Service Bus queues |
| <a name="output_service_bus_topic_authorization_rules"></a> [service\_bus\_topic\_authorization\_rules](#output\_service\_bus\_topic\_authorization\_rules) | Map of created topic authorization rules |
| <a name="output_service_bus_topic_names"></a> [service\_bus\_topic\_names](#output\_service\_bus\_topic\_names) | Map of topic keys to their actual names |
| <a name="output_service_bus_topic_subscriptions"></a> [service\_bus\_topic\_subscriptions](#output\_service\_bus\_topic\_subscriptions) | Map of created Service Bus topic subscriptions |
| <a name="output_service_bus_topics"></a> [service\_bus\_topics](#output\_service\_bus\_topics) | Map of created Service Bus topics |
| <a name="output_virtual_network_id"></a> [virtual\_network\_id](#output\_virtual\_network\_id) | The ID of the virtual network |
<!-- END_TF_DOCS -->
