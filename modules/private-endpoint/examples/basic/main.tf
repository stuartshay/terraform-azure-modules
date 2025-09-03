# Basic Private Endpoint Example
# This example demonstrates a simple private endpoint setup for a storage account

terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Data sources for existing infrastructure
data "azurerm_resource_group" "example" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "example" {
  name                = var.virtual_network_name
  resource_group_name = data.azurerm_resource_group.example.name
}

data "azurerm_subnet" "example" {
  name                 = var.subnet_name
  virtual_network_name = data.azurerm_virtual_network.example.name
  resource_group_name  = data.azurerm_resource_group.example.name
}

# Storage Account (example resource to create private endpoint for)
resource "azurerm_storage_account" "example" {
  #checkov:skip=CKV2_AZURE_47:This is an example configuration
  name                     = var.storage_account_name
  resource_group_name      = data.azurerm_resource_group.example.name
  location                 = data.azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Disable public network access when using private endpoints
  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false

  # Security configurations
  https_traffic_only_enabled = true
  min_tls_version            = "TLS1_2"

  tags = var.tags
}

# Private Endpoint using the module
module "storage_private_endpoint" {
  source = "../../"

  name                           = "pe-${azurerm_storage_account.example.name}-blob"
  location                       = data.azurerm_resource_group.example.location
  resource_group_name            = data.azurerm_resource_group.example.name
  subnet_id                      = data.azurerm_subnet.example.id
  private_connection_resource_id = azurerm_storage_account.example.id
  subresource_names              = ["blob"]

  tags = var.tags
}
