# Basic App Service Example
# This example demonstrates the minimal configuration required for the app-service-plan-web module

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
  name     = "rg-app-service-plan-web-basic-example"
  location = "East US"

  tags = local.common_tags
}

# Local values for consistent configuration
locals {
  workload    = "example"
  environment = "dev"

  common_tags = {
    Environment = local.environment
    Project     = "app-service-plan-web-example"
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

# Create a subnet for App Service integration
resource "azurerm_subnet" "app_service" {
  name                 = "subnet-app-service"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  # Delegate subnet to App Service
  delegation {
    name = "app-service-delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
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
  subnet_id           = azurerm_subnet.app_service.id

  # Use S1 SKU (only S1 and S2 are allowed)
  sku_name = "S1"

  # This creates:
  # - App Service Plan with S1 SKU
  # - Linux Web App with Python 3.13
  # - VNET integration for network isolation
  # - HTTPS only enabled
  # - Always on enabled
  # - HTTP/2 enabled
  # - FTP disabled

  tags = local.common_tags
}
