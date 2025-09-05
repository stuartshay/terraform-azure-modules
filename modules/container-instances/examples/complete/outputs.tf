# Complete Example Outputs

output "container_group_id" {
  description = "The ID of the Container Group"
  value       = module.container_instances.container_group_id
}

output "container_group_name" {
  description = "The name of the Container Group"
  value       = module.container_instances.container_group_name
}

output "ip_address" {
  description = "The private IP address of the Container Group"
  value       = module.container_instances.ip_address
}

output "fqdn" {
  description = "The FQDN of the Container Group"
  value       = module.container_instances.fqdn
}

output "containers" {
  description = "Information about all containers in the group"
  value       = module.container_instances.containers
}

output "volumes" {
  description = "Information about all volumes in the group"
  value       = module.container_instances.volumes
}

output "identity" {
  description = "The managed identity information"
  value       = module.container_instances.identity
}

output "principal_id" {
  description = "The principal ID of the managed identity"
  value       = module.container_instances.principal_id
}

output "runtime_configuration" {
  description = "Runtime configuration of the Container Group"
  value       = module.container_instances.runtime_configuration
}

output "network_configuration" {
  description = "Network configuration of the Container Group"
  value       = module.container_instances.network_configuration
}

output "security_configuration" {
  description = "Security configuration of the Container Group"
  value       = module.container_instances.security_configuration
}

output "monitoring_configuration" {
  description = "Monitoring configuration of the Container Group"
  value       = module.container_instances.monitoring_configuration
}

output "container_group_summary" {
  description = "Complete summary of the Container Group deployment"
  value       = module.container_instances.container_group_summary
}
