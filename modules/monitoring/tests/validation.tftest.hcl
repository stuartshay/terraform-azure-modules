# Validation tests for monitoring module
# Tests that the module validates input correctly

# Mock the AzureRM provider to avoid authentication requirements
mock_provider "azurerm" {}

# Test that module works with all required variables provided
run "valid_configuration" {
  command = plan

  variables {
    resource_group_name = "rg-test-monitoring"
    location            = "East US"
    workload            = "testapp"
    environment         = "dev"
    location_short      = "eastus"
    subscription_id     = "00000000-0000-0000-0000-000000000000"
    notification_emails = { admin = "admin@example.com" }
    tags                = { Environment = "dev", Project = "testapp" }
  }

  # Verify that the configuration is valid and resources are planned
  assert {
    condition     = azurerm_log_analytics_workspace.main.name == "log-testapp-dev-eastus-001"
    error_message = "Log Analytics Workspace should be created with correct name"
  }

  assert {
    condition     = azurerm_application_insights.main.name == "appi-testapp-dev-eastus-001"
    error_message = "Application Insights should be created with correct name"
  }

  assert {
    condition     = azurerm_monitor_action_group.main.name == "ag-testapp-dev-eastus-001"
    error_message = "Action Group should be created with correct name"
  }
}

# Test with different environment
run "production_environment" {
  command = plan

  variables {
    resource_group_name = "rg-test-monitoring"
    location            = "West US 2"
    workload            = "myapp"
    environment         = "prod"
    location_short      = "westus2"
    subscription_id     = "00000000-0000-0000-0000-000000000000"
    notification_emails = { admin = "admin@example.com", ops = "ops@example.com" }
    tags                = { Environment = "prod", Project = "myapp" }
  }

  # Verify that the configuration works with different values
  assert {
    condition     = azurerm_log_analytics_workspace.main.name == "log-myapp-prod-westus2-001"
    error_message = "Log Analytics Workspace should be created with correct name for prod environment"
  }

  assert {
    condition     = azurerm_application_insights.main.name == "appi-myapp-prod-westus2-001"
    error_message = "Application Insights should be created with correct name for prod environment"
  }

  assert {
    condition     = azurerm_monitor_action_group.main.name == "ag-myapp-prod-westus2-001"
    error_message = "Action Group should be created with correct name for prod environment"
  }

  assert {
    condition     = azurerm_monitor_action_group.main.short_name == "mon-prod"
    error_message = "Action Group short name should be 'mon-prod' for production environment"
  }

  assert {
    condition     = length(azurerm_monitor_action_group.main.email_receiver) == 2
    error_message = "Action Group should have two email receivers configured"
  }
}
