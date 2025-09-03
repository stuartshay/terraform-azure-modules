# Activity log alerts tests for monitoring module
# Tests that activity log alerts for resource and service health are created

# Mock the AzureRM provider to avoid authentication requirements
mock_provider "azurerm" {}

# Test activity log alerts creation when enabled
run "test_activity_log_alerts_enabled" {
  command = plan

  variables {
    resource_group_name        = "rg-test-monitoring"
    location                   = "East US"
    workload                   = "testapp"
    environment                = "dev"
    location_short             = "eastus"
    subscription_id            = "00000000-0000-0000-0000-000000000000"
    notification_emails        = { admin = "admin@example.com" }
    enable_activity_log_alerts = true
    tags                       = { Environment = "dev", Project = "testapp" }
  }

  # Verify resource health activity log alert is created
  assert {
    condition     = azurerm_monitor_activity_log_alert.resource_health[0].name == "alert-resource-health"
    error_message = "Resource health activity log alert should be created with correct name"
  }

  assert {
    condition     = azurerm_monitor_activity_log_alert.resource_health[0].location == "global"
    error_message = "Resource health activity log alert should have global location"
  }

  assert {
    condition     = azurerm_monitor_activity_log_alert.resource_health[0].criteria[0].category == "ResourceHealth"
    error_message = "Resource health activity log alert should monitor ResourceHealth category"
  }

  assert {
    condition     = contains(azurerm_monitor_activity_log_alert.resource_health[0].criteria[0].resource_health[0].current, "Degraded")
    error_message = "Resource health activity log alert should monitor Degraded status"
  }

  assert {
    condition     = contains(azurerm_monitor_activity_log_alert.resource_health[0].criteria[0].resource_health[0].current, "Unavailable")
    error_message = "Resource health activity log alert should monitor Unavailable status"
  }

  assert {
    condition     = contains(azurerm_monitor_activity_log_alert.resource_health[0].criteria[0].resource_health[0].previous, "Available")
    error_message = "Resource health activity log alert should monitor transition from Available status"
  }

  # Verify service health activity log alert is created
  assert {
    condition     = azurerm_monitor_activity_log_alert.service_health[0].name == "alert-service-health"
    error_message = "Service health activity log alert should be created with correct name"
  }

  assert {
    condition     = azurerm_monitor_activity_log_alert.service_health[0].location == "global"
    error_message = "Service health activity log alert should have global location"
  }

  assert {
    condition     = azurerm_monitor_activity_log_alert.service_health[0].criteria[0].category == "ServiceHealth"
    error_message = "Service health activity log alert should monitor ServiceHealth category"
  }

  assert {
    condition     = contains(azurerm_monitor_activity_log_alert.service_health[0].criteria[0].service_health[0].events, "Incident")
    error_message = "Service health activity log alert should monitor Incident events"
  }

  assert {
    condition     = contains(azurerm_monitor_activity_log_alert.service_health[0].criteria[0].service_health[0].events, "Maintenance")
    error_message = "Service health activity log alert should monitor Maintenance events"
  }

  assert {
    condition     = contains(azurerm_monitor_activity_log_alert.service_health[0].criteria[0].service_health[0].locations, "East US")
    error_message = "Service health activity log alert should monitor the specified location"
  }

  assert {
    condition     = contains(azurerm_monitor_activity_log_alert.service_health[0].criteria[0].service_health[0].services, "App Service")
    error_message = "Service health activity log alert should monitor App Service"
  }

  assert {
    condition     = contains(azurerm_monitor_activity_log_alert.service_health[0].criteria[0].service_health[0].services, "Application Insights")
    error_message = "Service health activity log alert should monitor Application Insights"
  }

  assert {
    condition     = contains(azurerm_monitor_activity_log_alert.service_health[0].criteria[0].service_health[0].services, "Log Analytics")
    error_message = "Service health activity log alert should monitor Log Analytics"
  }

  # Verify both alerts have action blocks configured
  assert {
    condition     = length(azurerm_monitor_activity_log_alert.resource_health[0].action) > 0
    error_message = "Resource health activity log alert should have action blocks configured"
  }

  assert {
    condition     = length(azurerm_monitor_activity_log_alert.service_health[0].action) > 0
    error_message = "Service health activity log alert should have action blocks configured"
  }

  # Verify both alerts are scoped to the subscription
  assert {
    condition     = contains(azurerm_monitor_activity_log_alert.resource_health[0].scopes, "/subscriptions/00000000-0000-0000-0000-000000000000")
    error_message = "Resource health activity log alert should be scoped to the subscription"
  }

  assert {
    condition     = contains(azurerm_monitor_activity_log_alert.service_health[0].scopes, "/subscriptions/00000000-0000-0000-0000-000000000000")
    error_message = "Service health activity log alert should be scoped to the subscription"
  }
}

# Test activity log alerts disabled
run "test_activity_log_alerts_disabled" {
  command = plan

  variables {
    resource_group_name        = "rg-test-monitoring"
    location                   = "East US"
    workload                   = "testapp"
    environment                = "dev"
    location_short             = "eastus"
    subscription_id            = "00000000-0000-0000-0000-000000000000"
    notification_emails        = { admin = "admin@example.com" }
    enable_activity_log_alerts = false
    tags                       = { Environment = "dev", Project = "testapp" }
  }

  # Verify activity log alerts are not created when disabled
  assert {
    condition     = length(azurerm_monitor_activity_log_alert.resource_health) == 0
    error_message = "Resource health activity log alert should not be created when activity log alerts are disabled"
  }

  assert {
    condition     = length(azurerm_monitor_activity_log_alert.service_health) == 0
    error_message = "Service health activity log alert should not be created when activity log alerts are disabled"
  }
}

# Test activity log alerts with different location
run "test_activity_log_alerts_different_location" {
  command = plan

  variables {
    resource_group_name        = "rg-test-monitoring"
    location                   = "West US 2"
    workload                   = "testapp"
    environment                = "prod"
    location_short             = "westus2"
    subscription_id            = "00000000-0000-0000-0000-000000000000"
    notification_emails        = { admin = "admin@example.com" }
    enable_activity_log_alerts = true
    tags                       = { Environment = "prod", Project = "testapp" }
  }

  # Verify service health alert monitors the correct location
  assert {
    condition     = contains(azurerm_monitor_activity_log_alert.service_health[0].criteria[0].service_health[0].locations, "West US 2")
    error_message = "Service health activity log alert should monitor the West US 2 location"
  }
}
