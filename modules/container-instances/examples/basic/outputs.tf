# Basic Example Outputs

output "container_group_id" {
  description = "The ID of the Container Group"
  value       = module.container_instances.container_group_id
}

output "container_group_name" {
  description = "The name of the Container Group"
  value       = module.container_instances.container_group_name
}

output "ip_address" {
  description = "The public IP address of the Container Group"
  value       = module.container_instances.ip_address
}

output "fqdn" {
  description = "The FQDN of the Container Group"
  value       = module.container_instances.fqdn
}

output "container_group_summary" {
  description = "Summary of the Container Group deployment"
  value       = module.container_instances.container_group_summary
}
