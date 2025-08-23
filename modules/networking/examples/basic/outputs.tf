# Basic Example Outputs

output "vnet_id" {
  description = "ID of the created virtual network"
  value       = module.networking.vnet_id
}

output "vnet_name" {
  description = "Name of the created virtual network"
  value       = module.networking.vnet_name
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

output "networking_summary" {
  description = "Summary of networking configuration"
  value       = module.networking.networking_summary
}

output "connectivity_info" {
  description = "Information for connecting other resources to the network"
  value       = module.networking.connectivity_info
}
