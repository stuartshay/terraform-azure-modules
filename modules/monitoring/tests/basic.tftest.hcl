# Basic functionality tests for monitoring module
# Tests the core functionality of creating monitoring resources

# Mock the AzureRM provider to avoid authentication requirements
mock_provider "azurerm" {}

# Test basic monitoring resources creation with required variables
run "basic_monitoring_creation" {
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

  # Verify Log Analytics Workspace is created
  assert {
    condition     = azurerm_log_analytics_workspace.main.name == "log-testapp-dev-eastus-001"
    error_message = "Log Analytics Workspace name should follow the naming convention"
  }

  assert {
    condition     = azurerm_log_analytics_workspace.main.resource_group_name == "rg-test-monitoring"
    error_message = "Log Analytics Workspace should be in the correct resource group"
  }

  assert {
    condition     = azurerm_log_analytics_workspace.main.location == "East US"
    error_message = "Log Analytics Workspace should be in the correct location"
  }

  # Verify Application Insights is created
  assert {
    condition     = azurerm_application_insights.main.name == "appi-testapp-dev-eastus-001"
    error_message = "Application Insights name should follow the naming convention"
  }

  assert {
    condition     = azurerm_application_insights.main.resource_group_name == "rg-test-monitoring"
    error_message = "Application Insights should be in the correct resource group"
  }

  assert {
    condition     = azurerm_application_insights.main.application_type == "web"
    error_message = "Application Insights should be of type 'web'"
  }

  # Verify Action Group is created
  assert {
    condition     = azurerm_monitor_action_group.main.name == "ag-testapp-dev-eastus-001"
    error_message = "Action Group name should follow the naming convention"
  }

  assert {
    condition     = azurerm_monitor_action_group.main.short_name == "mon-dev"
    error_message = "Action Group short name should be 'mon-dev'"
  }

  # Verify email receiver is configured
  assert {
    condition     = length(azurerm_monitor_action_group.main.email_receiver) == 1
    error_message = "Action Group should have one email receiver configured"
  }
}
