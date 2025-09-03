# Service Bus Module - Validation Test
# Tests input validation for the Service Bus module

mock_provider "azurerm" {}

run "invalid_sku_test" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    location            = "East US"
    location_short      = "eastus"
    resource_group_name = "rg-test"
    sku                 = "Invalid"
  }

  expect_failures = [
    var.sku,
  ]
}

run "invalid_environment_test" {
  command = plan

  variables {
    workload            = "test"
    environment         = "invalid"
    location            = "East US"
    location_short      = "eastus"
    resource_group_name = "rg-test"
    sku                 = "Standard"
  }

  expect_failures = [
    var.environment,
  ]
}

run "invalid_workload_test" {
  command = plan

  variables {
    workload            = "INVALID_WORKLOAD_NAME"
    environment         = "dev"
    location            = "East US"
    location_short      = "eastus"
    resource_group_name = "rg-test"
    sku                 = "Standard"
  }

  expect_failures = [
    var.workload,
  ]
}

run "invalid_location_short_test" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    location            = "East US"
    location_short      = "INVALID_LOCATION"
    resource_group_name = "rg-test"
    sku                 = "Standard"
  }

  expect_failures = [
    var.location_short,
  ]
}

run "invalid_premium_messaging_units_test" {
  command = plan

  variables {
    workload                = "test"
    environment             = "dev"
    location                = "East US"
    location_short          = "eastus"
    resource_group_name     = "rg-test"
    sku                     = "Premium"
    premium_messaging_units = 3
  }

  expect_failures = [
    var.premium_messaging_units,
  ]
}

run "invalid_premium_messaging_partitions_test" {
  command = plan

  variables {
    workload                     = "test"
    environment                  = "dev"
    location                     = "East US"
    location_short               = "eastus"
    resource_group_name          = "rg-test"
    sku                          = "Premium"
    premium_messaging_partitions = 3
  }

  expect_failures = [
    var.premium_messaging_partitions,
  ]
}

run "invalid_minimum_tls_version_test" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    location            = "East US"
    location_short      = "eastus"
    resource_group_name = "rg-test"
    sku                 = "Standard"
    minimum_tls_version = "1.3"
  }

  expect_failures = [
    var.minimum_tls_version,
  ]
}

run "invalid_identity_type_test" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    location            = "East US"
    location_short      = "eastus"
    resource_group_name = "rg-test"
    sku                 = "Standard"
    identity_type       = "InvalidIdentity"
  }

  expect_failures = [
    var.identity_type,
  ]
}
