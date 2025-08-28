# Enhanced Storage Account Example Outputs

# Storage Account Information
output "storage_account_name" {
  description = "Name of the created storage account"
  value       = module.storage_account_enhanced.storage_account_name
}

output "storage_account_id" {
  description = "ID of the created storage account"
  value       = module.storage_account_enhanced.storage_account_id
}

# Enhanced Diagnostic Settings
output "diagnostic_setting_ids" {
  description = "Map of diagnostic setting IDs for each storage service"
  value       = module.storage_account_enhanced.diagnostic_setting_ids
}

# Blob Versioning Status
output "blob_versioning_enabled" {
  description = "Whether blob versioning is enabled"
  value       = module.storage_account_enhanced.blob_versioning_enabled
}

# Key Vault SAS Token Secret
output "key_vault_sas_secret_id" {
  description = "ID of the Key Vault secret containing the SAS token"
  value       = module.storage_account_enhanced.key_vault_sas_secret_id
}

# Storage Endpoints
output "primary_blob_endpoint" {
  description = "Primary blob endpoint"
  value       = module.storage_account_enhanced.primary_blob_endpoint
}

output "primary_file_endpoint" {
  description = "Primary file endpoint"
  value       = module.storage_account_enhanced.primary_file_endpoint
}

output "primary_queue_endpoint" {
  description = "Primary queue endpoint"
  value       = module.storage_account_enhanced.primary_queue_endpoint
}

output "primary_table_endpoint" {
  description = "Primary table endpoint"
  value       = module.storage_account_enhanced.primary_table_endpoint
}

# Container Information
output "blob_container_names" {
  description = "Map of blob container keys to their actual names"
  value       = module.storage_account_enhanced.blob_container_names
}

# Log Analytics Workspace
output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace for diagnostics"
  value       = azurerm_log_analytics_workspace.example.id
}

# Key Vault Information
output "key_vault_id" {
  description = "ID of the Key Vault for SAS token storage"
  value       = azurerm_key_vault.example.id
}

# Security and Compliance Summary
output "security_summary" {
  description = "Summary of security and compliance features"
  value = {
    diagnostics_enabled     = true
    blob_versioning_enabled = module.storage_account_enhanced.blob_versioning_enabled
    container_immutability  = "enabled for audit and compliance containers"
    sas_token_in_key_vault  = module.storage_account_enhanced.key_vault_sas_secret_id != null
    https_only              = true
    min_tls_version         = "TLS1_2"
    public_access_disabled  = true
  }
}
