# Private Endpoint Module - Outputs
# This file defines all output values for the private endpoint module

output "id" {
  description = "ID of the private endpoint"
  value       = azurerm_private_endpoint.main.id
}

output "name" {
  description = "Name of the private endpoint"
  value       = azurerm_private_endpoint.main.name
}

output "location" {
  description = "Location of the private endpoint"
  value       = azurerm_private_endpoint.main.location
}

output "resource_group_name" {
  description = "Resource group name of the private endpoint"
  value       = azurerm_private_endpoint.main.resource_group_name
}

output "subnet_id" {
  description = "Subnet ID where the private endpoint is deployed"
  value       = azurerm_private_endpoint.main.subnet_id
}

output "private_service_connection" {
  description = "Private service connection details"
  value = {
    name                           = azurerm_private_endpoint.main.private_service_connection[0].name
    private_connection_resource_id = azurerm_private_endpoint.main.private_service_connection[0].private_connection_resource_id
    subresource_names              = azurerm_private_endpoint.main.private_service_connection[0].subresource_names
    is_manual_connection           = azurerm_private_endpoint.main.private_service_connection[0].is_manual_connection
    private_ip_address             = azurerm_private_endpoint.main.private_service_connection[0].private_ip_address
  }
}

output "private_dns_zone_group" {
  description = "Private DNS zone group details (if configured)"
  value = length(azurerm_private_endpoint.main.private_dns_zone_group) > 0 ? {
    name                 = azurerm_private_endpoint.main.private_dns_zone_group[0].name
    private_dns_zone_ids = azurerm_private_endpoint.main.private_dns_zone_group[0].private_dns_zone_ids
  } : null
}

output "network_interface" {
  description = "Network interface details of the private endpoint"
  value = {
    id   = length(azurerm_private_endpoint.main.network_interface) > 0 ? azurerm_private_endpoint.main.network_interface[0].id : null
    name = length(azurerm_private_endpoint.main.network_interface) > 0 ? azurerm_private_endpoint.main.network_interface[0].name : null
  }
}

output "custom_dns_configs" {
  description = "Custom DNS configurations for the private endpoint"
  value = [
    for config in azurerm_private_endpoint.main.custom_dns_configs : {
      fqdn         = config.fqdn
      ip_addresses = config.ip_addresses
    }
  ]
}

output "private_ip_address" {
  description = "Private IP address of the private endpoint"
  value       = azurerm_private_endpoint.main.private_service_connection[0].private_ip_address
}

output "fqdn" {
  description = "FQDN of the private endpoint (if available)"
  value       = length(azurerm_private_endpoint.main.custom_dns_configs) > 0 ? azurerm_private_endpoint.main.custom_dns_configs[0].fqdn : null
}
