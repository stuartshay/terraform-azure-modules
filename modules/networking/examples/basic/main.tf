# Basic Networking Example
# This example creates a simple VNet with one subnet and basic security configuration

terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.40"
    }
  }
}

# Configure the Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group for this example
resource "azurerm_resource_group" "example" {
  name     = "rg-networking-basic-example"
  location = "East US"

  tags = {
    Environment = "dev"
    Project     = "networking-example"
    Example     = "basic"
  }
}

# Basic networking module usage
module "networking" {
  source = "../../"

  # Required variables
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  environment         = "dev"
  workload            = "example"
  location_short      = "eastus"

  # Network configuration
  vnet_address_space = ["10.0.0.0/16"]
  subnet_config = {
    default = {
      address_prefixes  = ["10.0.1.0/24"]
      service_endpoints = []
    }
  }

  tags = {
    Environment = "dev"
    Project     = "networking-example"
    Example     = "basic"
  }
}
