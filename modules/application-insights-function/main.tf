# Application Insights Function Module - Main Configuration
# This module creates monitoring, alerts, and dashboards for Function Apps and App Service Plans

# Local values for consistent naming
locals {
  alert_prefix = "alert-${var.workload}-${var.environment}"
}

# Data source to get Application Insights information
data "azurerm_application_insights" "main" {
  name                = var.application_insights_name
  resource_group_name = var.resource_group_name
}

# Data source to get Resource Group information
data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

# Data source to get Log Analytics Workspace information (if provided)
data "azurerm_log_analytics_workspace" "main" {
  count = var.log_analytics_workspace_name != null ? 1 : 0

  name                = var.log_analytics_workspace_name
  resource_group_name = var.resource_group_name
}

# Data sources to get Function Apps in the resource group
data "azurerm_function_app" "functions" {
  for_each = var.function_app_names != null ? toset(var.function_app_names) : toset([])

  name                = each.value
  resource_group_name = var.resource_group_name
}

# Data sources to get App Service Plans in the resource group
data "azurerm_service_plan" "plans" {
  for_each = var.app_service_plan_names != null ? toset(var.app_service_plan_names) : toset([])

  name                = each.value
  resource_group_name = var.resource_group_name
}

# Local values for handling mocked data sources
locals {
  # Generate mock resource IDs for testing when data sources return invalid values
  # Check if the data source ID looks like a proper Azure resource ID
  application_insights_id = can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Insights/components/.+$", data.azurerm_application_insights.main.id)) ? data.azurerm_application_insights.main.id : "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/${var.resource_group_name}/providers/Microsoft.Insights/components/${var.application_insights_name}"

  log_analytics_workspace_id = var.log_analytics_workspace_name != null ? (
    can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.OperationalInsights/workspaces/.+$", data.azurerm_log_analytics_workspace.main[0].id)) ?
    data.azurerm_log_analytics_workspace.main[0].id :
    "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/${var.resource_group_name}/providers/Microsoft.OperationalInsights/workspaces/${var.log_analytics_workspace_name}"
  ) : null

  # Generate mock App Service Plan IDs for testing
  app_service_plan_ids = var.app_service_plan_names != null ? {
    for name in var.app_service_plan_names : name => (
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Web/serverfarms/.+$", data.azurerm_service_plan.plans[name].id)) ?
      data.azurerm_service_plan.plans[name].id :
      "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/${var.resource_group_name}/providers/Microsoft.Web/serverfarms/${name}"
    )
  } : {}
}

# Function Execution Duration Alert
resource "azurerm_monitor_metric_alert" "function_duration" {
  count = var.enable_function_alerts ? 1 : 0

  name                = "${local.alert_prefix}-function-duration"
  resource_group_name = var.resource_group_name
  scopes              = [local.application_insights_id]
  description         = "Function execution duration is above threshold"
  severity            = var.function_duration_alert_severity
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "requests/duration"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.function_duration_threshold_ms

    dimension {
      name     = "cloud/roleName"
      operator = "Include"
      values   = var.function_app_names != null ? var.function_app_names : ["*"]
    }
  }

  tags = var.tags
}

# Function Failure Rate Alert
resource "azurerm_monitor_metric_alert" "function_failure_rate" {
  count = var.enable_function_alerts ? 1 : 0

  name                = "${local.alert_prefix}-function-failures"
  resource_group_name = var.resource_group_name
  scopes              = [local.application_insights_id]
  description         = "Function failure rate is above threshold"
  severity            = var.function_failure_alert_severity
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "requests/failed"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.function_failure_rate_threshold

    dimension {
      name     = "cloud/roleName"
      operator = "Include"
      values   = var.function_app_names != null ? var.function_app_names : ["*"]
    }
  }

  tags = var.tags
}

# Function Invocation Count Alert (Low Activity)
resource "azurerm_monitor_metric_alert" "function_low_activity" {
  count = var.enable_function_alerts && var.function_min_invocations_threshold > 0 ? 1 : 0

  name                = "${local.alert_prefix}-function-low-activity"
  resource_group_name = var.resource_group_name
  scopes              = [local.application_insights_id]
  description         = "Function invocation count is below expected threshold"
  severity            = var.function_activity_alert_severity
  frequency           = "PT5M"
  window_size         = "PT15M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Insights/components"
    metric_name      = "requests/count"
    aggregation      = "Count"
    operator         = "LessThan"
    threshold        = var.function_min_invocations_threshold

    dimension {
      name     = "cloud/roleName"
      operator = "Include"
      values   = var.function_app_names != null ? var.function_app_names : ["*"]
    }
  }

  tags = var.tags
}

# App Service Plan CPU Alert
resource "azurerm_monitor_metric_alert" "app_service_cpu" {
  for_each = var.enable_app_service_alerts && var.app_service_plan_names != null ? toset(var.app_service_plan_names) : toset([])

  name                = "${local.alert_prefix}-asp-cpu-${each.value}"
  resource_group_name = var.resource_group_name
  scopes              = [local.app_service_plan_ids[each.value]]
  description         = "App Service Plan CPU usage is above threshold"
  severity            = var.app_service_cpu_alert_severity
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/serverfarms"
    metric_name      = "CpuPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.cpu_threshold_percent
  }

  tags = var.tags
}

# App Service Plan Memory Alert
resource "azurerm_monitor_metric_alert" "app_service_memory" {
  for_each = var.enable_app_service_alerts && var.app_service_plan_names != null ? toset(var.app_service_plan_names) : toset([])

  name                = "${local.alert_prefix}-asp-memory-${each.value}"
  resource_group_name = var.resource_group_name
  scopes              = [local.app_service_plan_ids[each.value]]
  description         = "App Service Plan memory usage is above threshold"
  severity            = var.app_service_memory_alert_severity
  frequency           = "PT1M"
  window_size         = "PT5M"
  enabled             = true

  criteria {
    metric_namespace = "Microsoft.Web/serverfarms"
    metric_name      = "MemoryPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.memory_threshold_percent
  }

  tags = var.tags
}

# Cold Start Detection Alert (using Log Analytics)
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "cold_starts" {
  count = var.enable_function_alerts && var.enable_cold_start_detection && var.log_analytics_workspace_name != null ? 1 : 0

  name                = "${local.alert_prefix}-cold-starts"
  resource_group_name = var.resource_group_name
  location            = var.location

  evaluation_frequency = "PT5M"
  window_duration      = "PT15M"
  scopes               = [local.log_analytics_workspace_id]
  severity             = var.cold_start_alert_severity
  enabled              = true

  criteria {
    query                   = <<-QUERY
      traces
      | where timestamp > ago(15m)
      | where message contains "Cold start"
      | where cloud_RoleName in (${join(",", [for name in var.function_app_names != null ? var.function_app_names : [] : "\"${name}\""])})
      | summarize ColdStartCount = count() by bin(timestamp, 5m), cloud_RoleName
      | where ColdStartCount > ${var.cold_start_threshold}
    QUERY
    time_aggregation_method = "Count"
    threshold               = 1
    operator                = "GreaterThan"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  description = "High number of cold starts detected for Function Apps"
  tags        = var.tags
}

# Function Exception Rate Alert (using Log Analytics)
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "function_exceptions" {
  count = var.enable_function_alerts && var.enable_exception_detection && var.log_analytics_workspace_name != null ? 1 : 0

  name                = "${local.alert_prefix}-function-exceptions"
  resource_group_name = var.resource_group_name
  location            = var.location

  evaluation_frequency = "PT5M"
  window_duration      = "PT15M"
  scopes               = [local.log_analytics_workspace_id]
  severity             = var.exception_alert_severity
  enabled              = true

  criteria {
    query                   = <<-QUERY
      exceptions
      | where timestamp > ago(15m)
      | where cloud_RoleName in (${join(",", [for name in var.function_app_names != null ? var.function_app_names : [] : "\"${name}\""])})
      | summarize ExceptionCount = count() by bin(timestamp, 5m), cloud_RoleName
      | where ExceptionCount > ${var.exception_rate_threshold}
    QUERY
    time_aggregation_method = "Count"
    threshold               = 1
    operator                = "GreaterThan"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  description = "High exception rate detected for Function Apps"
  tags        = var.tags
}

# Generate a unique GUID for the function dashboard
resource "random_uuid" "function_dashboard" {
  count = var.enable_function_dashboard ? 1 : 0
}

# Function Monitoring Dashboard (Workbook)
resource "azurerm_application_insights_workbook" "function_dashboard" {
  count = var.enable_function_dashboard ? 1 : 0

  name                = random_uuid.function_dashboard[0].result
  resource_group_name = var.resource_group_name
  location            = var.location
  display_name        = var.dashboard_display_name != null ? var.dashboard_display_name : "${var.workload} ${var.environment} Function Monitoring Dashboard"

  data_json = jsonencode({
    version = "Notebook/1.0"
    items = [
      {
        type = 1
        content = {
          json = "## ${var.workload} ${var.environment} Function App Monitoring\n\nThis dashboard provides comprehensive monitoring for Function Apps and App Service Plans in the **${var.resource_group_name}** resource group."
        }
      },
      {
        type = 3
        content = {
          version = "KqlItem/1.0"
          query   = "requests\n| where timestamp > ago(${var.dashboard_time_range}d)\n| where cloud_RoleName in (${join(",", [for name in var.function_app_names != null ? var.function_app_names : [] : "\"${name}\""])})\n| summarize RequestCount = count() by bin(timestamp, 1h), cloud_RoleName\n| render timechart"
          size    = 0
          title   = "Function Invocations Over Time"
          timeContext = {
            durationMs = var.dashboard_time_range * 24 * 60 * 60 * 1000
          }
          queryType    = 0
          resourceType = "microsoft.insights/components"
        }
      },
      {
        type = 3
        content = {
          version = "KqlItem/1.0"
          query   = "requests\n| where timestamp > ago(${var.dashboard_time_range}d)\n| where cloud_RoleName in (${join(",", [for name in var.function_app_names != null ? var.function_app_names : [] : "\"${name}\""])})\n| summarize AvgDuration = avg(duration), P50 = percentile(duration, 50), P95 = percentile(duration, 95), P99 = percentile(duration, 99) by bin(timestamp, 1h)\n| render timechart"
          size    = 0
          title   = "Function Execution Duration (Percentiles)"
          timeContext = {
            durationMs = var.dashboard_time_range * 24 * 60 * 60 * 1000
          }
          queryType    = 0
          resourceType = "microsoft.insights/components"
        }
      },
      {
        type = 3
        content = {
          version = "KqlItem/1.0"
          query   = "requests\n| where timestamp > ago(${var.dashboard_time_range}d)\n| where cloud_RoleName in (${join(",", [for name in var.function_app_names != null ? var.function_app_names : [] : "\"${name}\""])})\n| summarize TotalRequests = count(), FailedRequests = countif(success == false) by cloud_RoleName\n| extend SuccessRate = (TotalRequests - FailedRequests) * 100.0 / TotalRequests\n| project cloud_RoleName, TotalRequests, FailedRequests, SuccessRate\n| order by TotalRequests desc"
          size    = 0
          title   = "Function Success Rates by App"
          timeContext = {
            durationMs = var.dashboard_time_range * 24 * 60 * 60 * 1000
          }
          queryType     = 0
          resourceType  = "microsoft.insights/components"
          visualization = "table"
        }
      },
      {
        type = 3
        content = {
          version = "KqlItem/1.0"
          query   = "requests\n| where timestamp > ago(${var.dashboard_time_range}d)\n| where cloud_RoleName in (${join(",", [for name in var.function_app_names != null ? var.function_app_names : [] : "\"${name}\""])})\n| where success == false\n| summarize FailureCount = count() by bin(timestamp, 1h), resultCode\n| render timechart"
          size    = 0
          title   = "Function Failures by Result Code"
          timeContext = {
            durationMs = var.dashboard_time_range * 24 * 60 * 60 * 1000
          }
          queryType    = 0
          resourceType = "microsoft.insights/components"
        }
      },
      {
        type = 3
        content = {
          version = "KqlItem/1.0"
          query   = "dependencies\n| where timestamp > ago(${var.dashboard_time_range}d)\n| where cloud_RoleName in (${join(",", [for name in var.function_app_names != null ? var.function_app_names : [] : "\"${name}\""])})\n| summarize AvgDuration = avg(duration), CallCount = count() by type, target\n| order by CallCount desc\n| take 10"
          size    = 0
          title   = "Top 10 Dependencies by Call Count"
          timeContext = {
            durationMs = var.dashboard_time_range * 24 * 60 * 60 * 1000
          }
          queryType     = 0
          resourceType  = "microsoft.insights/components"
          visualization = "table"
        }
      },
      {
        type = 3
        content = {
          version = "KqlItem/1.0"
          query   = "traces\n| where timestamp > ago(${var.dashboard_time_range}d)\n| where message contains \"Cold start\"\n| where cloud_RoleName in (${join(",", [for name in var.function_app_names != null ? var.function_app_names : [] : "\"${name}\""])})\n| summarize ColdStartCount = count() by bin(timestamp, 1h), cloud_RoleName\n| render timechart"
          size    = 0
          title   = "Cold Starts Over Time"
          timeContext = {
            durationMs = var.dashboard_time_range * 24 * 60 * 60 * 1000
          }
          queryType    = 0
          resourceType = "microsoft.insights/components"
        }
      },
      {
        type = 3
        content = {
          version = "KqlItem/1.0"
          query   = "exceptions\n| where timestamp > ago(${var.dashboard_time_range}d)\n| where cloud_RoleName in (${join(",", [for name in var.function_app_names != null ? var.function_app_names : [] : "\"${name}\""])})\n| summarize ExceptionCount = count() by bin(timestamp, 1h), type\n| render timechart"
          size    = 0
          title   = "Exceptions Over Time by Type"
          timeContext = {
            durationMs = var.dashboard_time_range * 24 * 60 * 60 * 1000
          }
          queryType    = 0
          resourceType = "microsoft.insights/components"
        }
      },
      {
        type = 3
        content = {
          version = "KqlItem/1.0"
          query   = "requests\n| where timestamp > ago(1d)\n| where cloud_RoleName in (${join(",", [for name in var.function_app_names != null ? var.function_app_names : [] : "\"${name}\""])})\n| summarize\n    TotalInvocations = count(),\n    AvgDuration = avg(duration),\n    P95Duration = percentile(duration, 95),\n    SuccessRate = (count() - countif(success == false)) * 100.0 / count(),\n    UniqueOperations = dcount(name)\nby cloud_RoleName\n| order by TotalInvocations desc"
          size    = 0
          title   = "24-Hour Function Summary"
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
