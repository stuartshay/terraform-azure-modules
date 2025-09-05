# Service Bus Module - Main Configuration
# This module creates Azure Service Bus namespace with configurable queues, topics, and private endpoints

# Local values for consistent naming and configuration
locals {
  # Service Bus namespace name following the naming convention
  service_bus_name = "sb-${var.workload}-${var.environment}-${var.location_short}-001"

  # Create queue names with environment suffix
  queue_names = {
    for queue_name, queue_config in var.queues :
    queue_name => queue_config.custom_name != null ? queue_config.custom_name : "${queue_name}-${var.environment}"
  }

  # Create topic names with environment suffix
  topic_names = {
    for topic_name, topic_config in var.topics :
    topic_name => topic_config.custom_name != null ? topic_config.custom_name : "${topic_name}-${var.environment}"
  }

  # Create subscription names
  subscription_names = {
    for sub_key, sub_config in var.topic_subscriptions :
    sub_key => sub_config.custom_name != null ? sub_config.custom_name : "${sub_config.name}-${var.environment}"
  }

  # Authorization rule names
  auth_rule_names = {
    for rule_name, rule_config in var.authorization_rules :
    rule_name => rule_config.custom_name != null ? rule_config.custom_name : "${rule_name}-${var.environment}"
  }
}

# Service Bus Namespace
resource "azurerm_servicebus_namespace" "main" {
  #checkov:skip=CKV_AZURE_202:Public network access is controlled by variable
  name                = local.service_bus_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku

  # Premium SKU specific settings
  capacity                     = var.sku == "Premium" ? var.premium_messaging_units : null
  premium_messaging_partitions = var.sku == "Premium" ? var.premium_messaging_partitions : null

  # Network and security settings
  public_network_access_enabled = var.public_network_access_enabled
  minimum_tls_version           = var.minimum_tls_version


  # Local authentication
  local_auth_enabled = var.local_auth_enabled

  # Identity
  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  # Customer managed key (Premium only)
  dynamic "customer_managed_key" {
    for_each = var.sku == "Premium" && var.customer_managed_key != null ? [1] : []
    content {
      key_vault_key_id                  = var.customer_managed_key.key_vault_key_id
      identity_id                       = var.customer_managed_key.identity_id
      infrastructure_encryption_enabled = var.customer_managed_key.infrastructure_encryption_enabled
    }
  }

  # Network rule set
  dynamic "network_rule_set" {
    for_each = var.network_rule_set != null ? [1] : []
    content {
      default_action                = var.network_rule_set.default_action
      public_network_access_enabled = var.network_rule_set.public_network_access_enabled
      trusted_services_allowed      = var.network_rule_set.trusted_services_allowed

      dynamic "network_rules" {
        for_each = var.network_rule_set.network_rules
        content {
          subnet_id                            = network_rules.value.subnet_id
          ignore_missing_vnet_service_endpoint = network_rules.value.ignore_missing_vnet_service_endpoint
        }
      }

      ip_rules = var.network_rule_set.ip_rules
    }
  }

  tags = var.tags
}

# Service Bus Queues
resource "azurerm_servicebus_queue" "main" {
  for_each = var.queues

  name         = local.queue_names[each.key]
  namespace_id = azurerm_servicebus_namespace.main.id

  # Queue configuration
  auto_delete_on_idle                     = each.value.auto_delete_on_idle
  dead_lettering_on_message_expiration    = each.value.dead_lettering_on_message_expiration
  default_message_ttl                     = each.value.default_message_ttl
  duplicate_detection_history_time_window = each.value.duplicate_detection_history_time_window
  forward_dead_lettered_messages_to       = each.value.forward_dead_lettered_messages_to
  forward_to                              = each.value.forward_to
  lock_duration                           = each.value.lock_duration
  max_delivery_count                      = each.value.max_delivery_count
  max_message_size_in_kilobytes           = each.value.max_message_size_in_kilobytes
  max_size_in_megabytes                   = each.value.max_size_in_megabytes
  partitioning_enabled                    = each.value.enable_partitioning
  requires_duplicate_detection            = each.value.requires_duplicate_detection
  requires_session                        = each.value.requires_session
  status                                  = each.value.status
}

# Service Bus Topics
resource "azurerm_servicebus_topic" "main" {
  for_each = var.topics

  name         = local.topic_names[each.key]
  namespace_id = azurerm_servicebus_namespace.main.id

  # Topic configuration
  auto_delete_on_idle                     = each.value.auto_delete_on_idle
  default_message_ttl                     = each.value.default_message_ttl
  duplicate_detection_history_time_window = each.value.duplicate_detection_history_time_window
  max_message_size_in_kilobytes           = each.value.max_message_size_in_kilobytes
  max_size_in_megabytes                   = each.value.max_size_in_megabytes
  partitioning_enabled                    = each.value.enable_partitioning
  requires_duplicate_detection            = each.value.requires_duplicate_detection
  status                                  = each.value.status
  support_ordering                        = each.value.support_ordering
}

# Service Bus Topic Subscriptions
resource "azurerm_servicebus_subscription" "main" {
  for_each = var.topic_subscriptions

  name     = local.subscription_names[each.key]
  topic_id = azurerm_servicebus_topic.main[each.value.topic_name].id

  # Subscription configuration
  auto_delete_on_idle                       = each.value.auto_delete_on_idle
  dead_lettering_on_filter_evaluation_error = each.value.dead_lettering_on_filter_evaluation_error
  dead_lettering_on_message_expiration      = each.value.dead_lettering_on_message_expiration
  default_message_ttl                       = each.value.default_message_ttl
  forward_dead_lettered_messages_to         = each.value.forward_dead_lettered_messages_to
  forward_to                                = each.value.forward_to
  lock_duration                             = each.value.lock_duration
  max_delivery_count                        = each.value.max_delivery_count
  requires_session                          = each.value.requires_session
  status                                    = each.value.status

  # Client scoped subscription
  dynamic "client_scoped_subscription" {
    for_each = each.value.client_scoped_subscription_enabled ? [1] : []
    content {
      client_id                               = each.value.client_scoped_subscription.client_id
      is_client_scoped_subscription_shareable = each.value.client_scoped_subscription.is_shareable
    }
  }
}

# Authorization Rules
resource "azurerm_servicebus_namespace_authorization_rule" "main" {
  for_each = var.authorization_rules

  name         = local.auth_rule_names[each.key]
  namespace_id = azurerm_servicebus_namespace.main.id

  listen = each.value.listen
  send   = each.value.send
  manage = each.value.manage
}

# Queue Authorization Rules
resource "azurerm_servicebus_queue_authorization_rule" "main" {
  for_each = var.queue_authorization_rules

  name     = each.value.name
  queue_id = azurerm_servicebus_queue.main[each.value.queue_name].id

  listen = each.value.listen
  send   = each.value.send
  manage = each.value.manage
}

# Topic Authorization Rules
resource "azurerm_servicebus_topic_authorization_rule" "main" {
  for_each = var.topic_authorization_rules

  name     = each.value.name
  topic_id = azurerm_servicebus_topic.main[each.value.topic_name].id

  listen = each.value.listen
  send   = each.value.send
  manage = each.value.manage
}

# Private Endpoint (using the private-endpoint module)
module "private_endpoint" {
  source  = "app.terraform.io/azure-policy-cloud/private-endpoint/azurerm"
  version = "1.1.71"
  count   = var.enable_private_endpoint ? 1 : 0

  name                           = "pe-${local.service_bus_name}"
  location                       = var.location
  resource_group_name            = var.resource_group_name
  subnet_id                      = var.private_endpoint_subnet_id
  private_connection_resource_id = azurerm_servicebus_namespace.main.id
  subresource_names              = ["namespace"]

  # DNS integration
  private_dns_zone_ids = var.private_dns_zone_ids

  # Custom naming
  private_service_connection_name = var.private_service_connection_name != null ? var.private_service_connection_name : "psc-${local.service_bus_name}"
  private_dns_zone_group_name     = var.private_dns_zone_group_name != null ? var.private_dns_zone_group_name : "pdzg-${local.service_bus_name}"

  tags = var.tags
}

# Key Vault Secrets (optional)
resource "azurerm_key_vault_secret" "connection_strings" {
  for_each = var.enable_key_vault_integration ? var.key_vault_secrets : {}

  name            = each.value.secret_name
  value           = each.value.auth_rule_type == "namespace" ? azurerm_servicebus_namespace_authorization_rule.main[each.value.auth_rule_name].primary_connection_string : (each.value.auth_rule_type == "queue" ? azurerm_servicebus_queue_authorization_rule.main[each.value.auth_rule_name].primary_connection_string : azurerm_servicebus_topic_authorization_rule.main[each.value.auth_rule_name].primary_connection_string)
  key_vault_id    = var.key_vault_id
  content_type    = "text/plain"
  expiration_date = each.value.expiration_date

  tags = merge(var.tags, {
    SecretType = "servicebus-connection-string" # pragma: allowlist secret
    Namespace  = azurerm_servicebus_namespace.main.name
  })
}

# Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "main" {
  count = var.enable_diagnostic_settings ? 1 : 0

  name                           = "diag-${local.service_bus_name}"
  target_resource_id             = azurerm_servicebus_namespace.main.id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  storage_account_id             = var.diagnostic_storage_account_id
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  eventhub_name                  = var.eventhub_name

  # Enable logging categories
  dynamic "enabled_log" {
    for_each = var.diagnostic_log_categories
    content {
      category = enabled_log.value
    }
  }

  # Enable metrics
  dynamic "metric" {
    for_each = var.diagnostic_metrics
    content {
      category = metric.value
      enabled  = true
    }
  }
}
