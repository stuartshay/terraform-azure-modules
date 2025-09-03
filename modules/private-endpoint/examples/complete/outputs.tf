# Complete Private Endpoint Example - Outputs
# This file defines output values for the complete example

# Service Bus Outputs
output "servicebus_namespace_id" {
  description = "ID of the created Service Bus namespace"
  value       = azurerm_servicebus_namespace.example.id
}

output "servicebus_namespace_name" {
  description = "Name of the created Service Bus namespace"
  value       = azurerm_servicebus_namespace.example.name
}

output "servicebus_private_endpoint_id" {
  description = "ID of the Service Bus private endpoint"
  value       = module.servicebus_private_endpoint.id
}

output "servicebus_private_endpoint_ip" {
  description = "Private IP address of the Service Bus private endpoint"
  value       = module.servicebus_private_endpoint.private_ip_address
}

# Storage Account Outputs
output "storage_account_id" {
  description = "ID of the created storage account"
  value       = azurerm_storage_account.example.id
}

output "storage_account_name" {
  description = "Name of the created storage account"
  value       = azurerm_storage_account.example.name
}

output "storage_private_endpoint_ids" {
  description = "IDs of the storage account private endpoints"
  value = {
    for key, endpoint in module.storage_private_endpoints : key => endpoint.id
  }
}

output "storage_private_endpoint_ips" {
  description = "Private IP addresses of the storage account private endpoints"
  value = {
    for key, endpoint in module.storage_private_endpoints : key => endpoint.private_ip_address
  }
}

# DNS Zone Outputs
output "private_dns_zone_ids" {
  description = "IDs of the created private DNS zones"
  value = {
    servicebus = azurerm_private_dns_zone.servicebus.id
    blob       = azurerm_private_dns_zone.blob.id
    file       = azurerm_private_dns_zone.file.id
  }
}

output "private_dns_zone_names" {
  description = "Names of the created private DNS zones"
  value = {
    servicebus = azurerm_private_dns_zone.servicebus.name
    blob       = azurerm_private_dns_zone.blob.name
    file       = azurerm_private_dns_zone.file.name
  }
}

# Network Configuration Outputs
output "virtual_network_id" {
  description = "ID of the virtual network"
  value       = data.azurerm_virtual_network.example.id
}

output "private_endpoint_subnet_id" {
  description = "ID of the private endpoint subnet"
  value       = data.azurerm_subnet.private_endpoints.id
}

# DNS Configuration Details
output "servicebus_dns_configs" {
  description = "DNS configurations for the Service Bus private endpoint"
  value       = module.servicebus_private_endpoint.custom_dns_configs
}

output "storage_dns_configs" {
  description = "DNS configurations for the storage account private endpoints"
  value = {
    for key, endpoint in module.storage_private_endpoints : key => endpoint.custom_dns_configs
  }
}

# Private Service Connection Details
output "servicebus_private_service_connection" {
  description = "Private service connection details for Service Bus"
  value       = module.servicebus_private_endpoint.private_service_connection
}

output "storage_private_service_connections" {
  description = "Private service connection details for storage account"
  value = {
    for key, endpoint in module.storage_private_endpoints : key => endpoint.private_service_connection
  }
}
