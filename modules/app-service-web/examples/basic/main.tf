# Basic App Service Example
# This example demonstrates the minimal configuration required for the app-service-web module

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
  name     = "rg-app-service-web-basic-example"
  location = "East US"

  tags = local.common_tags
}

# Local values for consistent configuration
locals {
  workload    = "example"
  environment = "dev"

  common_tags = {
    Environment = local.environment
    Project     = "app-service-web-example"
    Owner       = "platform-team"
    Example     = "basic"
  }
}

# Basic app service module configuration
module "app_service" {
  source = "../../"

  # Required variables
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  workload            = local.workload
  environment         = local.environment

  # Use default settings for most options
  # This creates:
  # - App Service Plan with B1 SKU
  # - Linux Web App with Python 3.13
  # - HTTPS only enabled
  # - Always on enabled
  # - HTTP/2 enabled
  # - FTP disabled

  tags = local.common_tags
}
