# Basic Application Insights Function Example - Outputs

# Function Alert Information
output "alert_rule_names" {
  description = "Names of the created alert rules"
  value       = module.app_insights_function.alert_rule_names
}

output "function_duration_alert_id" {
  description = "ID of the function duration alert rule"
  value       = module.app_insights_function.function_duration_alert_id
}

output "function_failure_alert_id" {
  description = "ID of the function failure alert rule"
  value       = module.app_insights_function.function_failure_alert_id
}

# App Service Plan Alert Information
output "app_service_alert_names" {
  description = "Names of the App Service Plan alert rules"
  value       = module.app_insights_function.app_service_alert_names
}

output "app_service_cpu_alert_ids" {
  description = "IDs of the App Service Plan CPU alert rules"
  value       = module.app_insights_function.app_service_cpu_alert_ids
}

output "app_service_memory_alert_ids" {
  description = "IDs of the App Service Plan memory alert rules"
  value       = module.app_insights_function.app_service_memory_alert_ids
}

# Dashboard Information
output "function_dashboard_id" {
  description = "ID of the Function monitoring dashboard"
  value       = module.app_insights_function.function_dashboard_id
}

output "function_dashboard_display_name" {
  description = "Display name of the Function monitoring dashboard"
  value       = module.app_insights_function.function_dashboard_display_name
}

# Configuration Summary
output "function_monitoring_configuration" {
  description = "Complete Function monitoring configuration summary"
  value       = module.app_insights_function.function_monitoring_configuration
}

output "alert_summary" {
  description = "Summary of configured alerts"
  value       = module.app_insights_function.alert_summary
}

output "dashboard_summary" {
  description = "Summary of dashboard configuration"
  value       = module.app_insights_function.dashboard_summary
}

# Resource Information
output "resource_group_name" {
  description = "Name of the monitored resource group"
  value       = module.app_insights_function.resource_group_name
}

output "application_insights_name" {
  description = "Name of the monitored Application Insights instance"
  value       = module.app_insights_function.application_insights_name
}

output "monitored_function_apps" {
  description = "Information about monitored Function Apps"
  value       = module.app_insights_function.monitored_function_apps
}

output "monitored_app_service_plans" {
  description = "Information about monitored App Service Plans"
  value       = module.app_insights_function.monitored_app_service_plans
}

# Feature Flags
output "feature_flags" {
  description = "Summary of enabled features"
  value       = module.app_insights_function.feature_flags
}

# Example Resource Information
output "example_function_app_name" {
  description = "Name of the example Function App"
  value       = azurerm_linux_function_app.example.name
}

output "example_app_service_plan_name" {
  description = "Name of the example App Service Plan"
  value       = azurerm_service_plan.example.name
}

output "example_application_insights_name" {
  description = "Name of the example Application Insights instance"
  value       = azurerm_application_insights.example.name
}
