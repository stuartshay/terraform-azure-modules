# Application Insights Module - Outputs
# This file defines outputs from the application insights module

# Application Insights Outputs
output "id" {
  description = "ID of the Application Insights instance"
  value       = azurerm_application_insights.main.id
}

output "name" {
  description = "Name of the Application Insights instance"
  value       = azurerm_application_insights.main.name
}

output "instrumentation_key" {
  description = "Instrumentation key for Application Insights"
  value       = azurerm_application_insights.main.instrumentation_key
  sensitive   = true
}

output "connection_string" {
  description = "Connection string for Application Insights"
  value       = azurerm_application_insights.main.connection_string
  sensitive   = true
}

output "app_id" {
  description = "App ID for Application Insights"
  value       = azurerm_application_insights.main.app_id
}

output "application_type" {
  description = "Application type of the Application Insights instance"
  value       = azurerm_application_insights.main.application_type
}

output "workspace_id" {
  description = "Workspace ID associated with Application Insights (if workspace-based)"
  value       = azurerm_application_insights.main.workspace_id
}

# Smart Detection Rule Outputs
output "smart_detection_rule_ids" {
  description = "Map of smart detection rule IDs"
  value = var.enable_smart_detection ? {
    failure_anomalies     = azurerm_application_insights_smart_detection_rule.failure_anomalies[0].id
    performance_anomalies = azurerm_application_insights_smart_detection_rule.performance_anomalies[0].id
    trace_severity        = azurerm_application_insights_smart_detection_rule.trace_severity[0].id
    exception_volume      = azurerm_application_insights_smart_detection_rule.exception_volume[0].id
    memory_leak           = azurerm_application_insights_smart_detection_rule.memory_leak[0].id
    security_detection    = azurerm_application_insights_smart_detection_rule.security_detection[0].id
  } : {}
}

# Workbook Outputs
output "workbook_id" {
  description = "ID of the Application Insights workbook"
  value       = var.enable_workbook ? azurerm_application_insights_workbook.main[0].id : null
}

output "workbook_name" {
  description = "Name of the Application Insights workbook"
  value       = var.enable_workbook ? azurerm_application_insights_workbook.main[0].name : null
}

# API Key Outputs
output "api_key_id" {
  description = "ID of the Application Insights API key"
  value       = var.create_api_key ? azurerm_application_insights_api_key.main[0].id : null
}

output "api_key" {
  description = "Application Insights API key"
  value       = var.create_api_key ? azurerm_application_insights_api_key.main[0].api_key : null
  sensitive   = true
}

# Web Test Outputs
output "web_test_ids" {
  description = "Map of web test IDs"
  value       = { for k, v in azurerm_application_insights_standard_web_test.main : k => v.id }
}

output "web_test_synthetic_monitor_ids" {
  description = "Map of web test synthetic monitor IDs"
  value       = { for k, v in azurerm_application_insights_standard_web_test.main : k => v.synthetic_monitor_id }
}

# Configuration Summary
output "configuration" {
  description = "Summary of Application Insights configuration"
  value = {
    name                = azurerm_application_insights.main.name
    application_type    = azurerm_application_insights.main.application_type
    sampling_percentage = azurerm_application_insights.main.sampling_percentage
    workspace_based     = azurerm_application_insights.main.workspace_id != null
    workspace_id        = azurerm_application_insights.main.workspace_id
    retention_in_days   = azurerm_application_insights.main.retention_in_days
    daily_data_cap_gb   = azurerm_application_insights.main.daily_data_cap_in_gb
    features_enabled = {
      smart_detection = var.enable_smart_detection
      workbook        = var.enable_workbook
      api_key         = var.create_api_key
      web_tests       = length(var.web_tests) > 0
    }
    smart_detection_rules = var.enable_smart_detection ? {
      failure_anomalies     = var.smart_detection_failure_anomalies_enabled
      performance_anomalies = var.smart_detection_performance_anomalies_enabled
      trace_severity        = var.smart_detection_trace_severity_enabled
      exception_volume      = var.smart_detection_exception_volume_enabled
      memory_leak           = var.smart_detection_memory_leak_enabled
      security_detection    = var.smart_detection_security_detection_enabled
    } : {}
  }
}

# Resource Information
output "resource_group_name" {
  description = "Resource group name where Application Insights is deployed"
  value       = azurerm_application_insights.main.resource_group_name
}

output "location" {
  description = "Azure region where Application Insights is deployed"
  value       = azurerm_application_insights.main.location
}

output "tags" {
  description = "Tags applied to the Application Insights instance"
  value       = azurerm_application_insights.main.tags
}
