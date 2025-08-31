# Basic Service Bus Example - Outputs
# Output values for the basic Service Bus example

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

output "service_bus_namespace_connection_string" {
  description = "The primary connection string for the Service Bus namespace"
  value       = module.service_bus.namespace_default_primary_connection_string
  sensitive   = true
}
