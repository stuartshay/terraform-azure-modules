# Basic functionality tests for app-service-plan-function module
# Tests the core functionality of creating an Azure App Service Plan for Functions

# Mock the AzureRM provider to avoid authentication requirements
mock_provider "azurerm" {}

# Test basic App Service Plan creation with default values
run "basic_app_service_plan_creation" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
  }

  # Verify the App Service Plan is created with correct attributes
  assert {
    condition     = azurerm_service_plan.functions.name == "asp-test-functions-dev-001"
    error_message = "App Service Plan name should follow the naming convention"
  }

  assert {
    condition     = azurerm_service_plan.functions.resource_group_name == "rg-test-dev-001"
    error_message = "Resource group name should match the input variable"
  }

  assert {
    condition     = azurerm_service_plan.functions.location == "East US"
    error_message = "Location should match the input variable"
  }

  assert {
    condition     = azurerm_service_plan.functions.os_type == "Linux"
    error_message = "Default OS type should be Linux"
  }

  assert {
    condition     = azurerm_service_plan.functions.sku_name == "EP1"
    error_message = "Default SKU should be EP1"
  }

  assert {
    condition     = azurerm_service_plan.functions.maximum_elastic_worker_count == 3
    error_message = "Default maximum elastic worker count should be 3"
  }
}

# Test with Windows OS type
run "windows_app_service_plan" {
  command = plan

  variables {
    workload            = "test"
    environment         = "prod"
    resource_group_name = "rg-test-prod-001"
    location            = "West US 2"
    os_type             = "Windows"
    sku_name            = "EP2"
  }

  assert {
    condition     = azurerm_service_plan.functions.name == "asp-test-functions-prod-001"
    error_message = "App Service Plan name should follow the naming convention"
  }

  assert {
    condition     = azurerm_service_plan.functions.os_type == "Windows"
    error_message = "OS type should be Windows when specified"
  }

  assert {
    condition     = azurerm_service_plan.functions.sku_name == "EP2"
    error_message = "SKU should be EP2 when specified"
  }
}

# Test with EP3 SKU and custom worker count
run "premium_app_service_plan" {
  command = plan

  variables {
    workload                     = "premium"
    environment                  = "prod"
    resource_group_name          = "rg-premium-prod-001"
    location                     = "North Europe"
    sku_name                     = "EP3"
    maximum_elastic_worker_count = 10
    tags = {
      Environment = "Production"
      Project     = "Premium Functions"
    }
  }

  assert {
    condition     = azurerm_service_plan.functions.name == "asp-premium-functions-prod-001"
    error_message = "App Service Plan name should follow the naming convention"
  }

  assert {
    condition     = azurerm_service_plan.functions.sku_name == "EP3"
    error_message = "SKU should be EP3 when specified"
  }

  assert {
    condition     = azurerm_service_plan.functions.maximum_elastic_worker_count == 10
    error_message = "Maximum elastic worker count should be 10 when specified"
  }

  assert {
    condition     = length(azurerm_service_plan.functions.tags) == 2
    error_message = "Tags should be applied when provided"
  }
}

# Test with all supported SKU types
run "test_all_sku_types" {
  command = plan

  variables {
    workload            = "sku-test"
    environment         = "test"
    resource_group_name = "rg-sku-test-001"
    location            = "Central US"
    sku_name            = "EP1"
  }

  assert {
    condition     = contains(["EP1", "EP2", "EP3"], azurerm_service_plan.functions.sku_name)
    error_message = "SKU should be one of the supported Elastic Premium tiers"
  }
}
