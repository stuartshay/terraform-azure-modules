# Basic Service Bus Example
# This example creates a basic Service Bus namespace with minimal configuration

# Configure the Azure Provider
terraform {
  required_version = ">= 1.13.1"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=> 4.42.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create a resource group for this example
resource "azurerm_resource_group" "example" {
  name     = "rg-servicebus-basic-example"
  location = "East US"
}

# Basic Service Bus namespace
module "service_bus" {
  source = "../../"

  # Required variables
  workload            = "example"
  environment         = "dev"
  location            = azurerm_resource_group.example.location
  location_short      = "eastus"
  resource_group_name = azurerm_resource_group.example.name

  # Basic configuration
  sku = "Standard"

  # Tags
  tags = {
    Environment = "dev"
    Purpose     = "example"
    ManagedBy   = "terraform"
  }
}
