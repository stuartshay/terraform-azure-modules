# Complete Example Outputs

output "vnet_id" {
  description = "ID of the created virtual network"
  value       = module.networking.vnet_id
}

output "vnet_name" {
  description = "Name of the created virtual network"
  value       = module.networking.vnet_name
}

output "vnet_address_space" {
  description = "Address space of the virtual network"
  value       = module.networking.vnet_address_space
}

output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value       = module.networking.subnet_ids
}

output "subnet_names" {
  description = "Map of subnet keys to their actual names"
  value       = module.networking.subnet_names
}

output "nsg_ids" {
  description = "Map of NSG names to their IDs"
  value       = module.networking.nsg_ids
}

output "nsg_names" {
  description = "Map of NSG keys to their actual names"
  value       = module.networking.nsg_names
}

output "app_service_subnet_id" {
  description = "ID of the App Service subnet"
  value       = module.networking.app_service_subnet_id
}

output "functions_subnet_id" {
  description = "ID of the Functions subnet"
  value       = module.networking.functions_subnet_id
}

output "private_endpoints_subnet_id" {
  description = "ID of the Private Endpoints subnet"
  value       = module.networking.private_endpoints_subnet_id
}

output "route_table_id" {
  description = "ID of the route table"
  value       = module.networking.route_table_id
}

output "network_watcher_id" {
  description = "ID of the Network Watcher"
  value       = module.networking.network_watcher_id
}

output "flow_logs_storage_account_id" {
  description = "ID of the flow logs storage account"
  value       = module.networking.flow_logs_storage_account_id
}

output "vnet_flow_log_id" {
  description = "ID of the VNet flow log"
  value       = module.networking.vnet_flow_log_id
}

output "networking_summary" {
  description = "Summary of networking configuration"
  value       = module.networking.networking_summary
}

output "security_summary" {
  description = "Summary of network security configuration"
  value       = module.networking.security_summary
}

output "connectivity_info" {
  description = "Information for connecting other resources to the network"
  value       = module.networking.connectivity_info
}

output "resource_names" {
  description = "Map of all created resource names for reference"
  value       = module.networking.resource_names
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.example.id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.example.name
}
