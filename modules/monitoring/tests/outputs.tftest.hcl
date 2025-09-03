# Output tests for monitoring module
# Tests that all essential outputs are present and correctly formatted

# Mock the AzureRM provider to avoid authentication requirements
mock_provider "azurerm" {}

# Test that all essential outputs are present
run "test_outputs" {
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

  # Verify Log Analytics Workspace outputs
  assert {
    condition     = output.log_analytics_workspace_name == "log-testapp-dev-eastus-001"
    error_message = "Log Analytics Workspace name output should match expected value"
  }

  # Verify Application Insights outputs
  assert {
    condition     = output.application_insights_name == "appi-testapp-dev-eastus-001"
    error_message = "Application Insights name output should match expected value"
  }

  # Verify Action Group outputs
  assert {
    condition     = output.action_group_name == "ag-testapp-dev-eastus-001"
    error_message = "Action Group name output should match expected value"
  }

  assert {
    condition     = output.action_group_short_name == "mon-dev"
    error_message = "Action Group short name output should match expected value"
  }

  # Verify monitoring configuration output structure
  assert {
    condition     = output.monitoring_configuration.log_analytics_workspace.name == "log-testapp-dev-eastus-001"
    error_message = "Monitoring configuration should contain correct Log Analytics workspace name"
  }

  assert {
    condition     = output.monitoring_configuration.application_insights.name == "appi-testapp-dev-eastus-001"
    error_message = "Monitoring configuration should contain correct Application Insights name"
  }

  assert {
    condition     = output.monitoring_configuration.action_group.name == "ag-testapp-dev-eastus-001"
    error_message = "Monitoring configuration should contain correct Action Group name"
  }

  # Verify resource names output
  assert {
    condition     = output.resource_names.log_analytics_workspace == "log-testapp-dev-eastus-001"
    error_message = "Resource names should contain correct Log Analytics workspace name"
  }

  assert {
    condition     = output.resource_names.application_insights == "appi-testapp-dev-eastus-001"
    error_message = "Resource names should contain correct Application Insights name"
  }

  assert {
    condition     = output.resource_names.action_group == "ag-testapp-dev-eastus-001"
    error_message = "Resource names should contain correct Action Group name"
  }
}
