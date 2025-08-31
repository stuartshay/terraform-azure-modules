# Service Bus Module - Outputs
# Output values for the Azure Service Bus module

# Service Bus Namespace Outputs
output "namespace_id" {
  description = "The ID of the Service Bus namespace"
  value       = azurerm_servicebus_namespace.main.id
}

output "namespace_name" {
  description = "The name of the Service Bus namespace"
  value       = azurerm_servicebus_namespace.main.name
}

output "namespace_location" {
  description = "The location of the Service Bus namespace"
  value       = azurerm_servicebus_namespace.main.location
}

output "namespace_resource_group_name" {
  description = "The resource group name of the Service Bus namespace"
  value       = azurerm_servicebus_namespace.main.resource_group_name
}

output "namespace_sku" {
  description = "The SKU of the Service Bus namespace"
  value       = azurerm_servicebus_namespace.main.sku
}

output "namespace_capacity" {
  description = "The capacity of the Service Bus namespace (Premium only)"
  value       = azurerm_servicebus_namespace.main.capacity
}

output "namespace_default_primary_connection_string" {
  description = "The primary connection string for the Service Bus namespace"
  value       = azurerm_servicebus_namespace.main.default_primary_connection_string
  sensitive   = true
}

output "namespace_default_secondary_connection_string" {
  description = "The secondary connection string for the Service Bus namespace"
  value       = azurerm_servicebus_namespace.main.default_secondary_connection_string
  sensitive   = true
}

output "namespace_default_primary_key" {
  description = "The primary access key for the Service Bus namespace"
  value       = azurerm_servicebus_namespace.main.default_primary_key
  sensitive   = true
}

output "namespace_default_secondary_key" {
  description = "The secondary access key for the Service Bus namespace"
  value       = azurerm_servicebus_namespace.main.default_secondary_key
  sensitive   = true
}

output "namespace_endpoint" {
  description = "The endpoint URL for the Service Bus namespace"
  value       = "https://${azurerm_servicebus_namespace.main.name}.servicebus.windows.net/"
}

# Identity Outputs
output "namespace_identity" {
  description = "The managed identity of the Service Bus namespace"
  value = var.identity_type != null ? {
    type         = azurerm_servicebus_namespace.main.identity[0].type
    principal_id = azurerm_servicebus_namespace.main.identity[0].principal_id
    tenant_id    = azurerm_servicebus_namespace.main.identity[0].tenant_id
    identity_ids = azurerm_servicebus_namespace.main.identity[0].identity_ids
  } : null
}

# Queue Outputs
output "queues" {
  description = "Map of created Service Bus queues"
  value = {
    for k, v in azurerm_servicebus_queue.main : k => {
      id                    = v.id
      name                  = v.name
      namespace_id          = v.namespace_id
      max_size_in_megabytes = v.max_size_in_megabytes
      status                = v.status
    }
  }
}

output "queue_ids" {
  description = "Map of queue names to their IDs"
  value = {
    for k, v in azurerm_servicebus_queue.main : k => v.id
  }
}

output "queue_names" {
  description = "Map of queue keys to their actual names"
  value = {
    for k, v in azurerm_servicebus_queue.main : k => v.name
  }
}

# Topic Outputs
output "topics" {
  description = "Map of created Service Bus topics"
  value = {
    for k, v in azurerm_servicebus_topic.main : k => {
      id                    = v.id
      name                  = v.name
      namespace_id          = v.namespace_id
      max_size_in_megabytes = v.max_size_in_megabytes
      status                = v.status
    }
  }
}

output "topic_ids" {
  description = "Map of topic names to their IDs"
  value = {
    for k, v in azurerm_servicebus_topic.main : k => v.id
  }
}

output "topic_names" {
  description = "Map of topic keys to their actual names"
  value = {
    for k, v in azurerm_servicebus_topic.main : k => v.name
  }
}

# Topic Subscription Outputs
output "topic_subscriptions" {
  description = "Map of created Service Bus topic subscriptions"
  value = {
    for k, v in azurerm_servicebus_subscription.main : k => {
      id                 = v.id
      name               = v.name
      topic_id           = v.topic_id
      max_delivery_count = v.max_delivery_count
      status             = v.status
    }
  }
}

output "topic_subscription_ids" {
  description = "Map of subscription names to their IDs"
  value = {
    for k, v in azurerm_servicebus_subscription.main : k => v.id
  }
}

output "topic_subscription_names" {
  description = "Map of subscription keys to their actual names"
  value = {
    for k, v in azurerm_servicebus_subscription.main : k => v.name
  }
}

# Authorization Rule Outputs
output "authorization_rules" {
  description = "Map of created namespace authorization rules"
  value = {
    for k, v in azurerm_servicebus_namespace_authorization_rule.main : k => {
      id     = v.id
      name   = v.name
      listen = v.listen
      send   = v.send
      manage = v.manage
    }
  }
}

output "authorization_rule_connection_strings" {
  description = "Map of authorization rule primary connection strings"
  value = {
    for k, v in azurerm_servicebus_namespace_authorization_rule.main : k => v.primary_connection_string
  }
  sensitive = true
}

output "authorization_rule_keys" {
  description = "Map of authorization rule primary keys"
  value = {
    for k, v in azurerm_servicebus_namespace_authorization_rule.main : k => v.primary_key
  }
  sensitive = true
}

# Queue Authorization Rule Outputs
output "queue_authorization_rules" {
  description = "Map of created queue authorization rules"
  value = {
    for k, v in azurerm_servicebus_queue_authorization_rule.main : k => {
      id       = v.id
      name     = v.name
      queue_id = v.queue_id
      listen   = v.listen
      send     = v.send
      manage   = v.manage
    }
  }
}

output "queue_authorization_rule_connection_strings" {
  description = "Map of queue authorization rule primary connection strings"
  value = {
    for k, v in azurerm_servicebus_queue_authorization_rule.main : k => v.primary_connection_string
  }
  sensitive = true
}

# Topic Authorization Rule Outputs
output "topic_authorization_rules" {
  description = "Map of created topic authorization rules"
  value = {
    for k, v in azurerm_servicebus_topic_authorization_rule.main : k => {
      id       = v.id
      name     = v.name
      topic_id = v.topic_id
      listen   = v.listen
      send     = v.send
      manage   = v.manage
    }
  }
}

output "topic_authorization_rule_connection_strings" {
  description = "Map of topic authorization rule primary connection strings"
  value = {
    for k, v in azurerm_servicebus_topic_authorization_rule.main : k => v.primary_connection_string
  }
  sensitive = true
}

# Private Endpoint Outputs
output "private_endpoint" {
  description = "Private endpoint information"
  value = var.enable_private_endpoint ? {
    id                   = module.private_endpoint[0].private_endpoint_id
    name                 = module.private_endpoint[0].private_endpoint_name
    private_ip_address   = module.private_endpoint[0].private_ip_address
    network_interface_id = module.private_endpoint[0].network_interface_id
    fqdn                 = module.private_endpoint[0].fqdn
  } : null
}

output "private_endpoint_id" {
  description = "The ID of the private endpoint"
  value       = var.enable_private_endpoint ? module.private_endpoint[0].private_endpoint_id : null
}

output "private_endpoint_ip_address" {
  description = "The private IP address of the private endpoint"
  value       = var.enable_private_endpoint ? module.private_endpoint[0].private_ip_address : null
}

output "private_endpoint_fqdn" {
  description = "The FQDN of the private endpoint"
  value       = var.enable_private_endpoint ? module.private_endpoint[0].fqdn : null
}

# Key Vault Secret Outputs
output "key_vault_secrets" {
  description = "Map of created Key Vault secrets"
  value = var.enable_key_vault_integration ? {
    for k, v in azurerm_key_vault_secret.connection_strings : k => {
      id             = v.id
      name           = v.name
      key_vault_id   = v.key_vault_id
      version        = v.version
      versionless_id = v.versionless_id
    }
  } : {}
}

# Diagnostic Settings Outputs
output "diagnostic_setting" {
  description = "Diagnostic setting information"
  value = var.enable_diagnostic_settings ? {
    id                             = azurerm_monitor_diagnostic_setting.main[0].id
    name                           = azurerm_monitor_diagnostic_setting.main[0].name
    target_resource_id             = azurerm_monitor_diagnostic_setting.main[0].target_resource_id
    log_analytics_workspace_id     = azurerm_monitor_diagnostic_setting.main[0].log_analytics_workspace_id
    storage_account_id             = azurerm_monitor_diagnostic_setting.main[0].storage_account_id
    eventhub_authorization_rule_id = azurerm_monitor_diagnostic_setting.main[0].eventhub_authorization_rule_id
    eventhub_name                  = azurerm_monitor_diagnostic_setting.main[0].eventhub_name
  } : null
}
