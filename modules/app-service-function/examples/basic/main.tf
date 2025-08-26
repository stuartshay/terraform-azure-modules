# Basic App Service Plan for Functions Example
# This example demonstrates the minimal configuration required for the app-service-function module

terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.40"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create a resource group for this example
resource "azurerm_resource_group" "example" {
  name     = "rg-app-service-function-basic-example"
  location = "East US"

  tags = local.common_tags
}

# Local values for consistent configuration
locals {
  workload    = "example"
  environment = "dev"

  common_tags = {
    Environment = local.environment
    Project     = "app-service-function-example"
    Owner       = "platform-team"
    Example     = "basic"
  }
}

# Basic App Service Plan for Functions
module "function_app_service_plan" {
  source = "../../"

  # Required variables
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  workload            = local.workload
  environment         = local.environment

  # Use EP1 SKU (default - Elastic Premium for production readiness)
  sku_name = "EP1"
  os_type  = "Linux"

  # This creates:
  # - App Service Plan with EP1 SKU (Elastic Premium)
  # - Linux operating system support
  # - Elastic scaling capabilities
  # - Ready for Function App deployment

  tags = local.common_tags
}
