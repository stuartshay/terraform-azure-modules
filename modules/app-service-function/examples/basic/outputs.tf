output "function_app_name" {
  description = "The name of the Function App"
  value       = module.function_app.function_app_name
}

output "function_app_default_hostname" {
  description = "The default hostname of the Function App"
  value       = module.function_app.function_app_default_hostname
}

output "storage_account_name" {
  description = "The name of the Functions storage account"
  value       = module.function_app.storage_account_name
}

output "app_service_plan_id" {
  description = "The ID of the App Service Plan"
  value       = module.function_app.app_service_plan_id
}

output "application_insights_connection_string" {
  description = "Application Insights connection string"
  value       = module.function_app.application_insights_connection_string
  sensitive   = true
}
