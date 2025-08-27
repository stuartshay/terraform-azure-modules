# Provider configuration for tests
# This file provides the necessary provider configuration for all test files

provider "azurerm" {
  features {}

  # Skip provider registration for testing
  resource_provider_registrations = "none"
}
