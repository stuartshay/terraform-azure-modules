# Complete Storage Account Example - Outputs

output "storage_account_name" {
  description = "Name of the created storage account"
  value       = module.storage_account.storage_account_name
}

output "storage_account_id" {
  description = "ID of the created storage account"
  value       = module.storage_account.storage_account_id
}

output "primary_blob_endpoint" {
  description = "Primary blob endpoint of the storage account"
  value       = module.storage_account.primary_blob_endpoint
}

output "primary_dfs_endpoint" {
  description = "Primary DFS endpoint (Data Lake Gen2)"
  value       = module.storage_account.primary_dfs_endpoint
}

output "primary_web_endpoint" {
  description = "Primary web endpoint (Static Website)"
  value       = module.storage_account.primary_web_endpoint
}

output "blob_container_names" {
  description = "Names of the created blob containers"
  value       = module.storage_account.blob_container_names
}

output "file_share_names" {
  description = "Names of the created file shares"
  value       = module.storage_account.file_share_names
}

output "queue_names" {
  description = "Names of the created queues"
  value       = module.storage_account.queue_names
}

output "table_names" {
  description = "Names of the created tables"
  value       = module.storage_account.table_names
}

output "private_endpoint_ids" {
  description = "IDs of the created private endpoints"
  value       = module.storage_account.private_endpoint_ids
}

output "private_endpoint_ips" {
  description = "Private IP addresses of the private endpoints"
  value       = module.storage_account.private_endpoint_ips
}

output "identity" {
  description = "Managed identity information"
  value       = module.storage_account.identity
}

output "storage_account_summary" {
  description = "Summary of storage account configuration"
  value       = module.storage_account.storage_account_summary
}

output "security_summary" {
  description = "Summary of security configuration"
  value       = module.storage_account.security_summary
}

output "connectivity_info" {
  description = "Connectivity information"
  value       = module.storage_account.connectivity_info
}

output "compliance_info" {
  description = "Compliance and governance information"
  value       = module.storage_account.compliance_info
}

output "cost_optimization_info" {
  description = "Cost optimization information"
  value       = module.storage_account.cost_optimization_info
}
