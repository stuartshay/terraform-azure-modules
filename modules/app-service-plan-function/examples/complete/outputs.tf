output "app_service_plan_id" {
  description = "The ID of the App Service Plan"
  value       = module.function_app_service_plan.app_service_plan_id
}

output "app_service_plan_name" {
  description = "The name of the App Service Plan"
  value       = module.function_app_service_plan.app_service_plan_name
}

output "app_service_plan_sku" {
  description = "The SKU of the App Service Plan"
  value       = module.function_app_service_plan.app_service_plan_sku
}

output "app_service_plan_os_type" {
  description = "The operating system type of the App Service Plan"
  value       = module.function_app_service_plan.app_service_plan_os_type
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = azurerm_storage_account.functions.name
}

output "application_insights_connection_string" {
  description = "Application Insights connection string"
  value       = azurerm_application_insights.functions.connection_string
  sensitive   = true
}
