output "function_app_id" {
  description = "The ID of the Function App"
  value       = module.function_app.function_app_id
}

output "function_app_name" {
  description = "The name of the Function App"
  value       = module.function_app.function_app_name
}

output "function_app_default_hostname" {
  description = "The default hostname of the Function App"
  value       = module.function_app.function_app_default_hostname
}

output "function_app_url" {
  description = "The URL of the Function App"
  value       = "https://${module.function_app.function_app_default_hostname}"
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = module.function_app.storage_account_name
}

output "app_service_plan_id" {
  description = "The ID of the App Service Plan"
  value       = module.app_service_plan.app_service_plan_id
}

output "app_service_plan_name" {
  description = "The name of the App Service Plan"
  value       = module.app_service_plan.app_service_plan_name
}

output "application_insights_instrumentation_key" {
  description = "The Application Insights instrumentation key"
  value       = module.function_app.application_insights_instrumentation_key
  sensitive   = true
}

output "function_app_principal_id" {
  description = "The principal ID of the Function App's managed identity"
  value       = module.function_app.function_app_principal_id
}

output "function_app_summary" {
  description = "Summary of the Function App deployment"
  value       = module.function_app.function_app_summary
}
