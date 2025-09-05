# Basic Example Outputs for Application Insights Network Module

# Application Insights Information
output "application_insights_id" {
  description = "ID of the Application Insights instance"
  value       = azurerm_application_insights.example.id
}

output "application_insights_name" {
  description = "Name of the Application Insights instance"
  value       = azurerm_application_insights.example.name
}

output "application_insights_connection_string" {
  description = "Connection string for the Application Insights instance"
  value       = azurerm_application_insights.example.connection_string
  sensitive   = true
}

# Log Analytics Workspace Information
output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.example.id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.example.name
}

# Module Outputs
output "alert_rule_names" {
  description = "Names of the created alert rules"
  value       = module.app_insights_network.alert_rule_names
}

output "dashboard_id" {
  description = "ID of the created dashboard"
  value       = module.app_insights_network.dashboard_id
}

output "dashboard_display_name" {
  description = "Display name of the created dashboard"
  value       = module.app_insights_network.dashboard_display_name
}

output "monitoring_configuration" {
  description = "Summary of the monitoring configuration"
  value       = module.app_insights_network.configuration
}

# Resource Group Information
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.example.name
}

output "location" {
  description = "Azure region where resources are deployed"
  value       = azurerm_resource_group.example.location
}
