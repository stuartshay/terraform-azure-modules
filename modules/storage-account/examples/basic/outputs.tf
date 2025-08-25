# Basic Storage Account Example - Outputs

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

output "blob_container_names" {
  description = "Names of the created blob containers"
  value       = module.storage_account.blob_container_names
}

output "storage_account_summary" {
  description = "Summary of storage account configuration"
  value       = module.storage_account.storage_account_summary
}
