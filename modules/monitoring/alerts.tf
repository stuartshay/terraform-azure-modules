# Monitoring Module - Alert Rules Configuration
# This file defines metric alerts, log query alerts, and activity log alerts

# Metric Alerts for Function Apps
resource "azurerm_monitor_metric_alert" "function_app_cpu" {
  for_each = var.monitored_function_apps

  name                = "alert-${each.key}-cpu-high"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.resource_id]
  description         = "High CPU usage on Function App ${each.key}"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "CpuPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.cpu_threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = var.tags
}

# App Service Metric Alerts
resource "azurerm_monitor_metric_alert" "app_service_cpu" {
  for_each = var.enable_app_service_monitoring ? var.monitored_app_services : {}

  name                = "alert-${each.key}-cpu-high"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.resource_id]
  description         = "High CPU usage on App Service ${each.key}"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "CpuPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.cpu_threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = var.tags
}

resource "azurerm_monitor_metric_alert" "app_service_memory" {
  for_each = var.enable_app_service_monitoring ? var.monitored_app_services : {}

  name                = "alert-${each.key}-memory-high"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.resource_id]
  description         = "High memory usage on App Service ${each.key}"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "MemoryPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.memory_threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = var.tags
}

resource "azurerm_monitor_metric_alert" "app_service_http_errors" {
  for_each = var.enable_app_service_monitoring ? var.monitored_app_services : {}

  name                = "alert-${each.key}-http-errors"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.resource_id]
  description         = "High number of HTTP errors on App Service ${each.key}"
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Http5xx"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.error_threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = var.tags
}

resource "azurerm_monitor_metric_alert" "app_service_response_time" {
  for_each = var.enable_app_service_monitoring ? var.monitored_app_services : {}

  name                = "alert-${each.key}-response-time"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.resource_id]
  description         = "High response time on App Service ${each.key}"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "AverageResponseTime"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.response_time_threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = var.tags
}

resource "azurerm_monitor_metric_alert" "app_service_requests" {
  for_each = var.enable_app_service_monitoring ? var.monitored_app_services : {}

  name                = "alert-${each.key}-high-requests"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.resource_id]
  description         = "High number of requests on App Service ${each.key}"
  severity            = 3
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Requests"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 1000 # Configurable threshold for high request volume
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = var.tags
}

# App Service Log Query Alerts
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "app_service_exceptions" {
  count = var.enable_log_alerts && var.enable_app_service_monitoring ? 1 : 0

  name                = "alert-app-service-exceptions"
  resource_group_name = var.resource_group_name
  location            = var.location

  evaluation_frequency = "PT5M"
  window_duration      = "PT15M"
  scopes               = [azurerm_log_analytics_workspace.main.id]
  severity             = 1
  description          = "High number of exceptions in App Services"
  enabled              = true

  criteria {
    query                   = <<-QUERY
      AppServiceConsoleLogs
      | where TimeGenerated > ago(15m)
      | where ResultDescription contains "Exception" or ResultDescription contains "Error"
      | summarize count() by _ResourceId
      | where count_ > ${var.exception_threshold}
    QUERY
    time_aggregation_method = "Count"
    threshold               = 1
    operator                = "GreaterThanOrEqual"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.main.id]
  }

  tags = var.tags
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "app_service_availability" {
  count = var.enable_log_alerts && var.enable_app_service_monitoring ? 1 : 0

  name                = "alert-app-service-availability"
  resource_group_name = var.resource_group_name
  location            = var.location

  evaluation_frequency = "PT5M"
  window_duration      = "PT15M"
  scopes               = [azurerm_log_analytics_workspace.main.id]
  severity             = 1
  description          = "App Service availability issues"
  enabled              = true

  criteria {
    query                   = <<-QUERY
      AppServiceHTTPLogs
      | where TimeGenerated > ago(15m)
      | summarize
          total_requests = count(),
          failed_requests = countif(ScStatus >= 500)
          by _ResourceId
      | extend availability = (total_requests - failed_requests) * 100.0 / total_requests
      | where availability < ${var.availability_threshold}
    QUERY
    time_aggregation_method = "Count"
    threshold               = 1
    operator                = "GreaterThanOrEqual"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.main.id]
  }

  tags = var.tags
}

resource "azurerm_monitor_metric_alert" "function_app_memory" {
  for_each = var.monitored_function_apps

  name                = "alert-${each.key}-memory-high"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.resource_id]
  description         = "High memory usage on Function App ${each.key}"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "MemoryPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.memory_threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = var.tags
}

resource "azurerm_monitor_metric_alert" "function_app_errors" {
  for_each = var.monitored_function_apps

  name                = "alert-${each.key}-http-errors"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.resource_id]
  description         = "High number of HTTP errors on Function App ${each.key}"
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Http5xx"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.error_threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = var.tags
}

resource "azurerm_monitor_metric_alert" "function_app_response_time" {
  for_each = var.monitored_function_apps

  name                = "alert-${each.key}-response-time"
  resource_group_name = var.resource_group_name
  scopes              = [each.value.resource_id]
  description         = "High response time on Function App ${each.key}"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "AverageResponseTime"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.response_time_threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = var.tags
}

# Log Query Alerts
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "function_exceptions" {
  count = var.enable_log_alerts ? 1 : 0

  name                = "alert-function-exceptions"
  resource_group_name = var.resource_group_name
  location            = var.location

  evaluation_frequency = "PT5M"
  window_duration      = "PT15M"
  scopes               = [azurerm_log_analytics_workspace.main.id]
  severity             = 1
  description          = "High number of exceptions in Function Apps"
  enabled              = true

  criteria {
    query                   = <<-QUERY
      exceptions
      | where timestamp > ago(15m)
      | where cloud_RoleName startswith "func-"
      | summarize count() by cloud_RoleName
      | where count_ > ${var.exception_threshold}
    QUERY
    time_aggregation_method = "Count"
    threshold               = 1
    operator                = "GreaterThanOrEqual"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.main.id]
  }

  tags = var.tags
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "function_availability" {
  count = var.enable_log_alerts ? 1 : 0

  name                = "alert-function-availability"
  resource_group_name = var.resource_group_name
  location            = var.location

  evaluation_frequency = "PT5M"
  window_duration      = "PT15M"
  scopes               = [azurerm_log_analytics_workspace.main.id]
  severity             = 1
  description          = "Function App availability issues"
  enabled              = true

  criteria {
    query                   = <<-QUERY
      requests
      | where timestamp > ago(15m)
      | where cloud_RoleName startswith "func-"
      | summarize
          total_requests = count(),
          failed_requests = countif(success == false)
          by cloud_RoleName
      | extend availability = (total_requests - failed_requests) * 100.0 / total_requests
      | where availability < ${var.availability_threshold}
    QUERY
    time_aggregation_method = "Count"
    threshold               = 1
    operator                = "GreaterThanOrEqual"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.main.id]
  }

  tags = var.tags
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "function_performance" {
  count = var.enable_log_alerts ? 1 : 0

  name                = "alert-function-performance"
  resource_group_name = var.resource_group_name
  location            = var.location

  evaluation_frequency = "PT5M"
  window_duration      = "PT15M"
  scopes               = [azurerm_log_analytics_workspace.main.id]
  severity             = 2
  description          = "Function App performance degradation"
  enabled              = true

  criteria {
    query                   = <<-QUERY
      requests
      | where timestamp > ago(15m)
      | where cloud_RoleName startswith "func-"
      | summarize avg_duration = avg(duration) by cloud_RoleName
      | where avg_duration > ${var.performance_threshold}
    QUERY
    time_aggregation_method = "Count"
    threshold               = 1
    operator                = "GreaterThanOrEqual"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.main.id]
  }

  tags = var.tags
}

# Activity Log Alerts
resource "azurerm_monitor_activity_log_alert" "resource_health" {
  count = var.enable_activity_log_alerts ? 1 : 0

  name                = "alert-resource-health"
  resource_group_name = var.resource_group_name
  location            = "global"
  scopes              = ["/subscriptions/${var.subscription_id}"]
  description         = "Resource health degradation alert"

  criteria {
    category = "ResourceHealth"

    resource_health {
      current  = ["Degraded", "Unavailable"]
      previous = ["Available"]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = var.tags
}

resource "azurerm_monitor_activity_log_alert" "service_health" {
  count = var.enable_activity_log_alerts ? 1 : 0

  name                = "alert-service-health"
  resource_group_name = var.resource_group_name
  location            = "global"
  scopes              = ["/subscriptions/${var.subscription_id}"]
  description         = "Azure service health issues"

  criteria {
    category = "ServiceHealth"

    service_health {
      events    = ["Incident", "Maintenance"]
      locations = [var.location]
      services  = ["App Service", "Application Insights", "Log Analytics"]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = var.tags
}

# Budget Alert (if enabled)
resource "azurerm_consumption_budget_resource_group" "monitoring" {
  count = var.enable_budget_alerts ? 1 : 0

  name              = "budget-monitoring-${var.environment}"
  resource_group_id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}"

  amount     = var.budget_amount
  time_grain = "Monthly"

  time_period {
    start_date = formatdate("YYYY-MM-01'T'00:00:00'Z'", timestamp())
    end_date   = formatdate("YYYY-MM-01'T'00:00:00'Z'", timeadd(timestamp(), "8760h")) # 1 year
  }

  filter {
    dimension {
      name = "ResourceGroupName"
      values = [
        var.resource_group_name,
      ]
    }
  }

  notification {
    enabled   = true
    threshold = 80
    operator  = "GreaterThan"

    contact_emails = var.budget_notification_emails
  }

  notification {
    enabled   = true
    threshold = 100
    operator  = "GreaterThan"

    contact_emails = var.budget_notification_emails
  }
}

# Smart Detection Rules for Application Insights
resource "azurerm_application_insights_smart_detection_rule" "failure_anomalies" {
  name                    = "Abnormal rise in exception volume"
  application_insights_id = azurerm_application_insights.main.id
  enabled                 = var.enable_smart_detection

  send_emails_to_subscription_owners = false
  additional_email_recipients        = var.smart_detection_emails
}

resource "azurerm_application_insights_smart_detection_rule" "performance_anomalies" {
  name                    = "Slow server response time"
  application_insights_id = azurerm_application_insights.main.id
  enabled                 = var.enable_smart_detection

  send_emails_to_subscription_owners = false
  additional_email_recipients        = var.smart_detection_emails
}

resource "azurerm_application_insights_smart_detection_rule" "trace_severity" {
  name                    = "Degradation in trace severity ratio"
  application_insights_id = azurerm_application_insights.main.id
  enabled                 = var.enable_smart_detection

  send_emails_to_subscription_owners = false
  additional_email_recipients        = var.smart_detection_emails
}

# Custom Metric Alerts for Application Insights
resource "azurerm_monitor_metric_alert" "app_insights_availability" {
  count = var.enable_availability_tests ? 1 : 0

  name                = "alert-availability-${var.workload}-${var.environment}"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_insights.main.id]
  description         = "Application availability below threshold"
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "availabilityResults/availabilityPercentage"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = var.availability_threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = var.tags
}
