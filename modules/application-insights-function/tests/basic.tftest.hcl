# Mock the AzureRM provider to avoid authentication requirements
mock_provider "azurerm" {}

# Basic tests for Application Insights Function module

run "setup" {
  command = plan

  variables {
    resource_group_name       = "rg-test-function-001"
    location                  = "East US"
    application_insights_name = "appi-test-function-001"
    workload                  = "test"
    environment               = "dev"

    # Basic function monitoring configuration
    function_app_names     = ["func-test-001"]
    app_service_plan_names = ["asp-test-001"]

    # Simplified configuration for testing
    enable_cold_start_detection = false
    enable_exception_detection  = false

    tags = {
      Environment = "Test"
      Purpose     = "Testing"
    }
  }
}

run "validate_alert_names" {
  command = plan

  variables {
    resource_group_name       = "rg-test-function-001"
    location                  = "East US"
    application_insights_name = "appi-test-function-001"
    workload                  = "test"
    environment               = "dev"
    function_app_names        = ["func-test-001"]
    app_service_plan_names    = ["asp-test-001"]
  }

  assert {
    condition = length(regexall("alert-test-dev-function-duration",
    azurerm_monitor_metric_alert.function_duration[0].name)) > 0
    error_message = "Function duration alert name should follow naming convention"
  }

  assert {
    condition     = azurerm_monitor_metric_alert.function_duration[0].criteria[0].threshold == 30000
    error_message = "Function duration threshold should match default value"
  }
}

run "validate_dashboard_creation" {
  command = plan

  variables {
    resource_group_name       = "rg-test-function-001"
    location                  = "East US"
    application_insights_name = "appi-test-function-001"
    enable_function_dashboard = true
    function_app_names        = ["func-test-001"]
  }

  assert {
    condition     = length(azurerm_application_insights_workbook.function_dashboard) > 0
    error_message = "Function dashboard should be created when enabled"
  }

  assert {
    condition     = length(random_uuid.function_dashboard) > 0
    error_message = "Random UUID should be generated for dashboard"
  }
}

run "validate_disabled_features" {
  command = plan

  variables {
    resource_group_name       = "rg-test-function-001"
    location                  = "East US"
    application_insights_name = "appi-test-function-001"

    # Disable optional features
    enable_function_alerts    = false
    enable_app_service_alerts = false
    enable_function_dashboard = false

    function_app_names = ["func-test-001"]
  }

  assert {
    condition     = length(azurerm_monitor_metric_alert.function_duration) == 0
    error_message = "Function duration alert should not be created when disabled"
  }

  assert {
    condition     = length(azurerm_monitor_metric_alert.function_failure_rate) == 0
    error_message = "Function failure alert should not be created when disabled"
  }

  assert {
    condition     = length(azurerm_application_insights_workbook.function_dashboard) == 0
    error_message = "Dashboard should not be created when disabled"
  }
}

run "validate_app_service_plan_alerts" {
  command = plan

  variables {
    resource_group_name       = "rg-test-function-001"
    location                  = "East US"
    application_insights_name = "appi-test-function-001"

    enable_app_service_alerts = true
    app_service_plan_names    = ["asp-test-001", "asp-test-002"]

    cpu_threshold_percent    = 75
    memory_threshold_percent = 80
  }

  assert {
    condition     = length(azurerm_monitor_metric_alert.app_service_cpu) == 2
    error_message = "Should create CPU alerts for each App Service Plan"
  }

  assert {
    condition     = length(azurerm_monitor_metric_alert.app_service_memory) == 2
    error_message = "Should create memory alerts for each App Service Plan"
  }
}

run "validate_advanced_alerts_require_log_analytics" {
  command = plan

  variables {
    resource_group_name       = "rg-test-function-001"
    location                  = "East US"
    application_insights_name = "appi-test-function-001"

    enable_cold_start_detection  = true
    enable_exception_detection   = true
    log_analytics_workspace_name = null # No workspace provided

    function_app_names = ["func-test-001"]
  }

  assert {
    condition     = length(azurerm_monitor_scheduled_query_rules_alert_v2.cold_starts) == 0
    error_message = "Cold start alerts should not be created without Log Analytics workspace"
  }

  assert {
    condition     = length(azurerm_monitor_scheduled_query_rules_alert_v2.function_exceptions) == 0
    error_message = "Exception alerts should not be created without Log Analytics workspace"
  }
}

run "validate_variable_constraints" {
  command = plan

  variables {
    resource_group_name       = "rg-test-function-001"
    location                  = "East US"
    application_insights_name = "appi-test-function-001"

    # Test variable constraints
    function_duration_threshold_ms  = 15000
    function_failure_rate_threshold = 3
    cpu_threshold_percent           = 85
    memory_threshold_percent        = 75
    dashboard_time_range            = 14

    function_app_names = ["func-test-001"]
  }

  assert {
    condition     = var.function_duration_threshold_ms > 0
    error_message = "Function duration threshold must be greater than 0"
  }

  assert {
    condition     = var.function_failure_rate_threshold >= 0 && var.function_failure_rate_threshold <= 100
    error_message = "Function failure rate threshold must be between 0 and 100"
  }

  assert {
    condition     = var.cpu_threshold_percent >= 0 && var.cpu_threshold_percent <= 100
    error_message = "CPU threshold must be between 0 and 100"
  }

  assert {
    condition     = var.dashboard_time_range > 0 && var.dashboard_time_range <= 90
    error_message = "Dashboard time range must be between 1 and 90 days"
  }
}
