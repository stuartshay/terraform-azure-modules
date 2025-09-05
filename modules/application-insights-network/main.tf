# Application Insights Network Module - Main Configuration
# This module creates alerting rules and dashboards for Application Insights monitoring

# Local values for consistent naming
locals {
  alert_prefix = "alert-${var.workload}-${var.environment}"
}

# Data source to get Application Insights information
data "azurerm_application_insights" "main" {
  name                = var.application_insights_name
  resource_group_name = var.resource_group_name
}

# Data source to get Log Analytics Workspace information (if provided)
data "azurerm_log_analytics_workspace" "main" {
  count = var.log_analytics_workspace_name != null ? 1 : 0

  name                = var.log_analytics_workspace_name
  resource_group_name = var.resource_group_name
}

# Response Time Alert
resource "azurerm_monitor_metric_alert" "response_time" {
  count = var.enable_response_time_alert ? 1 : 0

  name                = "${local.alert_prefix}-response-time"
  resource_group_name = var.resource_group_name
  scopes              = [data.azurerm_application_insights.main.id]
  description         = "Application response time is above threshold"
  severity            = var.response_time_alert_severity
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "requests/duration"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.response_time_threshold_ms
  }

  tags = var.tags
}

# Failed Request Rate Alert
resource "azurerm_monitor_metric_alert" "failed_request_rate" {
  count = var.enable_failed_request_alert ? 1 : 0

  name                = "${local.alert_prefix}-failed-requests"
  resource_group_name = var.resource_group_name
  scopes              = [data.azurerm_application_insights.main.id]
  description         = "Failed request rate is above threshold"
  severity            = var.failed_request_alert_severity
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "requests/failed"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.failed_request_rate_threshold
  }

  tags = var.tags
}

# Exception Rate Alert
resource "azurerm_monitor_metric_alert" "exception_rate" {
  count = var.enable_exception_alert ? 1 : 0

  name                = "${local.alert_prefix}-exceptions"
  resource_group_name = var.resource_group_name
  scopes              = [data.azurerm_application_insights.main.id]
  description         = "Exception rate is above threshold"
  severity            = var.exception_alert_severity
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "exceptions/count"
    aggregation      = "Count"
    operator         = "GreaterThan"
    threshold        = var.exception_rate_threshold
  }

  tags = var.tags
}

# Availability Alert
resource "azurerm_monitor_metric_alert" "availability" {
  count = var.enable_availability_alert ? 1 : 0

  name                = "${local.alert_prefix}-availability"
  resource_group_name = var.resource_group_name
  scopes              = [data.azurerm_application_insights.main.id]
  description         = "Application availability is below threshold"
  severity            = var.availability_alert_severity
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "availabilityResults/availabilityPercentage"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = var.availability_threshold_percent
  }

  tags = var.tags
}

# Server Errors Alert (5xx responses)
resource "azurerm_monitor_metric_alert" "server_errors" {
  count = var.enable_server_error_alert ? 1 : 0

  name                = "${local.alert_prefix}-server-errors"
  resource_group_name = var.resource_group_name
  scopes              = [data.azurerm_application_insights.main.id]
  description         = "Server error rate is above threshold"
  severity            = var.server_error_alert_severity
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "requests/count"
    aggregation      = "Count"
    operator         = "GreaterThan"
    threshold        = var.server_error_threshold

    dimension {
      name     = "request/resultCode"
      operator = "Include"
      values   = ["5*"]
    }
  }

  tags = var.tags
}

# Generate a unique GUID for the workbook name
resource "random_uuid" "dashboard" {
  count = var.enable_dashboard ? 1 : 0
}

# Application Insights Dashboard (Workbook)
resource "azurerm_application_insights_workbook" "dashboard" {
  count = var.enable_dashboard ? 1 : 0

  name                = random_uuid.dashboard[0].result
  resource_group_name = var.resource_group_name
  location            = var.location
  display_name        = var.dashboard_display_name != null ? var.dashboard_display_name : "${var.workload} ${var.environment} Monitoring Dashboard"

  data_json = jsonencode({
    version = "Notebook/1.0"
    items = [
      {
        type = 1
        content = {
          json = "## ${var.workload} ${var.environment} Application Monitoring\n\nThis dashboard provides an overview of application performance and health metrics from Application Insights."
        }
      },
      {
        type = 3
        content = {
          version = "KqlItem/1.0"
          query   = "requests\n| where timestamp > ago(1h)\n| summarize RequestCount = count() by bin(timestamp, 5m)\n| render timechart"
          size    = 0
          title   = "Request Rate (Last Hour)"
          timeContext = {
            durationMs = 3600000
          }
          queryType    = 0
          resourceType = "microsoft.insights/components"
        }
      },
      {
        type = 3
        content = {
          version = "KqlItem/1.0"
          query   = "requests\n| where timestamp > ago(1h)\n| summarize AvgDuration = avg(duration) by bin(timestamp, 5m)\n| render timechart"
          size    = 0
          title   = "Average Response Time (Last Hour)"
          timeContext = {
            durationMs = 3600000
          }
          queryType    = 0
          resourceType = "microsoft.insights/components"
        }
      },
      {
        type = 3
        content = {
          version = "KqlItem/1.0"
          query   = "requests\n| where timestamp > ago(1h)\n| where success == false\n| summarize FailedRequests = count() by bin(timestamp, 5m)\n| render timechart"
          size    = 0
          title   = "Failed Requests (Last Hour)"
          timeContext = {
            durationMs = 3600000
          }
          queryType    = 0
          resourceType = "microsoft.insights/components"
        }
      },
      {
        type = 3
        content = {
          version = "KqlItem/1.0"
          query   = "exceptions\n| where timestamp > ago(1h)\n| summarize ExceptionCount = count() by bin(timestamp, 5m)\n| render timechart"
          size    = 0
          title   = "Exceptions (Last Hour)"
          timeContext = {
            durationMs = 3600000
          }
          queryType    = 0
          resourceType = "microsoft.insights/components"
        }
      },
      {
        type = 3
        content = {
          version = "KqlItem/1.0"
          query   = "availabilityResults\n| where timestamp > ago(1h)\n| summarize AvailabilityPercentage = avg(success) * 100 by bin(timestamp, 5m)\n| render timechart"
          size    = 0
          title   = "Availability Percentage (Last Hour)"
          timeContext = {
            durationMs = 3600000
          }
          queryType    = 0
          resourceType = "microsoft.insights/components"
        }
      },
      {
        type = 3
        content = {
          version = "KqlItem/1.0"
          query   = "requests\n| where timestamp > ago(24h)\n| summarize\n    TotalRequests = count(),\n    SuccessfulRequests = countif(success == true),\n    FailedRequests = countif(success == false),\n    AvgResponseTime = avg(duration)\n| extend SuccessRate = (SuccessfulRequests * 100.0) / TotalRequests\n| project TotalRequests, SuccessfulRequests, FailedRequests, SuccessRate, AvgResponseTime"
          size    = 0
          title   = "24-Hour Summary"
          timeContext = {
            durationMs = 86400000
          }
          queryType     = 0
          resourceType  = "microsoft.insights/components"
          visualization = "table"
        }
      }
    ]
  })

  tags = var.tags
}
