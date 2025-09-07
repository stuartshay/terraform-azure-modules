# Required provider block for AzureRM
provider "azurerm" {
  features {}
}
# Basic tests for Application Insights Billing module

run "setup" {
  command = plan

  variables {
    resource_group_name       = "rg-test-billing-001"
    location                  = "East US"
    application_insights_name = "appi-test-billing-001"
    workload                  = "test"
    environment               = "dev"

    # Basic budget configuration for testing
    monthly_budget_amount   = 100
    quarterly_budget_amount = 300
    annual_budget_amount    = 1200

    # Simplified configuration for testing
    budget_alert_thresholds  = [90, 100]
    enable_forecast_alerts   = false
    enable_cost_alerts       = false
    enable_anomaly_detection = false

    budget_notification_emails = ["test@example.com"]

    tags = {
      Environment = "Test"
      Purpose     = "Testing"
    }
  }
}

run "validate_budget_names" {
  command = plan

  variables {
    resource_group_name        = "rg-test-billing-001"
    location                   = "East US"
    application_insights_name  = "appi-test-billing-001"
    workload                   = "test"
    environment                = "dev"
    monthly_budget_amount      = 100
    budget_notification_emails = ["test@example.com"]
  }

  assert {
    condition = length(regexall("budget-test-dev-monthly",
    azurerm_consumption_budget_resource_group.monthly[0].name)) > 0
    error_message = "Monthly budget name should follow naming convention"
  }

  assert {
    condition     = azurerm_consumption_budget_resource_group.monthly[0].amount == 100
    error_message = "Monthly budget amount should match input variable"
  }
}

run "validate_dashboard_creation" {
  command = plan

  variables {
    resource_group_name        = "rg-test-billing-001"
    location                   = "East US"
    application_insights_name  = "appi-test-billing-001"
    enable_billing_dashboard   = true
    monthly_budget_amount      = 100
    budget_notification_emails = ["test@example.com"]
  }

  assert {
    condition     = length(azurerm_application_insights_workbook.billing_dashboard) > 0
    error_message = "Billing dashboard should be created when enabled"
  }

  assert {
    condition     = length(random_uuid.billing_dashboard) > 0
    error_message = "Random UUID should be generated for dashboard"
  }
}

run "validate_disabled_features" {
  command = plan

  variables {
    resource_group_name       = "rg-test-billing-001"
    location                  = "East US"
    application_insights_name = "appi-test-billing-001"

    # Disable optional features
    enable_budget_monitoring = false
    enable_billing_dashboard = false
    enable_cost_alerts       = false

    monthly_budget_amount      = 0
    budget_notification_emails = []
  }

  assert {
    condition     = length(azurerm_consumption_budget_resource_group.monthly) == 0
    error_message = "Monthly budget should not be created when disabled or amount is 0"
  }

  assert {
    condition     = length(azurerm_application_insights_workbook.billing_dashboard) == 0
    error_message = "Dashboard should not be created when disabled"
  }

  assert {
    condition     = length(azurerm_monitor_scheduled_query_rules_alert_v2.daily_cost) == 0
    error_message = "Cost alerts should not be created when disabled"
  }
}

run "validate_cost_alerts_require_log_analytics" {
  command = plan

  variables {
    resource_group_name       = "rg-test-billing-001"
    location                  = "East US"
    application_insights_name = "appi-test-billing-001"

    enable_cost_alerts           = true
    log_analytics_workspace_name = null # No workspace provided

    monthly_budget_amount      = 100
    budget_notification_emails = ["test@example.com"]
  }

  assert {
    condition     = length(azurerm_monitor_scheduled_query_rules_alert_v2.daily_cost) == 0
    error_message = "Cost alerts should not be created without Log Analytics workspace"
  }

  assert {
    condition     = length(azurerm_monitor_scheduled_query_rules_alert_v2.cost_anomaly) == 0
    error_message = "Anomaly detection should not be created without Log Analytics workspace"
  }
}

run "validate_variable_constraints" {
  command = plan

  variables {
    resource_group_name       = "rg-test-billing-001"
    location                  = "East US"
    application_insights_name = "appi-test-billing-001"

    # Test variable constraints
    monthly_budget_amount     = 500
    budget_alert_thresholds   = [80, 90, 100]
    daily_cost_alert_severity = 2
    anomaly_alert_severity    = 1
    cost_anomaly_sensitivity  = 2.5
    dashboard_time_range      = 60

    budget_notification_emails = ["valid@example.com"]
  }

  assert {
    condition     = var.monthly_budget_amount >= 0
    error_message = "Monthly budget amount must be non-negative"
  }

  assert {
    condition = alltrue([
      for threshold in var.budget_alert_thresholds : threshold > 0 && threshold <= 200
    ])
    error_message = "Budget alert thresholds must be between 1 and 200"
  }

  assert {
    condition     = var.daily_cost_alert_severity >= 0 && var.daily_cost_alert_severity <= 4
    error_message = "Alert severity must be between 0 and 4"
  }

  assert {
    condition     = var.dashboard_time_range > 0 && var.dashboard_time_range <= 365
    error_message = "Dashboard time range must be between 1 and 365 days"
  }
}
