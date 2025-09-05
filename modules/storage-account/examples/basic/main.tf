# Basic Storage Account Example
# This example creates a simple storage account with minimal configuration

terraform {
  required_version = ">= 1.13.1"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.42.0"
    }
  }
}

# Configure the Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group for this example
resource "azurerm_resource_group" "example" {
  name     = "rg-storage-basic-example"
  location = "East US"

  tags = {
    Environment = "dev"
    Project     = "storage-example"
    Example     = "basic"
  }
}

# Basic storage account module usage
module "storage_account" {
  source = "../../"

  # Required variables
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  environment         = "dev"
  workload            = "example"
  location_short      = "eastus"

  # Basic configuration
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  access_tier              = "Hot"

  # Create a simple blob container
  blob_containers = {
    documents = {
      access_type = "private"
    }
  }

  tags = {
    Environment = "dev"
    Project     = "storage-example"
    Example     = "basic"
  }
}
