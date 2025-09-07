# Application Insights Billing Module - Outputs
# This file defines outputs from the application insights billing module

# Budget Outputs
output "monthly_budget_id" {
  description = "ID of the monthly budget"
  value       = var.enable_budget_monitoring && var.monthly_budget_amount > 0 ? azurerm_consumption_budget_resource_group.monthly[0].id : null
}

output "quarterly_budget_id" {
  description = "ID of the quarterly budget"
  value       = var.enable_budget_monitoring && var.quarterly_budget_amount > 0 ? azurerm_consumption_budget_resource_group.quarterly[0].id : null
}

output "annual_budget_id" {
  description = "ID of the annual budget"
  value       = var.enable_budget_monitoring && var.annual_budget_amount > 0 ? azurerm_consumption_budget_resource_group.annual[0].id : null
}

# Budget Names
output "budget_names" {
  description = "Map of budget names"
  value = {
    monthly   = var.enable_budget_monitoring && var.monthly_budget_amount > 0 ? azurerm_consumption_budget_resource_group.monthly[0].name : null
    quarterly = var.enable_budget_monitoring && var.quarterly_budget_amount > 0 ? azurerm_consumption_budget_resource_group.quarterly[0].name : null
    annual    = var.enable_budget_monitoring && var.annual_budget_amount > 0 ? azurerm_consumption_budget_resource_group.annual[0].name : null
  }
}

# Cost Alert Outputs
output "daily_cost_alert_id" {
  description = "ID of the daily cost alert rule"
  value       = var.enable_cost_alerts && var.log_analytics_workspace_name != null ? azurerm_monitor_scheduled_query_rules_alert_v2.daily_cost[0].id : null
}

output "cost_anomaly_alert_id" {
  description = "ID of the cost anomaly alert rule"
  value       = var.enable_cost_alerts && var.enable_anomaly_detection && var.log_analytics_workspace_name != null ? azurerm_monitor_scheduled_query_rules_alert_v2.cost_anomaly[0].id : null
}

# Alert Rule Names
output "alert_rule_names" {
  description = "Map of alert rule names"
  value = {
    daily_cost   = var.enable_cost_alerts && var.log_analytics_workspace_name != null ? azurerm_monitor_scheduled_query_rules_alert_v2.daily_cost[0].name : null
    cost_anomaly = var.enable_cost_alerts && var.enable_anomaly_detection && var.log_analytics_workspace_name != null ? azurerm_monitor_scheduled_query_rules_alert_v2.cost_anomaly[0].name : null
  }
}

# Dashboard Outputs
output "billing_dashboard_id" {
  description = "ID of the billing dashboard"
  value       = var.enable_billing_dashboard ? azurerm_application_insights_workbook.billing_dashboard[0].id : null
}

output "billing_dashboard_name" {
  description = "Name of the billing dashboard"
  value       = var.enable_billing_dashboard ? azurerm_application_insights_workbook.billing_dashboard[0].name : null
}

output "billing_dashboard_display_name" {
  description = "Display name of the billing dashboard"
  value       = var.enable_billing_dashboard ? azurerm_application_insights_workbook.billing_dashboard[0].display_name : null
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

# Resource Group Information
output "resource_group_id" {
  description = "ID of the monitored resource group"
  value       = data.azurerm_resource_group.main.id
}

output "resource_group_name" {
  description = "Name of the monitored resource group"
  value       = data.azurerm_resource_group.main.name
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
output "billing_configuration" {
  description = "Summary of billing monitoring configuration"
  value = {
    resource_group_name       = data.azurerm_resource_group.main.name
    application_insights_name = data.azurerm_application_insights.main.name
    budgets_enabled = {
      monthly   = var.enable_budget_monitoring && var.monthly_budget_amount > 0
      quarterly = var.enable_budget_monitoring && var.quarterly_budget_amount > 0
      annual    = var.enable_budget_monitoring && var.annual_budget_amount > 0
    }
    budget_amounts = {
      monthly   = var.monthly_budget_amount
      quarterly = var.quarterly_budget_amount
      annual    = var.annual_budget_amount
    }
    alerts_enabled = {
      daily_cost      = var.enable_cost_alerts && var.log_analytics_workspace_name != null
      cost_anomaly    = var.enable_cost_alerts && var.enable_anomaly_detection && var.log_analytics_workspace_name != null
      budget_alerts   = var.enable_budget_monitoring
      forecast_alerts = var.enable_forecast_alerts
    }
    alert_thresholds = {
      daily_spend_usd        = var.daily_spend_threshold
      budget_alert_percent   = var.budget_alert_thresholds
      forecast_alert_percent = var.budget_forecast_thresholds
      anomaly_sensitivity    = var.cost_anomaly_sensitivity
    }
    dashboard_enabled       = var.enable_billing_dashboard
    log_analytics_workspace = var.log_analytics_workspace_name
    notification_emails     = var.budget_notification_emails
    cost_filters = {
      resource_types = var.cost_filter_resource_types
      tags           = var.cost_filter_tags
    }
  }
}

# Budget Summary
output "budget_summary" {
  description = "Summary of configured budgets"
  value = {
    total_monthly_budget   = var.monthly_budget_amount
    total_quarterly_budget = var.quarterly_budget_amount
    total_annual_budget    = var.annual_budget_amount
    alert_thresholds       = var.budget_alert_thresholds
    forecast_thresholds    = var.budget_forecast_thresholds
    notification_emails    = var.budget_notification_emails
    budget_end_date        = var.budget_end_date
  }
}

# Alert Summary
output "alert_summary" {
  description = "Summary of configured alerts"
  value = {
    cost_alerts_enabled       = var.enable_cost_alerts
    anomaly_detection_enabled = var.enable_anomaly_detection
    daily_threshold_usd       = var.daily_spend_threshold
    anomaly_sensitivity       = var.cost_anomaly_sensitivity
    daily_alert_severity      = var.daily_cost_alert_severity
    anomaly_alert_severity    = var.anomaly_alert_severity
    requires_log_analytics    = var.enable_cost_alerts
  }
}

# Resource Information
output "location" {
  description = "Azure region where billing resources are deployed"
  value       = var.location
}

output "tags" {
  description = "Tags applied to the billing resources"
  value       = var.tags
}
