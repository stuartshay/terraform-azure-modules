# Complete Example Outputs

output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.example.name
}

output "virtual_network_id" {
  description = "ID of the created virtual network"
  value       = azurerm_virtual_network.example.id
}

output "function_app_ids" {
  description = "IDs of the created Function Apps"
  value = {
    basic    = azurerm_linux_function_app.example_basic.id
    advanced = azurerm_linux_function_app.example_advanced.id
  }
}

# Monitoring Module Outputs
output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics Workspace"
  value       = module.monitoring.log_analytics_workspace_id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace"
  value       = module.monitoring.log_analytics_workspace_name
}

output "application_insights_id" {
  description = "ID of the Application Insights instance"
  value       = module.monitoring.application_insights_id
}

output "application_insights_name" {
  description = "Name of the Application Insights instance"
  value       = module.monitoring.application_insights_name
}

output "application_insights_connection_string" {
  description = "Connection string for Application Insights"
  value       = module.monitoring.application_insights_connection_string
  sensitive   = true
}

output "application_insights_instrumentation_key" {
  description = "Instrumentation key for Application Insights"
  value       = module.monitoring.application_insights_instrumentation_key
  sensitive   = true
}

output "action_group_id" {
  description = "ID of the monitoring action group"
  value       = module.monitoring.action_group_id
}

output "action_group_name" {
  description = "Name of the monitoring action group"
  value       = module.monitoring.action_group_name
}

output "monitoring_storage_account_id" {
  description = "ID of the monitoring storage account"
  value       = module.monitoring.monitoring_storage_account_id
}

output "log_analytics_private_endpoint_id" {
  description = "ID of the Log Analytics private endpoint"
  value       = module.monitoring.log_analytics_private_endpoint_id
}

output "monitoring_workbook_id" {
  description = "ID of the monitoring workbook"
  value       = module.monitoring.monitoring_workbook_id
}

output "metric_alert_ids" {
  description = "Map of metric alert IDs by function app"
  value       = module.monitoring.metric_alert_ids
}

output "log_alert_ids" {
  description = "List of log query alert IDs"
  value       = module.monitoring.log_alert_ids
}

output "activity_log_alert_ids" {
  description = "List of activity log alert IDs"
  value       = module.monitoring.activity_log_alert_ids
}

output "smart_detection_rule_ids" {
  description = "List of smart detection rule IDs"
  value       = module.monitoring.smart_detection_rule_ids
}

output "budget_alert_id" {
  description = "ID of the budget alert"
  value       = module.monitoring.budget_alert_id
}

output "monitoring_configuration" {
  description = "Summary of monitoring configuration"
  value       = module.monitoring.monitoring_configuration
}

output "resource_names" {
  description = "Names of created monitoring resources"
  value       = module.monitoring.resource_names
}
