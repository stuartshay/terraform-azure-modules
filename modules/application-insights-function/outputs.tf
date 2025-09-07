# Application Insights Function Module - Outputs
# This file defines outputs from the application insights function module

# Function Alert Outputs
output "function_duration_alert_id" {
  description = "ID of the function duration alert rule"
  value       = var.enable_function_alerts ? azurerm_monitor_metric_alert.function_duration[0].id : null
}

output "function_failure_alert_id" {
  description = "ID of the function failure rate alert rule"
  value       = var.enable_function_alerts ? azurerm_monitor_metric_alert.function_failure_rate[0].id : null
}

output "function_low_activity_alert_id" {
  description = "ID of the function low activity alert rule"
  value       = var.enable_function_alerts && var.function_min_invocations_threshold > 0 ? azurerm_monitor_metric_alert.function_low_activity[0].id : null
}

# App Service Plan Alert Outputs
output "app_service_cpu_alert_ids" {
  description = "Map of App Service Plan CPU alert rule IDs"
  value = var.enable_app_service_alerts && var.app_service_plan_names != null ? {
    for name in var.app_service_plan_names : name => azurerm_monitor_metric_alert.app_service_cpu[name].id
  } : {}
}

output "app_service_memory_alert_ids" {
  description = "Map of App Service Plan memory alert rule IDs"
  value = var.enable_app_service_alerts && var.app_service_plan_names != null ? {
    for name in var.app_service_plan_names : name => azurerm_monitor_metric_alert.app_service_memory[name].id
  } : {}
}

# Advanced Alert Outputs
output "cold_start_alert_id" {
  description = "ID of the cold start detection alert rule"
  value       = var.enable_function_alerts && var.enable_cold_start_detection && var.log_analytics_workspace_name != null ? azurerm_monitor_scheduled_query_rules_alert_v2.cold_starts[0].id : null
}

output "exception_alert_id" {
  description = "ID of the function exception alert rule"
  value       = var.enable_function_alerts && var.enable_exception_detection && var.log_analytics_workspace_name != null ? azurerm_monitor_scheduled_query_rules_alert_v2.function_exceptions[0].id : null
}

# Alert Rule Names
output "alert_rule_names" {
  description = "Map of alert rule names"
  value = {
    function_duration     = var.enable_function_alerts ? azurerm_monitor_metric_alert.function_duration[0].name : null
    function_failures     = var.enable_function_alerts ? azurerm_monitor_metric_alert.function_failure_rate[0].name : null
    function_low_activity = var.enable_function_alerts && var.function_min_invocations_threshold > 0 ? azurerm_monitor_metric_alert.function_low_activity[0].name : null
    cold_starts           = var.enable_function_alerts && var.enable_cold_start_detection && var.log_analytics_workspace_name != null ? azurerm_monitor_scheduled_query_rules_alert_v2.cold_starts[0].name : null
    exceptions            = var.enable_function_alerts && var.enable_exception_detection && var.log_analytics_workspace_name != null ? azurerm_monitor_scheduled_query_rules_alert_v2.function_exceptions[0].name : null
  }
}

output "app_service_alert_names" {
  description = "Map of App Service Plan alert rule names"
  value = {
    cpu_alerts = var.enable_app_service_alerts && var.app_service_plan_names != null ? {
      for name in var.app_service_plan_names : name => azurerm_monitor_metric_alert.app_service_cpu[name].name
    } : {}
    memory_alerts = var.enable_app_service_alerts && var.app_service_plan_names != null ? {
      for name in var.app_service_plan_names : name => azurerm_monitor_metric_alert.app_service_memory[name].name
    } : {}
  }
}

# Dashboard Outputs
output "function_dashboard_id" {
  description = "ID of the Function App monitoring dashboard"
  value       = var.enable_function_dashboard ? azurerm_application_insights_workbook.function_dashboard[0].id : null
}

output "function_dashboard_name" {
  description = "Name of the Function App monitoring dashboard"
  value       = var.enable_function_dashboard ? azurerm_application_insights_workbook.function_dashboard[0].name : null
}

output "function_dashboard_display_name" {
  description = "Display name of the Function App monitoring dashboard"
  value       = var.enable_function_dashboard ? azurerm_application_insights_workbook.function_dashboard[0].display_name : null
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

# Function App Information
output "monitored_function_apps" {
  description = "Information about monitored Function Apps"
  value = var.function_app_names != null ? {
    for name in var.function_app_names : name => {
      id       = data.azurerm_linux_function_app.functions[name].id
      name     = data.azurerm_linux_function_app.functions[name].name
      location = data.azurerm_linux_function_app.functions[name].location
    }
  } : {}
}

# App Service Plan Information
output "monitored_app_service_plans" {
  description = "Information about monitored App Service Plans"
  value = var.app_service_plan_names != null ? {
    for name in var.app_service_plan_names : name => {
      id       = data.azurerm_service_plan.plans[name].id
      name     = data.azurerm_service_plan.plans[name].name
      location = data.azurerm_service_plan.plans[name].location
      sku_name = data.azurerm_service_plan.plans[name].sku_name
      os_type  = data.azurerm_service_plan.plans[name].os_type
    }
  } : {}
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
output "function_monitoring_configuration" {
  description = "Summary of Function App monitoring configuration"
  value = {
    resource_group_name         = data.azurerm_resource_group.main.name
    application_insights_name   = data.azurerm_application_insights.main.name
    monitored_function_apps     = var.function_app_names
    monitored_app_service_plans = var.app_service_plan_names
    alerts_enabled = {
      function_alerts      = var.enable_function_alerts
      app_service_alerts   = var.enable_app_service_alerts
      cold_start_detection = var.enable_cold_start_detection
      exception_detection  = var.enable_exception_detection
    }
    alert_thresholds = {
      function_duration_ms     = var.function_duration_threshold_ms
      function_failure_rate    = var.function_failure_rate_threshold
      cpu_threshold_percent    = var.cpu_threshold_percent
      memory_threshold_percent = var.memory_threshold_percent
      cold_start_threshold     = var.cold_start_threshold
      exception_rate_threshold = var.exception_rate_threshold
    }
    dashboard_enabled         = var.enable_function_dashboard
    log_analytics_workspace   = var.log_analytics_workspace_name
    dashboard_time_range_days = var.dashboard_time_range
  }
}

# Alert Summary
output "alert_summary" {
  description = "Summary of configured alerts"
  value = {
    function_alerts = {
      duration_alert_enabled     = var.enable_function_alerts
      failure_alert_enabled      = var.enable_function_alerts
      low_activity_alert_enabled = var.enable_function_alerts && var.function_min_invocations_threshold > 0
      cold_start_alert_enabled   = var.enable_function_alerts && var.enable_cold_start_detection
      exception_alert_enabled    = var.enable_function_alerts && var.enable_exception_detection
    }
    app_service_alerts = {
      cpu_alerts_enabled    = var.enable_app_service_alerts
      memory_alerts_enabled = var.enable_app_service_alerts
      monitored_plans_count = var.app_service_plan_names != null ? length(var.app_service_plan_names) : 0
    }
    alert_severities = {
      function_duration_severity = var.function_duration_alert_severity
      function_failure_severity  = var.function_failure_alert_severity
      function_activity_severity = var.function_activity_alert_severity
      cpu_alert_severity         = var.app_service_cpu_alert_severity
      memory_alert_severity      = var.app_service_memory_alert_severity
      cold_start_severity        = var.cold_start_alert_severity
      exception_severity         = var.exception_alert_severity
    }
    requires_log_analytics = var.enable_cold_start_detection || var.enable_exception_detection
  }
}

# Dashboard Summary
output "dashboard_summary" {
  description = "Summary of dashboard configuration"
  value = {
    dashboard_enabled    = var.enable_function_dashboard
    dashboard_name       = var.enable_function_dashboard ? azurerm_application_insights_workbook.function_dashboard[0].display_name : null
    time_range_days      = var.dashboard_time_range
    dependency_tracking  = var.enable_dependency_tracking
    performance_counters = var.enable_performance_counters
    custom_metrics       = var.enable_custom_metrics
    monitored_apps_count = var.function_app_names != null ? length(var.function_app_names) : 0
  }
}

# Resource Information
output "location" {
  description = "Azure region where monitoring resources are deployed"
  value       = var.location
}

output "tags" {
  description = "Tags applied to the monitoring resources"
  value       = var.tags
}

# Feature Flags
output "feature_flags" {
  description = "Summary of enabled features"
  value = {
    function_alerts_enabled      = var.enable_function_alerts
    app_service_alerts_enabled   = var.enable_app_service_alerts
    cold_start_detection_enabled = var.enable_cold_start_detection
    exception_detection_enabled  = var.enable_exception_detection
    dashboard_enabled            = var.enable_function_dashboard
    dependency_tracking_enabled  = var.enable_dependency_tracking
    performance_counters_enabled = var.enable_performance_counters
    custom_metrics_enabled       = var.enable_custom_metrics
  }
}
