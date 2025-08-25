# Basic App Service Function Example
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

# Create a virtual network for the example
resource "azurerm_virtual_network" "example" {
  name                = "vnet-${local.workload}-${local.environment}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  tags = local.common_tags
}

# Create a subnet for Function App integration
resource "azurerm_subnet" "functions" {
  name                 = "subnet-functions"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  # Delegate subnet to App Service
  delegation {
    name = "function-delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# Basic function app module configuration
module "function_app" {
  source = "../../"

  # Required variables
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  location_short      = "eus" # East US short name
  workload            = local.workload
  environment         = local.environment
  subnet_id           = azurerm_subnet.functions.id

  # Use EP1 SKU (default - Elastic Premium for production readiness)
  sku_name = "EP1"

  # This creates:
  # - Storage Account for Function App state
  # - App Service Plan with EP1 SKU (Elastic Premium)
  # - Linux Function App with Python 3.13
  # - VNET integration for network isolation
  # - Application Insights for monitoring
  # - HTTPS only enabled
  # - Always on enabled for EP1

  tags = local.common_tags
}
