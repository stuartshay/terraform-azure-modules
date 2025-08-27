# Output validation tests for app-service-plan-function module
# Tests that all outputs are correctly populated and formatted

# Mock the AzureRM provider to avoid authentication requirements
mock_provider "azurerm" {
  # Mock provider configuration
}

# Test all outputs are populated correctly
run "verify_outputs" {
  command = plan

  variables {
    workload            = "output-test"
    environment         = "dev"
    resource_group_name = "rg-output-test-dev-001"
    location            = "East US"
    os_type             = "Linux"
    sku_name            = "EP2"
    tags = {
      Environment = "Development"
      Purpose     = "Testing"
    }
  }

  # Test app_service_plan_name output matches expected naming convention
  assert {
    condition     = output.app_service_plan_name == "asp-output-test-functions-dev-001"
    error_message = "app_service_plan_name output should match the expected naming convention"
  }

  # Test app_service_plan_sku output matches input
  assert {
    condition     = output.app_service_plan_sku == "EP2"
    error_message = "app_service_plan_sku output should match the specified SKU"
  }

  # Test app_service_plan_os_type output matches input
  assert {
    condition     = output.app_service_plan_os_type == "Linux"
    error_message = "app_service_plan_os_type output should match the specified OS type"
  }

  # Test output types and formats
  assert {
    condition     = can(regex("^asp-.*", output.app_service_plan_name))
    error_message = "app_service_plan_name should start with 'asp-' prefix"
  }

  assert {
    condition     = contains(["Linux", "Windows"], output.app_service_plan_os_type)
    error_message = "app_service_plan_os_type should be either Linux or Windows"
  }

  assert {
    condition     = contains(["EP1", "EP2", "EP3"], output.app_service_plan_sku)
    error_message = "app_service_plan_sku should be one of the Elastic Premium SKUs"
  }

  # Test that outputs are not null or empty
  assert {
    condition     = output.app_service_plan_name != null && output.app_service_plan_name != ""
    error_message = "app_service_plan_name should not be null or empty"
  }

  assert {
    condition     = output.app_service_plan_sku != null && output.app_service_plan_sku != ""
    error_message = "app_service_plan_sku should not be null or empty"
  }

  assert {
    condition     = output.app_service_plan_os_type != null && output.app_service_plan_os_type != ""
    error_message = "app_service_plan_os_type should not be null or empty"
  }
}
