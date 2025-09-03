# Azure Service Bus Module

This Terraform module creates an Azure Service Bus namespace with configurable queues, topics, subscriptions, authorization rules, private endpoints, and Key Vault integration.

## Features

- **Service Bus Namespace**: Support for Basic, Standard, and Premium SKUs with proper validation
- **Queues and Topics**: Configurable queues and topics with all Azure Service Bus features
- **Topic Subscriptions**: Support for topic subscriptions with advanced configuration
- **Authorization Rules**: Namespace, queue, and topic-level authorization rules
- **Private Endpoint**: Optional private endpoint integration using the private-endpoint module
- **Key Vault Integration**: Optional storage of connection strings in Azure Key Vault
- **Security**: Configurable network access, TLS settings, and managed identity support
- **Monitoring**: Diagnostic settings integration with Log Analytics, Storage, and Event Hubs
- **Naming Convention**: Enforced naming convention: `sb-{workload}-{environment}-{location_short}-001`

## Usage

### Basic Example

```hcl
module "service_bus" {
  source = "path/to/modules/service-bus"

  # Required variables
  workload            = "myapp"
  environment         = "dev"
  location            = "East US"
  location_short      = "eastus"
  resource_group_name = "rg-myapp-dev"

  # Basic configuration
  sku = "Standard"

  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
```

### Complete Example with All Features

```hcl
module "service_bus" {
  source = "path/to/modules/service-bus"

  # Required variables
  workload            = "myapp"
  environment         = "prod"
  location            = "East US"
  location_short      = "eastus"
  resource_group_name = "rg-myapp-prod"

  # Service Bus configuration
  sku                     = "Premium"
  premium_messaging_units = 2

  # Network and security settings
  public_network_access_enabled = false
  minimum_tls_version           = "1.2"
  local_auth_enabled            = true

  # Identity configuration
  identity_type = "SystemAssigned"

  # Queues configuration
  queues = {
    "order-processing" = {
      max_size_in_megabytes                   = 2048
      default_message_ttl                     = "P7D"
      duplicate_detection_history_time_window = "PT30M"
      enable_partitioning                     = true
      requires_duplicate_detection            = true
      max_delivery_count                      = 5
    }
    "notifications" = {
      max_size_in_megabytes = 1024
      default_message_ttl   = "P3D"
      max_delivery_count    = 3
      requires_session      = true
    }
  }

  # Topics configuration
  topics = {
    "events" = {
      max_size_in_megabytes                   = 4096
      default_message_ttl                     = "P14D"
      duplicate_detection_history_time_window = "PT1H"
      enable_partitioning                     = true
      requires_duplicate_detection            = true
      support_ordering                        = true
    }
  }

  # Topic subscriptions
  topic_subscriptions = {
    "events-all" = {
      name                                       = "all-events"
      topic_name                                 = "events"
      max_delivery_count                         = 10
      default_message_ttl                        = "P7D"
      dead_lettering_on_filter_evaluation_error = true
      dead_lettering_on_message_expiration       = true
    }
  }

  # Authorization rules
  authorization_rules = {
    "app-access" = {
      listen = true
      send   = true
      manage = false
    }
    "read-only" = {
      listen = true
      send   = false
      manage = false
    }
  }

  # Private endpoint configuration
  enable_private_endpoint    = true
  private_endpoint_subnet_id = azurerm_subnet.private_endpoints.id
  private_dns_zone_ids       = [azurerm_private_dns_zone.servicebus.id]

  # Key Vault integration
  enable_key_vault_integration = true
  key_vault_id                 = azurerm_key_vault.main.id
  key_vault_secrets = {
    "app-connection" = {
      secret_name    = "servicebus-app-connection-string"
      auth_rule_name = "app-access"
      auth_rule_type = "namespace"
    }
  }

  # Diagnostic settings
  enable_diagnostic_settings = true
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  tags = {
    Environment = "prod"
    ManagedBy   = "terraform"
    Project     = "myapp"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.42.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.42.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_private_endpoint"></a> [private\_endpoint](#module\_private\_endpoint) | ../private-endpoint | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault_secret.connection_strings](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_monitor_diagnostic_setting.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_servicebus_namespace.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace) | resource |
| [azurerm_servicebus_namespace_authorization_rule.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace_authorization_rule) | resource |
| [azurerm_servicebus_queue.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_queue) | resource |
| [azurerm_servicebus_queue_authorization_rule.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_queue_authorization_rule) | resource |
| [azurerm_servicebus_subscription.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_subscription) | resource |
| [azurerm_servicebus_topic.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_topic) | resource |
| [azurerm_servicebus_topic_authorization_rule.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_topic_authorization_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_workload"></a> [workload](#input\_workload) | The workload name for naming convention | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name for naming convention | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where resources will be created | `string` | n/a | yes |
| <a name="input_location_short"></a> [location\_short](#input\_location\_short) | The short name for the Azure region (e.g., 'eastus', 'westus2') | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group where the Service Bus will be created | `string` | n/a | yes |
| <a name="input_sku"></a> [sku](#input\_sku) | The SKU of the Service Bus namespace | `string` | `"Standard"` | no |
| <a name="input_premium_messaging_units"></a> [premium\_messaging\_units](#input\_premium\_messaging\_units) | The number of messaging units for Premium SKU (1, 2, 4, 8, or 16) | `number` | `1` | no |
| <a name="input_premium_messaging_partitions"></a> [premium\_messaging\_partitions](#input\_premium\_messaging\_partitions) | The number of messaging partitions for Premium SKU (1, 2, or 4) | `number` | `1` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether public network access is enabled for the Service Bus namespace | `bool` | `true` | no |
| <a name="input_minimum_tls_version"></a> [minimum\_tls\_version](#input\_minimum\_tls\_version) | The minimum TLS version for the Service Bus namespace | `string` | `"1.2"` | no |
| <a name="input_local_auth_enabled"></a> [local\_auth\_enabled](#input\_local\_auth\_enabled) | Whether local authentication is enabled for the Service Bus namespace | `bool` | `true` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | The type of managed identity for the Service Bus namespace | `string` | `null` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | List of user assigned identity IDs | `list(string)` | `null` | no |
| <a name="input_customer_managed_key"></a> [customer\_managed\_key](#input\_customer\_managed\_key) | Customer managed key configuration for Premium SKU | <pre>object({<br>    key_vault_key_id                  = string<br>    identity_id                       = string<br>    infrastructure_encryption_enabled = optional(bool, false)<br>  })</pre> | `null` | no |
| <a name="input_network_rule_set"></a> [network\_rule\_set](#input\_network\_rule\_set) | Network rule set configuration | <pre>object({<br>    default_action                = string<br>    public_network_access_enabled = optional(bool, true)<br>    trusted_services_allowed      = optional(bool, false)<br>    network_rules = optional(list(object({<br>      subnet_id                            = string<br>      ignore_missing_vnet_service_endpoint = optional(bool, false)<br>    })), [])<br>    ip_rules = optional(list(object({<br>      ip_mask = string<br>      action  = optional(string, "Allow")<br>    })), [])<br>  })</pre> | `null` | no |
| <a name="input_queues"></a> [queues](#input\_queues) | Map of Service Bus queues to create | <pre>map(object({<br>    custom_name                             = optional(string)<br>    auto_delete_on_idle                     = optional(string, "P10675199DT2H48M5.4775807S")<br>    dead_lettering_on_message_expiration    = optional(bool, false)<br>    default_message_ttl                     = optional(string, "P14D")<br>    duplicate_detection_history_time_window = optional(string, "PT10M")<br>    enable_express                          = optional(bool, false)<br>    enable_partitioning                     = optional(bool, false)<br>    forward_dead_lettered_messages_to       = optional(string)<br>    forward_to                              = optional(string)<br>    lock_duration                           = optional(string, "PT1M")<br>    max_delivery_count                      = optional(number, 10)<br>    max_message_size_in_kilobytes           = optional(number)<br>    max_size_in_megabytes                   = optional(number, 1024)<br>    requires_duplicate_detection            = optional(bool, false)<br>    requires_session                        = optional(bool, false)<br>    status                                  = optional(string, "Active")<br>  }))</pre> | `{}` | no |
| <a name="input_topics"></a> [topics](#input\_topics) | Map of Service Bus topics to create | <pre>map(object({<br>    custom_name                             = optional(string)<br>    auto_delete_on_idle                     = optional(string, "P10675199DT2H48M5.4775807S")<br>    default_message_ttl                     = optional(string, "P14D")<br>    duplicate_detection_history_time_window = optional(string, "PT10M")<br>    enable_express                          = optional(bool, false)<br>    enable_partitioning                     = optional(bool, false)<br>    max_message_size_in_kilobytes           = optional(number)<br>    max_size_in_megabytes                   = optional(number, 1024)<br>    requires_duplicate_detection            = optional(bool, false)<br>    status                                  = optional(string, "Active")<br>    support_ordering                        = optional(bool, false)<br>  }))</pre> | `{}` | no |
| <a name="input_topic_subscriptions"></a> [topic\_subscriptions](#input\_topic\_subscriptions) | Map of Service Bus topic subscriptions to create | <pre>map(object({<br>    name                                       = string<br>    topic_name                                 = string<br>    custom_name                                = optional(string)<br>    auto_delete_on_idle                        = optional(string, "P10675199DT2H48M5.4775807S")<br>    dead_lettering_on_filter_evaluation_error = optional(bool, true)<br>    dead_lettering_on_message_expiration       = optional(bool, false)<br>    default_message_ttl                        = optional(string, "P14D")<br>    enable_batched_operations                  = optional(bool, true)<br>    forward_dead_lettered_messages_to          = optional(string)<br>    forward_to                                 = optional(string)<br>    lock_duration                              = optional(string, "PT1M")<br>    max_delivery_count                         = optional(number, 10)<br>    requires_session                           = optional(bool, false)<br>    status                                     = optional(string, "Active")<br>    client_scoped_subscription_enabled         = optional(bool, false)<br>    client_scoped_subscription = optional(object({<br>      client_id    = string<br>      is_shareable = optional(bool, false)<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_authorization_rules"></a> [authorization\_rules](#input\_authorization\_rules) | Map of namespace-level authorization rules to create | <pre>map(object({<br>    custom_name = optional(string)<br>    listen      = optional(bool, false)<br>    send        = optional(bool, false)<br>    manage      = optional(bool, false)<br>  }))</pre> | `{}` | no |
| <a name="input_queue_authorization_rules"></a> [queue\_authorization\_rules](#input\_queue\_authorization\_rules) | Map of queue-level authorization rules to create | <pre>map(object({<br>    name       = string<br>    queue_name = string<br>    listen     = optional(bool, false)<br>    send       = optional(bool, false)<br>    manage     = optional(bool, false)<br>  }))</pre> | `{}` | no |
| <a name="input_topic_authorization_rules"></a> [topic\_authorization\_rules](#input\_topic\_authorization\_rules) | Map of topic-level authorization rules to create | <pre>map(object({<br>    name       = string<br>    topic_name = string<br>    listen     = optional(bool, false)<br>    send       = optional(bool, false)<br>    manage     = optional(bool, false)<br>  }))</pre> | `{}` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | Whether to create a private endpoint for the Service Bus namespace | `bool` | `false` | no |
| <a name="input_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#input\_private\_endpoint\_subnet\_id) | The subnet ID where the private endpoint will be created | `string` | `null` | no |
| <a name="input_private_dns_zone_ids"></a> [private\_dns\_zone\_ids](#input\_private\_dns\_zone\_ids) | List of private DNS zone IDs for the private endpoint | `list(string)` | `null` | no |
| <a name="input_private_service_connection_name"></a> [private\_service\_connection\_name](#input\_private\_service\_connection\_name) | Custom name for the private service connection | `string` | `null` | no |
| <a name="input_private_dns_zone_group_name"></a> [private\_dns\_zone\_group\_name](#input\_private\_dns\_zone\_group\_name) | Custom name for the private DNS zone group | `string` | `null` | no |
| <a name="input_enable_key_vault_integration"></a> [enable\_key\_vault\_integration](#input\_enable\_key\_vault\_integration) | Whether to store connection strings in Key Vault | `bool` | `false` | no |
| <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id) | The ID of the Key Vault where connection strings will be stored | `string` | `null` | no |
| <a name="input_key_vault_secrets"></a> [key\_vault\_secrets](#input\_key\_vault\_secrets) | Map of Key Vault secrets to create for connection strings | <pre>map(object({<br>    secret_name     = string<br>    auth_rule_name  = string<br>    auth_rule_type  = string # "namespace", "queue", or "topic"<br>    expiration_date = optional(string)<br>  }))</pre> | `{}` | no |
| <a name="input_enable_diagnostic_settings"></a> [enable\_diagnostic\_settings](#input\_enable\_diagnostic\_settings) | Whether to enable diagnostic settings for the Service Bus namespace | `bool` | `false` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | The ID of the Log Analytics workspace for diagnostic settings | `string` | `null` | no |
| <a name="input_diagnostic_storage_account_id"></a> [diagnostic\_storage\_account\_id](#input\_diagnostic\_storage\_account\_id) | The ID of the storage account for diagnostic settings | `string` | `null` | no |
| <a name="input_eventhub_authorization_rule_id"></a> [eventhub\_authorization\_rule\_id](#input\_eventhub\_authorization\_rule\_id) | The ID of the Event Hub authorization rule for diagnostic settings | `string` | `null` | no |
| <a name="input_eventhub_name"></a> [eventhub\_name](#input\_eventhub\_name) | The name of the Event Hub for diagnostic settings | `string` | `null` | no |
| <a name="input_diagnostic_log_categories"></a> [diagnostic\_log\_categories](#input\_diagnostic\_log\_categories) | List of log categories to enable for diagnostic settings | `list(string)` | <pre>[<br>  "OperationalLogs",<br>  "VNetAndIPFilteringLogs",<br>  "RuntimeAuditLogs",<br>  "ApplicationMetricsLogs"<br>]</pre> | no |
| <a name="input_diagnostic_metrics"></a> [diagnostic\_metrics](#input\_diagnostic\_metrics) | List of metric categories to enable for diagnostic settings | `list(string)` | <pre>[<br>  "AllMetrics"<br>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_namespace_id"></a> [namespace\_id](#output\_namespace\_id) | The ID of the Service Bus namespace |
| <a name="output_namespace_name"></a> [namespace\_name](#output\_namespace\_name) | The name of the Service Bus namespace |
| <a name="output_namespace_location"></a> [namespace\_location](#output\_namespace\_location) | The location of the Service Bus namespace |
| <a name="output_namespace_resource_group_name"></a> [namespace\_resource\_group\_name](#output\_namespace\_resource\_group\_name) | The resource group name of the Service Bus namespace |
| <a name="output_namespace_sku"></a> [namespace\_sku](#output\_namespace\_sku) | The SKU of the Service Bus namespace |
| <a name="output_namespace_capacity"></a> [namespace\_capacity](#output\_namespace\_capacity) | The capacity of the Service Bus namespace (Premium only) |
| <a name="output_namespace_default_primary_connection_string"></a> [namespace\_default\_primary\_connection\_string](#output\_namespace\_default\_primary\_connection\_string) | The primary connection string for the Service Bus namespace |
| <a name="output_namespace_default_secondary_connection_string"></a> [namespace\_default\_secondary\_connection\_string](#output\_namespace\_default\_secondary\_connection\_string) | The secondary connection string for the Service Bus namespace |
| <a name="output_namespace_default_primary_key"></a> [namespace\_default\_primary\_key](#output\_namespace\_default\_primary\_key) | The primary access key for the Service Bus namespace |
| <a name="output_namespace_default_secondary_key"></a> [namespace\_default\_secondary\_key](#output\_namespace\_default\_secondary\_key) | The secondary access key for the Service Bus namespace |
| <a name="output_namespace_endpoint"></a> [namespace\_endpoint](#output\_namespace\_endpoint) | The endpoint URL for the Service Bus namespace |
| <a name="output_namespace_identity"></a> [namespace\_identity](#output\_namespace\_identity) | The managed identity of the Service Bus namespace |
| <a name="output_queues"></a> [queues](#output\_queues) | Map of created Service Bus queues |
| <a name="output_queue_ids"></a> [queue\_ids](#output\_queue\_ids) | Map of queue names to their IDs |
| <a name="output_queue_names"></a> [queue\_names](#output\_queue\_names) | Map of queue keys to their actual names |
| <a name="output_topics"></a> [topics](#output\_topics) | Map of created Service Bus topics |
| <a name="output_topic_ids"></a> [topic\_ids](#output\_topic\_ids) | Map of topic names to their IDs |
| <a name="output_topic_names"></a> [topic\_names](#output\_topic\_names) | Map of topic keys to their actual names |
| <a name="output_topic_subscriptions"></a> [topic\_subscriptions](#output\_topic\_subscriptions) | Map of created Service Bus topic subscriptions |
| <a name="output_topic_subscription_ids"></a> [topic\_subscription\_ids](#output\_topic\_subscription\_ids) | Map of subscription names to their IDs |
| <a name="output_topic_subscription_names"></a> [topic\_subscription\_names](#output\_topic\_subscription\_names) | Map of subscription keys to their actual names |
| <a name="output_authorization_rules"></a> [authorization\_rules](#output\_authorization\_rules) | Map of created namespace authorization rules |
| <a name="output_authorization_rule_connection_strings"></a> [authorization\_rule\_connection\_strings](#output\_authorization\_rule\_connection\_strings) | Map of authorization rule primary connection strings |
| <a name="output_authorization_rule_keys"></a> [authorization\_rule\_keys](#output\_authorization\_rule\_keys) | Map of authorization rule primary keys |
| <a name="output_queue_authorization_rules"></a> [queue\_authorization\_rules](#output\_queue\_authorization\_rules) | Map of created queue authorization rules |
| <a name="output_queue_authorization_rule_connection_strings"></a> [queue\_authorization\_rule\_connection\_strings](#output\_queue\_authorization\_rule\_connection\_strings) | Map of queue authorization rule primary connection strings |
| <a name="output_topic_authorization_rules"></a> [topic\_authorization\_rules](#output\_topic\_authorization\_rules) | Map of created topic authorization rules |
| <a name="output_topic_authorization_rule_connection_strings"></a> [topic\_authorization\_rule\_connection\_strings](#output\_topic\_authorization\_rule\_connection\_strings) | Map of topic authorization rule primary connection strings |
| <a name="output_private_endpoint"></a> [private\_endpoint](#output\_private\_endpoint) | Private endpoint information |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | The ID of the private endpoint |
| <a name="output_private_endpoint_ip_address"></a> [private\_endpoint\_ip\_address](#output\_private\_endpoint\_ip\_address) | The private IP address of the private endpoint |
| <a name="output_private_endpoint_fqdn"></a> [private\_endpoint\_fqdn](#output\_private\_endpoint\_fqdn) | The FQDN of the private endpoint |
| <a name="output_key_vault_secrets"></a> [key\_vault\_secrets](#output\_key\_vault\_secrets) | Map of created Key Vault secrets |
| <a name="output_diagnostic_setting"></a> [diagnostic\_setting](#output\_diagnostic\_setting) | Diagnostic setting information |

## Examples

See the [examples](./examples/) directory for complete usage examples:

- [Basic](./examples/basic/) - Simple Service Bus namespace with minimal configuration
- [Complete](./examples/complete/) - Comprehensive setup with all features enabled

## Testing

The module includes comprehensive tests in the [tests](./tests/) directory:

- `basic.tftest.hcl` - Tests basic functionality and naming conventions
- `validation.tftest.hcl` - Tests input validation and error handling
- `outputs.tftest.hcl` - Tests module outputs

Run tests with:

```bash
terraform test
```

## Security Considerations

- By default, queues and topics are empty (no default resources created)
- Public network access is enabled by default but can be disabled
- Private endpoint support for secure network access
- TLS 1.2 is enforced by default
- Connection strings are marked as sensitive in outputs
- Key Vault integration for secure credential storage
- Managed identity support for authentication

## Contributing

When contributing to this module, please:

1. Follow the existing code style and patterns
2. Add appropriate tests for new features
3. Update documentation for any changes
4. Ensure all pre-commit hooks pass

## License

This module is licensed under the MIT License. See [LICENSE](../../LICENSE) for details.

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
| <a name="module_private_endpoint"></a> [private\_endpoint](#module\_private\_endpoint) | app.terraform.io/azure-policy-cloud/private-endpoint/azurerm | 1.1.42-beta |

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault_secret.connection_strings](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_monitor_diagnostic_setting.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_servicebus_namespace.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace) | resource |
| [azurerm_servicebus_namespace_authorization_rule.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace_authorization_rule) | resource |
| [azurerm_servicebus_queue.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_queue) | resource |
| [azurerm_servicebus_queue_authorization_rule.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_queue_authorization_rule) | resource |
| [azurerm_servicebus_subscription.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_subscription) | resource |
| [azurerm_servicebus_topic.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_topic) | resource |
| [azurerm_servicebus_topic_authorization_rule.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_topic_authorization_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_authorization_rules"></a> [authorization\_rules](#input\_authorization\_rules) | Map of namespace-level authorization rules to create | <pre>map(object({<br/>    custom_name = optional(string)<br/>    listen      = optional(bool, false)<br/>    send        = optional(bool, false)<br/>    manage      = optional(bool, false)<br/>  }))</pre> | `{}` | no |
| <a name="input_customer_managed_key"></a> [customer\_managed\_key](#input\_customer\_managed\_key) | Customer managed key configuration for Premium SKU | <pre>object({<br/>    key_vault_key_id                  = string<br/>    identity_id                       = string<br/>    infrastructure_encryption_enabled = optional(bool, false)<br/>  })</pre> | `null` | no |
| <a name="input_diagnostic_log_categories"></a> [diagnostic\_log\_categories](#input\_diagnostic\_log\_categories) | List of log categories to enable for diagnostic settings | `list(string)` | <pre>[<br/>  "OperationalLogs",<br/>  "VNetAndIPFilteringLogs",<br/>  "RuntimeAuditLogs",<br/>  "ApplicationMetricsLogs"<br/>]</pre> | no |
| <a name="input_diagnostic_metrics"></a> [diagnostic\_metrics](#input\_diagnostic\_metrics) | List of metric categories to enable for diagnostic settings | `list(string)` | <pre>[<br/>  "AllMetrics"<br/>]</pre> | no |
| <a name="input_diagnostic_storage_account_id"></a> [diagnostic\_storage\_account\_id](#input\_diagnostic\_storage\_account\_id) | The ID of the storage account for diagnostic settings | `string` | `null` | no |
| <a name="input_enable_diagnostic_settings"></a> [enable\_diagnostic\_settings](#input\_enable\_diagnostic\_settings) | Whether to enable diagnostic settings for the Service Bus namespace | `bool` | `false` | no |
| <a name="input_enable_key_vault_integration"></a> [enable\_key\_vault\_integration](#input\_enable\_key\_vault\_integration) | Whether to store connection strings in Key Vault | `bool` | `false` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | Whether to create a private endpoint for the Service Bus namespace | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name for naming convention | `string` | n/a | yes |
| <a name="input_eventhub_authorization_rule_id"></a> [eventhub\_authorization\_rule\_id](#input\_eventhub\_authorization\_rule\_id) | The ID of the Event Hub authorization rule for diagnostic settings | `string` | `null` | no |
| <a name="input_eventhub_name"></a> [eventhub\_name](#input\_eventhub\_name) | The name of the Event Hub for diagnostic settings | `string` | `null` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | List of user assigned identity IDs | `list(string)` | `null` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | The type of managed identity for the Service Bus namespace | `string` | `null` | no |
| <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id) | The ID of the Key Vault where connection strings will be stored | `string` | `null` | no |
| <a name="input_key_vault_secrets"></a> [key\_vault\_secrets](#input\_key\_vault\_secrets) | Map of Key Vault secrets to create for connection strings | <pre>map(object({<br/>    secret_name     = string<br/>    auth_rule_name  = string<br/>    auth_rule_type  = string # "namespace", "queue", or "topic"<br/>    expiration_date = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_local_auth_enabled"></a> [local\_auth\_enabled](#input\_local\_auth\_enabled) | Whether local authentication is enabled for the Service Bus namespace | `bool` | `true` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where resources will be created | `string` | n/a | yes |
| <a name="input_location_short"></a> [location\_short](#input\_location\_short) | The short name for the Azure region (e.g., 'eastus', 'westus2') | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | The ID of the Log Analytics workspace for diagnostic settings | `string` | `null` | no |
| <a name="input_minimum_tls_version"></a> [minimum\_tls\_version](#input\_minimum\_tls\_version) | The minimum TLS version for the Service Bus namespace | `string` | `"1.2"` | no |
| <a name="input_network_rule_set"></a> [network\_rule\_set](#input\_network\_rule\_set) | Network rule set configuration | <pre>object({<br/>    default_action                = string<br/>    public_network_access_enabled = optional(bool, true)<br/>    trusted_services_allowed      = optional(bool, false)<br/>    network_rules = optional(list(object({<br/>      subnet_id                            = string<br/>      ignore_missing_vnet_service_endpoint = optional(bool, false)<br/>    })), [])<br/>    ip_rules = optional(list(object({<br/>      ip_mask = string<br/>      action  = optional(string, "Allow")<br/>    })), [])<br/>  })</pre> | `null` | no |
| <a name="input_premium_messaging_partitions"></a> [premium\_messaging\_partitions](#input\_premium\_messaging\_partitions) | The number of messaging partitions for Premium SKU (1, 2, or 4) | `number` | `1` | no |
| <a name="input_premium_messaging_units"></a> [premium\_messaging\_units](#input\_premium\_messaging\_units) | The number of messaging units for Premium SKU (1, 2, 4, 8, or 16) | `number` | `1` | no |
| <a name="input_private_dns_zone_group_name"></a> [private\_dns\_zone\_group\_name](#input\_private\_dns\_zone\_group\_name) | Custom name for the private DNS zone group | `string` | `null` | no |
| <a name="input_private_dns_zone_ids"></a> [private\_dns\_zone\_ids](#input\_private\_dns\_zone\_ids) | List of private DNS zone IDs for the private endpoint | `list(string)` | `null` | no |
| <a name="input_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#input\_private\_endpoint\_subnet\_id) | The subnet ID where the private endpoint will be created | `string` | `null` | no |
| <a name="input_private_service_connection_name"></a> [private\_service\_connection\_name](#input\_private\_service\_connection\_name) | Custom name for the private service connection | `string` | `null` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether public network access is enabled for the Service Bus namespace | `bool` | `true` | no |
| <a name="input_queue_authorization_rules"></a> [queue\_authorization\_rules](#input\_queue\_authorization\_rules) | Map of queue-level authorization rules to create | <pre>map(object({<br/>    name       = string<br/>    queue_name = string<br/>    listen     = optional(bool, false)<br/>    send       = optional(bool, false)<br/>    manage     = optional(bool, false)<br/>  }))</pre> | `{}` | no |
| <a name="input_queues"></a> [queues](#input\_queues) | Map of Service Bus queues to create | <pre>map(object({<br/>    custom_name                             = optional(string)<br/>    auto_delete_on_idle                     = optional(string, "P10675199DT2H48M5.4775807S")<br/>    dead_lettering_on_message_expiration    = optional(bool, false)<br/>    default_message_ttl                     = optional(string, "P14D")<br/>    duplicate_detection_history_time_window = optional(string, "PT10M")<br/>    enable_express                          = optional(bool, false)<br/>    enable_partitioning                     = optional(bool, false)<br/>    forward_dead_lettered_messages_to       = optional(string)<br/>    forward_to                              = optional(string)<br/>    lock_duration                           = optional(string, "PT1M")<br/>    max_delivery_count                      = optional(number, 10)<br/>    max_message_size_in_kilobytes           = optional(number)<br/>    max_size_in_megabytes                   = optional(number, 1024)<br/>    requires_duplicate_detection            = optional(bool, false)<br/>    requires_session                        = optional(bool, false)<br/>    status                                  = optional(string, "Active")<br/>  }))</pre> | `{}` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group where the Service Bus will be created | `string` | n/a | yes |
| <a name="input_sku"></a> [sku](#input\_sku) | The SKU of the Service Bus namespace | `string` | `"Standard"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resources | `map(string)` | `{}` | no |
| <a name="input_topic_authorization_rules"></a> [topic\_authorization\_rules](#input\_topic\_authorization\_rules) | Map of topic-level authorization rules to create | <pre>map(object({<br/>    name       = string<br/>    topic_name = string<br/>    listen     = optional(bool, false)<br/>    send       = optional(bool, false)<br/>    manage     = optional(bool, false)<br/>  }))</pre> | `{}` | no |
| <a name="input_topic_subscriptions"></a> [topic\_subscriptions](#input\_topic\_subscriptions) | Map of Service Bus topic subscriptions to create | <pre>map(object({<br/>    name                                      = string<br/>    topic_name                                = string<br/>    custom_name                               = optional(string)<br/>    auto_delete_on_idle                       = optional(string, "P10675199DT2H48M5.4775807S")<br/>    dead_lettering_on_filter_evaluation_error = optional(bool, true)<br/>    dead_lettering_on_message_expiration      = optional(bool, false)<br/>    default_message_ttl                       = optional(string, "P14D")<br/>    enable_batched_operations                 = optional(bool, true)<br/>    forward_dead_lettered_messages_to         = optional(string)<br/>    forward_to                                = optional(string)<br/>    lock_duration                             = optional(string, "PT1M")<br/>    max_delivery_count                        = optional(number, 10)<br/>    requires_session                          = optional(bool, false)<br/>    status                                    = optional(string, "Active")<br/>    client_scoped_subscription_enabled        = optional(bool, false)<br/>    client_scoped_subscription = optional(object({<br/>      client_id    = string<br/>      is_shareable = optional(bool, false)<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_topics"></a> [topics](#input\_topics) | Map of Service Bus topics to create | <pre>map(object({<br/>    custom_name                             = optional(string)<br/>    auto_delete_on_idle                     = optional(string, "P10675199DT2H48M5.4775807S")<br/>    default_message_ttl                     = optional(string, "P14D")<br/>    duplicate_detection_history_time_window = optional(string, "PT10M")<br/>    enable_express                          = optional(bool, false)<br/>    enable_partitioning                     = optional(bool, false)<br/>    max_message_size_in_kilobytes           = optional(number)<br/>    max_size_in_megabytes                   = optional(number, 1024)<br/>    requires_duplicate_detection            = optional(bool, false)<br/>    status                                  = optional(string, "Active")<br/>    support_ordering                        = optional(bool, false)<br/>  }))</pre> | `{}` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | The workload name for naming convention | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_authorization_rule_connection_strings"></a> [authorization\_rule\_connection\_strings](#output\_authorization\_rule\_connection\_strings) | Map of authorization rule primary connection strings |
| <a name="output_authorization_rule_keys"></a> [authorization\_rule\_keys](#output\_authorization\_rule\_keys) | Map of authorization rule primary keys |
| <a name="output_authorization_rules"></a> [authorization\_rules](#output\_authorization\_rules) | Map of created namespace authorization rules |
| <a name="output_diagnostic_setting"></a> [diagnostic\_setting](#output\_diagnostic\_setting) | Diagnostic setting information |
| <a name="output_key_vault_secrets"></a> [key\_vault\_secrets](#output\_key\_vault\_secrets) | Map of created Key Vault secrets |
| <a name="output_namespace_capacity"></a> [namespace\_capacity](#output\_namespace\_capacity) | The capacity of the Service Bus namespace (Premium only) |
| <a name="output_namespace_default_primary_connection_string"></a> [namespace\_default\_primary\_connection\_string](#output\_namespace\_default\_primary\_connection\_string) | The primary connection string for the Service Bus namespace |
| <a name="output_namespace_default_primary_key"></a> [namespace\_default\_primary\_key](#output\_namespace\_default\_primary\_key) | The primary access key for the Service Bus namespace |
| <a name="output_namespace_default_secondary_connection_string"></a> [namespace\_default\_secondary\_connection\_string](#output\_namespace\_default\_secondary\_connection\_string) | The secondary connection string for the Service Bus namespace |
| <a name="output_namespace_default_secondary_key"></a> [namespace\_default\_secondary\_key](#output\_namespace\_default\_secondary\_key) | The secondary access key for the Service Bus namespace |
| <a name="output_namespace_endpoint"></a> [namespace\_endpoint](#output\_namespace\_endpoint) | The endpoint URL for the Service Bus namespace |
| <a name="output_namespace_id"></a> [namespace\_id](#output\_namespace\_id) | The ID of the Service Bus namespace |
| <a name="output_namespace_identity"></a> [namespace\_identity](#output\_namespace\_identity) | The managed identity of the Service Bus namespace |
| <a name="output_namespace_location"></a> [namespace\_location](#output\_namespace\_location) | The location of the Service Bus namespace |
| <a name="output_namespace_name"></a> [namespace\_name](#output\_namespace\_name) | The name of the Service Bus namespace |
| <a name="output_namespace_resource_group_name"></a> [namespace\_resource\_group\_name](#output\_namespace\_resource\_group\_name) | The resource group name of the Service Bus namespace |
| <a name="output_namespace_sku"></a> [namespace\_sku](#output\_namespace\_sku) | The SKU of the Service Bus namespace |
| <a name="output_private_endpoint"></a> [private\_endpoint](#output\_private\_endpoint) | Private endpoint information |
| <a name="output_private_endpoint_fqdn"></a> [private\_endpoint\_fqdn](#output\_private\_endpoint\_fqdn) | The FQDN of the private endpoint |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | The ID of the private endpoint |
| <a name="output_private_endpoint_ip_address"></a> [private\_endpoint\_ip\_address](#output\_private\_endpoint\_ip\_address) | The private IP address of the private endpoint |
| <a name="output_queue_authorization_rule_connection_strings"></a> [queue\_authorization\_rule\_connection\_strings](#output\_queue\_authorization\_rule\_connection\_strings) | Map of queue authorization rule primary connection strings |
| <a name="output_queue_authorization_rules"></a> [queue\_authorization\_rules](#output\_queue\_authorization\_rules) | Map of created queue authorization rules |
| <a name="output_queue_ids"></a> [queue\_ids](#output\_queue\_ids) | Map of queue names to their IDs |
| <a name="output_queue_names"></a> [queue\_names](#output\_queue\_names) | Map of queue keys to their actual names |
| <a name="output_queues"></a> [queues](#output\_queues) | Map of created Service Bus queues |
| <a name="output_topic_authorization_rule_connection_strings"></a> [topic\_authorization\_rule\_connection\_strings](#output\_topic\_authorization\_rule\_connection\_strings) | Map of topic authorization rule primary connection strings |
| <a name="output_topic_authorization_rules"></a> [topic\_authorization\_rules](#output\_topic\_authorization\_rules) | Map of created topic authorization rules |
| <a name="output_topic_ids"></a> [topic\_ids](#output\_topic\_ids) | Map of topic names to their IDs |
| <a name="output_topic_names"></a> [topic\_names](#output\_topic\_names) | Map of topic keys to their actual names |
| <a name="output_topic_subscription_ids"></a> [topic\_subscription\_ids](#output\_topic\_subscription\_ids) | Map of subscription names to their IDs |
| <a name="output_topic_subscription_names"></a> [topic\_subscription\_names](#output\_topic\_subscription\_names) | Map of subscription keys to their actual names |
| <a name="output_topic_subscriptions"></a> [topic\_subscriptions](#output\_topic\_subscriptions) | Map of created Service Bus topic subscriptions |
| <a name="output_topics"></a> [topics](#output\_topics) | Map of created Service Bus topics |
<!-- END_TF_DOCS -->
