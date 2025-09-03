# Complete Service Bus Example - Outputs
# Output values for the complete Service Bus example

# Service Bus Namespace Outputs
output "service_bus_namespace_id" {
  description = "The ID of the Service Bus namespace"
  value       = module.service_bus.namespace_id
}

output "service_bus_namespace_name" {
  description = "The name of the Service Bus namespace"
  value       = module.service_bus.namespace_name
}

output "service_bus_namespace_endpoint" {
  description = "The endpoint URL for the Service Bus namespace"
  value       = module.service_bus.namespace_endpoint
}

output "service_bus_namespace_sku" {
  description = "The SKU of the Service Bus namespace"
  value       = module.service_bus.namespace_sku
}

output "service_bus_namespace_identity" {
  description = "The managed identity of the Service Bus namespace"
  value       = module.service_bus.namespace_identity
}

# Queue Outputs
output "service_bus_queues" {
  description = "Map of created Service Bus queues"
  value       = module.service_bus.queues
}

output "service_bus_queue_names" {
  description = "Map of queue keys to their actual names"
  value       = module.service_bus.queue_names
}

# Topic Outputs
output "service_bus_topics" {
  description = "Map of created Service Bus topics"
  value       = module.service_bus.topics
}

output "service_bus_topic_names" {
  description = "Map of topic keys to their actual names"
  value       = module.service_bus.topic_names
}

# Topic Subscription Outputs
output "service_bus_topic_subscriptions" {
  description = "Map of created Service Bus topic subscriptions"
  value       = module.service_bus.topic_subscriptions
}

# Authorization Rule Outputs
output "service_bus_authorization_rules" {
  description = "Map of created namespace authorization rules"
  value       = module.service_bus.authorization_rules
}

output "service_bus_queue_authorization_rules" {
  description = "Map of created queue authorization rules"
  value       = module.service_bus.queue_authorization_rules
}

output "service_bus_topic_authorization_rules" {
  description = "Map of created topic authorization rules"
  value       = module.service_bus.topic_authorization_rules
}

# Private Endpoint Outputs
output "service_bus_private_endpoint" {
  description = "Private endpoint information"
  value       = module.service_bus.private_endpoint
}

output "service_bus_private_endpoint_ip" {
  description = "The private IP address of the private endpoint"
  value       = module.service_bus.private_endpoint_ip_address
}

output "service_bus_private_endpoint_fqdn" {
  description = "The FQDN of the private endpoint"
  value       = module.service_bus.private_endpoint_fqdn
}

# Key Vault Secret Outputs
output "service_bus_key_vault_secrets" {
  description = "Map of created Key Vault secrets"
  value       = module.service_bus.key_vault_secrets
}

# Diagnostic Settings Outputs
output "service_bus_diagnostic_setting" {
  description = "Diagnostic setting information"
  value       = module.service_bus.diagnostic_setting
}

# Supporting Infrastructure Outputs
output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.example.name
}

output "virtual_network_id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.example.id
}

output "private_dns_zone_id" {
  description = "The ID of the private DNS zone"
  value       = azurerm_private_dns_zone.servicebus.id
}

output "key_vault_id" {
  description = "The ID of the Key Vault"
  value       = azurerm_key_vault.example.id
}

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.example.id
}
