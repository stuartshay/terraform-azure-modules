# Validation tests for app-service-plan-function module
# Tests input validation rules and error conditions

# Mock the AzureRM provider to avoid authentication requirements
mock_provider "azurerm" {
  # Mock provider configuration
}

# Test invalid OS type validation
run "invalid_os_type" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    os_type             = "MacOS"
  }

  expect_failures = [
    var.os_type,
  ]
}

# Test invalid SKU name validation
run "invalid_sku_name" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    sku_name            = "S1"
  }

  expect_failures = [
    var.sku_name,
  ]
}

# Test maximum elastic worker count below minimum
run "worker_count_below_minimum" {
  command = plan

  variables {
    workload                     = "test"
    environment                  = "dev"
    resource_group_name          = "rg-test-dev-001"
    location                     = "East US"
    maximum_elastic_worker_count = 0
  }

  expect_failures = [
    var.maximum_elastic_worker_count,
  ]
}

# Test maximum elastic worker count above maximum
run "worker_count_above_maximum" {
  command = plan

  variables {
    workload                     = "test"
    environment                  = "dev"
    resource_group_name          = "rg-test-dev-001"
    location                     = "East US"
    maximum_elastic_worker_count = 25
  }

  expect_failures = [
    var.maximum_elastic_worker_count,
  ]
}

# Test valid OS type values
run "valid_linux_os_type" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    os_type             = "Linux"
  }

  assert {
    condition     = azurerm_service_plan.functions.os_type == "Linux"
    error_message = "Linux should be a valid OS type"
  }
}

run "valid_windows_os_type" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    os_type             = "Windows"
  }

  assert {
    condition     = azurerm_service_plan.functions.os_type == "Windows"
    error_message = "Windows should be a valid OS type"
  }
}

# Test valid SKU values
run "valid_ep1_sku" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    sku_name            = "EP1"
  }

  assert {
    condition     = azurerm_service_plan.functions.sku_name == "EP1"
    error_message = "EP1 should be a valid SKU"
  }
}

run "valid_ep2_sku" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    sku_name            = "EP2"
  }

  assert {
    condition     = azurerm_service_plan.functions.sku_name == "EP2"
    error_message = "EP2 should be a valid SKU"
  }
}

run "valid_ep3_sku" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    sku_name            = "EP3"
  }

  assert {
    condition     = azurerm_service_plan.functions.sku_name == "EP3"
    error_message = "EP3 should be a valid SKU"
  }
}

# Test valid worker count boundaries
run "minimum_worker_count" {
  command = plan

  variables {
    workload                     = "test"
    environment                  = "dev"
    resource_group_name          = "rg-test-dev-001"
    location                     = "East US"
    maximum_elastic_worker_count = 1
  }

  assert {
    condition     = azurerm_service_plan.functions.maximum_elastic_worker_count == 1
    error_message = "Minimum worker count of 1 should be valid"
  }
}

run "maximum_worker_count" {
  command = plan

  variables {
    workload                     = "test"
    environment                  = "dev"
    resource_group_name          = "rg-test-dev-001"
    location                     = "East US"
    maximum_elastic_worker_count = 20
  }

  assert {
    condition     = azurerm_service_plan.functions.maximum_elastic_worker_count == 20
    error_message = "Maximum worker count of 20 should be valid"
  }
}
