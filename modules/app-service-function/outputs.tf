output "function_app_id" {
  description = "The ID of the Function App"
  value       = azurerm_linux_function_app.main.id
}

output "function_app_name" {
  description = "The name of the Function App"
  value       = azurerm_linux_function_app.main.name
}

output "function_app_default_hostname" {
  description = "The default hostname of the Function App"
  value       = azurerm_linux_function_app.main.default_hostname
}

output "app_service_plan_id" {
  description = "The ID of the App Service Plan"
  value       = azurerm_service_plan.functions.id
}

output "storage_account_name" {
  description = "The name of the Functions storage account"
  value       = module.functions_storage.storage_account_name
}

output "storage_account_id" {
  description = "The ID of the Functions storage account"
  value       = module.functions_storage.storage_account_id
}

output "application_insights_connection_string" {
  description = "Application Insights connection string"
  value       = var.enable_application_insights ? azurerm_application_insights.functions[0].connection_string : null
  sensitive   = true
}

output "application_insights_instrumentation_key" {
  description = "Application Insights instrumentation key"
  value       = var.enable_application_insights ? azurerm_application_insights.functions[0].instrumentation_key : null
  sensitive   = true
}

output "application_insights_id" {
  description = "The ID of Application Insights"
  value       = var.enable_application_insights ? azurerm_application_insights.functions[0].id : null
}

# Additional storage account outputs for backward compatibility
output "storage_account_primary_access_key" {
  description = "The primary access key for the Functions storage account"
  value       = module.functions_storage.primary_access_key
  sensitive   = true
}

output "storage_account_primary_connection_string" {
  description = "The primary connection string for the Functions storage account"
  value       = module.functions_storage.primary_connection_string
  sensitive   = true
}

output "storage_account_primary_blob_endpoint" {
  description = "The primary blob endpoint for the Functions storage account"
  value       = module.functions_storage.primary_blob_endpoint
}
