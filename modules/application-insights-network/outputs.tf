# Application Insights Network Module - Outputs
# This file defines outputs from the application insights network module

# Alert Rule Outputs
output "response_time_alert_id" {
  description = "ID of the response time alert rule"
  value       = var.enable_response_time_alert ? azurerm_monitor_metric_alert.response_time[0].id : null
}

output "failed_request_alert_id" {
  description = "ID of the failed request alert rule"
  value       = var.enable_failed_request_alert ? azurerm_monitor_metric_alert.failed_request_rate[0].id : null
}

output "exception_alert_id" {
  description = "ID of the exception alert rule"
  value       = var.enable_exception_alert ? azurerm_monitor_metric_alert.exception_rate[0].id : null
}

output "availability_alert_id" {
  description = "ID of the availability alert rule"
  value       = var.enable_availability_alert ? azurerm_monitor_metric_alert.availability[0].id : null
}

output "server_error_alert_id" {
  description = "ID of the server error alert rule"
  value       = var.enable_server_error_alert ? azurerm_monitor_metric_alert.server_errors[0].id : null
}

# Alert Rule Names
output "alert_rule_names" {
  description = "Map of alert rule names"
  value = {
    response_time   = var.enable_response_time_alert ? azurerm_monitor_metric_alert.response_time[0].name : null
    failed_requests = var.enable_failed_request_alert ? azurerm_monitor_metric_alert.failed_request_rate[0].name : null
    exceptions      = var.enable_exception_alert ? azurerm_monitor_metric_alert.exception_rate[0].name : null
    availability    = var.enable_availability_alert ? azurerm_monitor_metric_alert.availability[0].name : null
    server_errors   = var.enable_server_error_alert ? azurerm_monitor_metric_alert.server_errors[0].name : null
  }
}

# Dashboard Outputs
output "dashboard_id" {
  description = "ID of the Application Insights dashboard"
  value       = var.enable_dashboard ? azurerm_application_insights_workbook.dashboard[0].id : null
}

output "dashboard_name" {
  description = "Name of the Application Insights dashboard"
  value       = var.enable_dashboard ? azurerm_application_insights_workbook.dashboard[0].name : null
}

output "dashboard_display_name" {
  description = "Display name of the Application Insights dashboard"
  value       = var.enable_dashboard ? azurerm_application_insights_workbook.dashboard[0].display_name : null
}

# Application Insights Information
output "application_insights_id" {
  description = "ID of the monitored Application Insights instance"
  value       = data.azurerm_application_insights.main.id
}

output "application_insights_name" {
  description = "Name of the monitored Application Insights instance"
  value       = data.azurerm_application_insights.main.name
}

output "application_insights_app_id" {
  description = "App ID of the monitored Application Insights instance"
  value       = data.azurerm_application_insights.main.app_id
}

# Log Analytics Workspace Information (if provided)
output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics Workspace (if provided)"
  value       = var.log_analytics_workspace_name != null ? data.azurerm_log_analytics_workspace.main[0].id : null
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace (if provided)"
  value       = var.log_analytics_workspace_name != null ? data.azurerm_log_analytics_workspace.main[0].name : null
}

# Configuration Summary
output "configuration" {
  description = "Summary of Application Insights Network monitoring configuration"
  value = {
    application_insights_name = data.azurerm_application_insights.main.name
    alerts_enabled = {
      response_time   = var.enable_response_time_alert
      failed_requests = var.enable_failed_request_alert
      exceptions      = var.enable_exception_alert
      availability    = var.enable_availability_alert
      server_errors   = var.enable_server_error_alert
    }
    alert_thresholds = {
      response_time_ms     = var.response_time_threshold_ms
      failed_request_rate  = var.failed_request_rate_threshold
      exception_rate       = var.exception_rate_threshold
      availability_percent = var.availability_threshold_percent
      server_error_count   = var.server_error_threshold
    }
    dashboard_enabled       = var.enable_dashboard
    log_analytics_workspace = var.log_analytics_workspace_name
  }
}

# Resource Information
output "resource_group_name" {
  description = "Resource group name where monitoring resources are deployed"
  value       = var.resource_group_name
}

output "location" {
  description = "Azure region where monitoring resources are deployed"
  value       = var.location
}

output "tags" {
  description = "Tags applied to the monitoring resources"
  value       = var.tags
}
