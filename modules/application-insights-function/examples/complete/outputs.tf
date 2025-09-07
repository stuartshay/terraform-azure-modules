# Outputs for the complete Application Insights Function monitoring example

output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.example.name
}

output "resource_group_id" {
  description = "The ID of the resource group"
  value       = azurerm_resource_group.example.id
}

output "application_insights_name" {
  description = "The name of the Application Insights instance"
  value       = azurerm_application_insights.example.name
}

output "application_insights_id" {
  description = "The ID of the Application Insights instance"
  value       = azurerm_application_insights.example.id
}

output "application_insights_instrumentation_key" {
  description = "The instrumentation key of the Application Insights instance"
  value       = azurerm_application_insights.example.instrumentation_key
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "The connection string of the Application Insights instance"
  value       = azurerm_application_insights.example.connection_string
  sensitive   = true
}

output "log_analytics_workspace_name" {
  description = "The name of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.example.name
}

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.example.id
}

output "function_app_names" {
  description = "The names of the created Function Apps"
  value       = [for app in azurerm_linux_function_app.example : app.name]
}

output "function_app_ids" {
  description = "The IDs of the created Function Apps"
  value       = [for app in azurerm_linux_function_app.example : app.id]
}

output "app_service_plan_name" {
  description = "The name of the App Service Plan"
  value       = azurerm_service_plan.example.name
}

output "app_service_plan_id" {
  description = "The ID of the App Service Plan"
  value       = azurerm_service_plan.example.id
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = azurerm_storage_account.example.name
}

output "storage_account_id" {
  description = "The ID of the storage account"
  value       = azurerm_storage_account.example.id
}

# Monitoring module outputs
output "function_monitoring_alert_summary" {
  description = "Summary of configured alerts"
  value       = module.function_monitoring.alert_summary
}

output "function_monitoring_dashboard_id" {
  description = "The ID of the function monitoring dashboard"
  value       = module.function_monitoring.function_dashboard_id
}

output "function_monitoring_configuration" {
  description = "Summary of Function App monitoring configuration"
  value       = module.function_monitoring.function_monitoring_configuration
}
