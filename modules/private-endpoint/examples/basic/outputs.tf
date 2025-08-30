# Basic Private Endpoint Example - Outputs
# This file defines output values for the basic example

output "storage_account_id" {
  description = "ID of the created storage account"
  value       = azurerm_storage_account.example.id
}

output "storage_account_name" {
  description = "Name of the created storage account"
  value       = azurerm_storage_account.example.name
}

output "private_endpoint_id" {
  description = "ID of the created private endpoint"
  value       = module.storage_private_endpoint.id
}

output "private_endpoint_name" {
  description = "Name of the created private endpoint"
  value       = module.storage_private_endpoint.name
}

output "private_ip_address" {
  description = "Private IP address of the private endpoint"
  value       = module.storage_private_endpoint.private_ip_address
}

output "private_service_connection" {
  description = "Private service connection details"
  value       = module.storage_private_endpoint.private_service_connection
}

output "network_interface" {
  description = "Network interface details of the private endpoint"
  value       = module.storage_private_endpoint.network_interface
}

output "custom_dns_configs" {
  description = "Custom DNS configurations for the private endpoint"
  value       = module.storage_private_endpoint.custom_dns_configs
}
