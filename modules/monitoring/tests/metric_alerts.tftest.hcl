# Metric alerts tests for monitoring module
# Tests that metric alerts for CPU, memory, errors, and response time are created for monitored function app

# Mock the AzureRM provider to avoid authentication requirements
mock_provider "azurerm" {}

# Test metric alerts creation for function apps
run "test_metric_alerts" {
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
    tags                = { Environment = "dev", Project = "testapp" }
  }

  # Verify CPU metric alert is created
  assert {
    condition     = azurerm_monitor_metric_alert.function_app_cpu["testfunc"].name == "alert-testfunc-cpu-high"
    error_message = "CPU metric alert should be created with correct name"
  }

  assert {
    condition     = azurerm_monitor_metric_alert.function_app_cpu["testfunc"].severity == 2
    error_message = "CPU metric alert should have severity 2"
  }

  assert {
    condition     = azurerm_monitor_metric_alert.function_app_cpu["testfunc"].criteria[0].metric_name == "CpuPercentage"
    error_message = "CPU metric alert should monitor CpuPercentage metric"
  }

  # Verify Memory metric alert is created
  assert {
    condition     = azurerm_monitor_metric_alert.function_app_memory["testfunc"].name == "alert-testfunc-memory-high"
    error_message = "Memory metric alert should be created with correct name"
  }

  assert {
    condition     = azurerm_monitor_metric_alert.function_app_memory["testfunc"].criteria[0].metric_name == "MemoryPercentage"
    error_message = "Memory metric alert should monitor MemoryPercentage metric"
  }

  # Verify HTTP errors metric alert is created
  assert {
    condition     = azurerm_monitor_metric_alert.function_app_errors["testfunc"].name == "alert-testfunc-http-errors"
    error_message = "HTTP errors metric alert should be created with correct name"
  }

  assert {
    condition     = azurerm_monitor_metric_alert.function_app_errors["testfunc"].severity == 1
    error_message = "HTTP errors metric alert should have severity 1"
  }

  assert {
    condition     = azurerm_monitor_metric_alert.function_app_errors["testfunc"].criteria[0].metric_name == "Http5xx"
    error_message = "HTTP errors metric alert should monitor Http5xx metric"
  }

  # Verify Response time metric alert is created
  assert {
    condition     = azurerm_monitor_metric_alert.function_app_response_time["testfunc"].name == "alert-testfunc-response-time"
    error_message = "Response time metric alert should be created with correct name"
  }

  assert {
    condition     = azurerm_monitor_metric_alert.function_app_response_time["testfunc"].criteria[0].metric_name == "AverageResponseTime"
    error_message = "Response time metric alert should monitor AverageResponseTime metric"
  }

  # Verify all alerts have action blocks configured
  assert {
    condition     = length(azurerm_monitor_metric_alert.function_app_cpu["testfunc"].action) > 0
    error_message = "CPU metric alert should have action blocks configured"
  }

  assert {
    condition     = length(azurerm_monitor_metric_alert.function_app_memory["testfunc"].action) > 0
    error_message = "Memory metric alert should have action blocks configured"
  }

  assert {
    condition     = length(azurerm_monitor_metric_alert.function_app_errors["testfunc"].action) > 0
    error_message = "HTTP errors metric alert should have action blocks configured"
  }

  assert {
    condition     = length(azurerm_monitor_metric_alert.function_app_response_time["testfunc"].action) > 0
    error_message = "Response time metric alert should have action blocks configured"
  }
}

# Test metric alerts with custom thresholds
run "test_custom_thresholds" {
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
    notification_emails     = { admin = "admin@example.com" }
    cpu_threshold           = 90
    memory_threshold        = 85
    error_threshold         = 10
    response_time_threshold = 5000
    tags                    = { Environment = "prod", Project = "testapp" }
  }

  # Verify custom thresholds are applied
  assert {
    condition     = azurerm_monitor_metric_alert.function_app_cpu["prodfunc"].criteria[0].threshold == 90
    error_message = "CPU metric alert should use custom threshold of 90"
  }

  assert {
    condition     = azurerm_monitor_metric_alert.function_app_memory["prodfunc"].criteria[0].threshold == 85
    error_message = "Memory metric alert should use custom threshold of 85"
  }

  assert {
    condition     = azurerm_monitor_metric_alert.function_app_errors["prodfunc"].criteria[0].threshold == 10
    error_message = "HTTP errors metric alert should use custom threshold of 10"
  }

  assert {
    condition     = azurerm_monitor_metric_alert.function_app_response_time["prodfunc"].criteria[0].threshold == 5000
    error_message = "Response time metric alert should use custom threshold of 5000"
  }
}
