# Application Insights Billing Module - Main Configuration
# This module creates billing monitoring, budgets, and cost alerts for Application Insights resources

# Local values for consistent naming
locals {
  budget_prefix = "budget-${var.workload}-${var.environment}"
  alert_prefix  = "alert-${var.workload}-${var.environment}"
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

# Monthly Budget for Resource Group
resource "azurerm_consumption_budget_resource_group" "monthly" {
  count = var.enable_budget_monitoring && var.monthly_budget_amount > 0 ? 1 : 0

  name              = "${local.budget_prefix}-monthly"
  resource_group_id = data.azurerm_resource_group.main.id

  amount     = var.monthly_budget_amount
  time_grain = "Monthly"

  time_period {
    start_date = formatdate("YYYY-MM-01'T'00:00:00'Z'", timestamp())
    end_date   = var.budget_end_date != null ? var.budget_end_date : formatdate("YYYY-MM-01'T'00:00:00'Z'", timeadd(timestamp(), "8760h")) # 1 year from now
  }

  dynamic "notification" {
    for_each = var.budget_alert_thresholds
    content {
      enabled        = true
      threshold      = notification.value
      operator       = "GreaterThan"
      threshold_type = "Actual"

      contact_emails = var.budget_notification_emails
    }
  }

  dynamic "notification" {
    for_each = var.enable_forecast_alerts ? var.budget_forecast_thresholds : []
    content {
      enabled        = true
      threshold      = notification.value
      operator       = "GreaterThan"
      threshold_type = "Forecasted"

      contact_emails = var.budget_notification_emails
    }
  }

  filter {
    dynamic "dimension" {
      for_each = length(var.cost_filter_resource_types) > 0 ? [1] : []
      content {
        name     = "ResourceType"
        operator = "In"
        values   = var.cost_filter_resource_types
      }
    }

    dynamic "tag" {
      for_each = var.cost_filter_tags
      content {
        name     = tag.key
        operator = "In"
        values   = tag.value
      }
    }
  }
}

# Quarterly Budget for Resource Group
resource "azurerm_consumption_budget_resource_group" "quarterly" {
  count = var.enable_budget_monitoring && var.quarterly_budget_amount > 0 ? 1 : 0

  name              = "${local.budget_prefix}-quarterly"
  resource_group_id = data.azurerm_resource_group.main.id

  amount     = var.quarterly_budget_amount
  time_grain = "Quarterly"

  time_period {
    start_date = formatdate("YYYY-MM-01'T'00:00:00'Z'", timestamp())
    end_date   = var.budget_end_date != null ? var.budget_end_date : formatdate("YYYY-MM-01'T'00:00:00'Z'", timeadd(timestamp(), "8760h")) # 1 year from now
  }

  dynamic "notification" {
    for_each = var.budget_alert_thresholds
    content {
      enabled        = true
      threshold      = notification.value
      operator       = "GreaterThan"
      threshold_type = "Actual"

      contact_emails = var.budget_notification_emails
    }
  }

  filter {
    dynamic "dimension" {
      for_each = length(var.cost_filter_resource_types) > 0 ? [1] : []
      content {
        name     = "ResourceType"
        operator = "In"
        values   = var.cost_filter_resource_types
      }
    }

    dynamic "tag" {
      for_each = var.cost_filter_tags
      content {
        name     = tag.key
        operator = "In"
        values   = tag.value
      }
    }
  }
}

# Annual Budget for Resource Group
resource "azurerm_consumption_budget_resource_group" "annual" {
  count = var.enable_budget_monitoring && var.annual_budget_amount > 0 ? 1 : 0

  name              = "${local.budget_prefix}-annual"
  resource_group_id = data.azurerm_resource_group.main.id

  amount     = var.annual_budget_amount
  time_grain = "Annually"

  time_period {
    start_date = formatdate("YYYY-MM-01'T'00:00:00'Z'", timestamp())
    end_date   = var.budget_end_date != null ? var.budget_end_date : formatdate("YYYY-MM-01'T'00:00:00'Z'", timeadd(timestamp(), "17520h")) # 2 years from now
  }

  dynamic "notification" {
    for_each = var.budget_alert_thresholds
    content {
      enabled        = true
      threshold      = notification.value
      operator       = "GreaterThan"
      threshold_type = "Actual"

      contact_emails = var.budget_notification_emails
    }
  }

  filter {
    dynamic "dimension" {
      for_each = length(var.cost_filter_resource_types) > 0 ? [1] : []
      content {
        name     = "ResourceType"
        operator = "In"
        values   = var.cost_filter_resource_types
      }
    }

    dynamic "tag" {
      for_each = var.cost_filter_tags
      content {
        name     = tag.key
        operator = "In"
        values   = tag.value
      }
    }
  }
}

# Daily Cost Alert (using Log Analytics if available)
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "daily_cost" {
  count = var.enable_cost_alerts && var.log_analytics_workspace_name != null ? 1 : 0

  name                = "${local.alert_prefix}-daily-cost"
  resource_group_name = var.resource_group_name
  location            = var.location

  evaluation_frequency = "PT1H"
  window_duration      = "P1D"
  scopes               = [data.azurerm_log_analytics_workspace.main[0].id]
  severity             = var.daily_cost_alert_severity
  enabled              = true

  criteria {
    query                   = <<-QUERY
      Usage
      | where TimeGenerated > ago(1d)
      | where ResourceGroup == "${var.resource_group_name}"
      | summarize TotalCost = sum(Quantity * UnitPrice) by bin(TimeGenerated, 1d)
      | where TotalCost > ${var.daily_spend_threshold}
    QUERY
    time_aggregation_method = "Count"
    threshold               = 1
    operator                = "GreaterThan"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  description = "Daily cost threshold exceeded for resource group ${var.resource_group_name}"
  tags        = var.tags
}

# Cost Anomaly Alert
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "cost_anomaly" {
  count = var.enable_cost_alerts && var.enable_anomaly_detection && var.log_analytics_workspace_name != null ? 1 : 0

  name                = "${local.alert_prefix}-cost-anomaly"
  resource_group_name = var.resource_group_name
  location            = var.location

  evaluation_frequency = "PT6H"
  window_duration      = "P1D"
  scopes               = [data.azurerm_log_analytics_workspace.main[0].id]
  severity             = var.anomaly_alert_severity
  enabled              = true

  criteria {
    query                   = <<-QUERY
      Usage
      | where TimeGenerated > ago(7d)
      | where ResourceGroup == "${var.resource_group_name}"
      | summarize DailyCost = sum(Quantity * UnitPrice) by bin(TimeGenerated, 1d)
      | extend AvgCost = avg(DailyCost)
      | extend StdDev = stdev(DailyCost)
      | extend Threshold = AvgCost + (${var.cost_anomaly_sensitivity} * StdDev)
      | where DailyCost > Threshold
      | where TimeGenerated > ago(1d)
    QUERY
    time_aggregation_method = "Count"
    threshold               = 1
    operator                = "GreaterThan"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  description = "Cost anomaly detected for resource group ${var.resource_group_name}"
  tags        = var.tags
}

# Generate a unique GUID for the billing dashboard
resource "random_uuid" "billing_dashboard" {
  count = var.enable_billing_dashboard ? 1 : 0
}

# Billing Dashboard (Workbook)
resource "azurerm_application_insights_workbook" "billing_dashboard" {
  count = var.enable_billing_dashboard ? 1 : 0

  name                = random_uuid.billing_dashboard[0].result
  resource_group_name = var.resource_group_name
  location            = var.location
  display_name        = var.dashboard_display_name != null ? var.dashboard_display_name : "${var.workload} ${var.environment} Billing Dashboard"

  data_json = jsonencode({
    version = "Notebook/1.0"
    items = [
      {
        type = 1
        content = {
          json = "## ${var.workload} ${var.environment} Billing & Cost Analysis\n\nThis dashboard provides comprehensive billing information and cost analysis for resources in the **${var.resource_group_name}** resource group."
        }
      },
      {
        type = 3
        content = {
          version = "KqlItem/1.0"
          query   = "Usage\n| where TimeGenerated > ago(30d)\n| where ResourceGroup == \"${var.resource_group_name}\"\n| summarize TotalCost = sum(Quantity * UnitPrice) by bin(TimeGenerated, 1d)\n| render timechart"
          size    = 0
          title   = "Daily Cost Trend (Last 30 Days)"
          timeContext = {
            durationMs = 2592000000 # 30 days
          }
          queryType    = 0
          resourceType = "microsoft.operationalinsights/workspaces"
        }
      },
      {
        type = 3
        content = {
          version = "KqlItem/1.0"
          query   = "Usage\n| where TimeGenerated > ago(30d)\n| where ResourceGroup == \"${var.resource_group_name}\"\n| summarize TotalCost = sum(Quantity * UnitPrice) by ResourceType\n| top 10 by TotalCost desc\n| render piechart"
          size    = 0
          title   = "Cost by Resource Type (Last 30 Days)"
          timeContext = {
            durationMs = 2592000000 # 30 days
          }
          queryType    = 0
          resourceType = "microsoft.operationalinsights/workspaces"
        }
      },
      {
        type = 3
        content = {
          version = "KqlItem/1.0"
          query   = "Usage\n| where TimeGenerated > ago(7d)\n| where ResourceGroup == \"${var.resource_group_name}\"\n| summarize TotalCost = sum(Quantity * UnitPrice) by Resource\n| top 10 by TotalCost desc"
          size    = 0
          title   = "Top 10 Most Expensive Resources (Last 7 Days)"
          timeContext = {
            durationMs = 604800000 # 7 days
          }
          queryType     = 0
          resourceType  = "microsoft.operationalinsights/workspaces"
          visualization = "table"
        }
      },
      {
        type = 3
        content = {
          version = "KqlItem/1.0"
          query   = "Usage\n| where TimeGenerated > ago(1d)\n| where ResourceGroup == \"${var.resource_group_name}\"\n| summarize\n    TotalCost = sum(Quantity * UnitPrice),\n    TotalQuantity = sum(Quantity),\n    UniqueResources = dcount(Resource),\n    UniqueResourceTypes = dcount(ResourceType)\n| extend AvgCostPerResource = TotalCost / UniqueResources"
          size    = 0
          title   = "24-Hour Cost Summary"
          timeContext = {
            durationMs = 86400000 # 24 hours
          }
          queryType     = 0
          resourceType  = "microsoft.operationalinsights/workspaces"
          visualization = "table"
        }
      },
      {
        type = 3
        content = {
          version = "KqlItem/1.0"
          query   = "Usage\n| where TimeGenerated > ago(30d)\n| where ResourceGroup == \"${var.resource_group_name}\"\n| summarize MonthlyCost = sum(Quantity * UnitPrice)\n| extend BudgetAmount = ${var.monthly_budget_amount > 0 ? var.monthly_budget_amount : 1000}\n| extend BudgetUtilization = (MonthlyCost / BudgetAmount) * 100\n| extend Status = case(\n    BudgetUtilization < 80, \"✅ On Track\",\n    BudgetUtilization < 95, \"⚠️ Warning\",\n    \"🚨 Over Budget\"\n)\n| project MonthlyCost, BudgetAmount, BudgetUtilization, Status"
          size    = 0
          title   = "Monthly Budget Status"
          timeContext = {
            durationMs = 2592000000 # 30 days
          }
          queryType     = 0
          resourceType  = "microsoft.operationalinsights/workspaces"
          visualization = "table"
        }
      },
      {
        type = 3
        content = {
          version = "KqlItem/1.0"
          query   = "Usage\n| where TimeGenerated > ago(30d)\n| where ResourceGroup == \"${var.resource_group_name}\"\n| summarize DailyCost = sum(Quantity * UnitPrice) by bin(TimeGenerated, 1d)\n| extend MovingAvg = series_fir(DailyCost, repeat(1, 7), true, true)\n| render timechart"
          size    = 0
          title   = "Daily Cost with 7-Day Moving Average"
          timeContext = {
            durationMs = 2592000000 # 30 days
          }
          queryType    = 0
          resourceType = "microsoft.operationalinsights/workspaces"
        }
      }
    ]
  })

  tags = var.tags
}
