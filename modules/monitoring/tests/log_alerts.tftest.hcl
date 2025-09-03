# Log alerts tests for monitoring module
# Tests that log query alerts for exceptions and availability are created for monitored function app

# Mock the AzureRM provider to avoid authentication requirements
mock_provider "azurerm" {}

# Test log alerts creation when enabled
run "test_log_alerts_enabled" {
  command = plan

  variables {
    resource_group_name = "rg-test-monitoring"
    location            = "East US"
    workload            = "testapp"
    environment         = "dev"
    location_short      = "eastus"
    subscription_id     = "00000000-0000-0000-0000-000000000000"
    monitored_function_apps = {
      testfunc = {
        resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-monitoring/providers/Microsoft.Web/sites/func-testapp-dev-001"
        name        = "func-testapp-dev-001"
      }
    }
    notification_emails = { admin = "admin@example.com" }
    enable_log_alerts   = true
    tags                = { Environment = "dev", Project = "testapp" }
  }

  # Verify function exceptions log alert is created
  assert {
    condition     = azurerm_monitor_scheduled_query_rules_alert_v2.function_exceptions[0].name == "alert-function-exceptions"
    error_message = "Function exceptions log alert should be created with correct name"
  }

  assert {
    condition     = azurerm_monitor_scheduled_query_rules_alert_v2.function_exceptions[0].severity == 1
    error_message = "Function exceptions log alert should have severity 1"
  }

  assert {
    condition     = azurerm_monitor_scheduled_query_rules_alert_v2.function_exceptions[0].evaluation_frequency == "PT5M"
    error_message = "Function exceptions log alert should have 5 minute evaluation frequency"
  }

  assert {
    condition     = azurerm_monitor_scheduled_query_rules_alert_v2.function_exceptions[0].window_duration == "PT15M"
    error_message = "Function exceptions log alert should have 15 minute window duration"
  }

  # Verify function availability log alert is created
  assert {
    condition     = azurerm_monitor_scheduled_query_rules_alert_v2.function_availability[0].name == "alert-function-availability"
    error_message = "Function availability log alert should be created with correct name"
  }

  assert {
    condition     = azurerm_monitor_scheduled_query_rules_alert_v2.function_availability[0].severity == 1
    error_message = "Function availability log alert should have severity 1"
  }

  # Verify function performance log alert is created
  assert {
    condition     = azurerm_monitor_scheduled_query_rules_alert_v2.function_performance[0].name == "alert-function-performance"
    error_message = "Function performance log alert should be created with correct name"
  }

  assert {
    condition     = azurerm_monitor_scheduled_query_rules_alert_v2.function_performance[0].severity == 2
    error_message = "Function performance log alert should have severity 2"
  }

  # Verify all log alerts are configured with the action group
  assert {
    condition     = length(azurerm_monitor_scheduled_query_rules_alert_v2.function_exceptions[0].action[0].action_groups) > 0
    error_message = "Function exceptions log alert should be configured with the action group"
  }

  assert {
    condition     = length(azurerm_monitor_scheduled_query_rules_alert_v2.function_availability[0].action[0].action_groups) > 0
    error_message = "Function availability log alert should be configured with the action group"
  }

  assert {
    condition     = length(azurerm_monitor_scheduled_query_rules_alert_v2.function_performance[0].action[0].action_groups) > 0
    error_message = "Function performance log alert should be configured with the action group"
  }

  # Verify log alerts are scoped to the Log Analytics workspace
  assert {
    condition     = length(azurerm_monitor_scheduled_query_rules_alert_v2.function_exceptions[0].scopes) > 0
    error_message = "Function exceptions log alert should be scoped to the Log Analytics workspace"
  }

  assert {
    condition     = length(azurerm_monitor_scheduled_query_rules_alert_v2.function_availability[0].scopes) > 0
    error_message = "Function availability log alert should be scoped to the Log Analytics workspace"
  }

  assert {
    condition     = length(azurerm_monitor_scheduled_query_rules_alert_v2.function_performance[0].scopes) > 0
    error_message = "Function performance log alert should be scoped to the Log Analytics workspace"
  }
}

# Test log alerts with custom thresholds
run "test_custom_log_alert_thresholds" {
  command = plan

  variables {
    resource_group_name = "rg-test-monitoring"
    location            = "East US"
    workload            = "testapp"
    environment         = "prod"
    location_short      = "eastus"
    subscription_id     = "00000000-0000-0000-0000-000000000000"
    monitored_function_apps = {
      prodfunc = {
        resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-monitoring/providers/Microsoft.Web/sites/func-testapp-prod-001"
        name        = "func-testapp-prod-001"
      }
    }
    notification_emails    = { admin = "admin@example.com" }
    enable_log_alerts      = true
    exception_threshold    = 20
    availability_threshold = 95
    performance_threshold  = 3000
    tags                   = { Environment = "prod", Project = "testapp" }
  }

  # Verify custom thresholds are used in queries
  assert {
    condition     = can(regex("20", azurerm_monitor_scheduled_query_rules_alert_v2.function_exceptions[0].criteria[0].query))
    error_message = "Function exceptions log alert should use custom exception threshold of 20"
  }

  assert {
    condition     = can(regex("95", azurerm_monitor_scheduled_query_rules_alert_v2.function_availability[0].criteria[0].query))
    error_message = "Function availability log alert should use custom availability threshold of 95"
  }

  assert {
    condition     = can(regex("3000", azurerm_monitor_scheduled_query_rules_alert_v2.function_performance[0].criteria[0].query))
    error_message = "Function performance log alert should use custom performance threshold of 3000"
  }
}

# Test log alerts disabled
run "test_log_alerts_disabled" {
  command = plan

  variables {
    resource_group_name = "rg-test-monitoring"
    location            = "East US"
    workload            = "testapp"
    environment         = "dev"
    location_short      = "eastus"
    subscription_id     = "00000000-0000-0000-0000-000000000000"
    monitored_function_apps = {
      testfunc = {
        resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test-monitoring/providers/Microsoft.Web/sites/func-testapp-dev-001"
        name        = "func-testapp-dev-001"
      }
    }
    notification_emails = { admin = "admin@example.com" }
    enable_log_alerts   = false
    tags                = { Environment = "dev", Project = "testapp" }
  }

  # Verify log alerts are not created when disabled
  assert {
    condition     = length(azurerm_monitor_scheduled_query_rules_alert_v2.function_exceptions) == 0
    error_message = "Function exceptions log alert should not be created when log alerts are disabled"
  }

  assert {
    condition     = length(azurerm_monitor_scheduled_query_rules_alert_v2.function_availability) == 0
    error_message = "Function availability log alert should not be created when log alerts are disabled"
  }

  assert {
    condition     = length(azurerm_monitor_scheduled_query_rules_alert_v2.function_performance) == 0
    error_message = "Function performance log alert should not be created when log alerts are disabled"
  }
}
