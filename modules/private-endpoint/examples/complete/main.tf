# Complete Private Endpoint Example
# This example demonstrates advanced private endpoint setup with DNS integration

terraform {
  required_version = ">= 1.13.1"
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

data "azurerm_subnet" "private_endpoints" {
  name                 = var.private_endpoint_subnet_name
  virtual_network_name = data.azurerm_virtual_network.example.name
  resource_group_name  = data.azurerm_resource_group.example.name
}

# Service Bus Namespace (example resource to create private endpoint for)
resource "azurerm_servicebus_namespace" "example" {
  name                = var.servicebus_namespace_name
  location            = data.azurerm_resource_group.example.location
  resource_group_name = data.azurerm_resource_group.example.name
  sku                 = "Premium"
  capacity            = 1

  # Disable public network access when using private endpoints
  public_network_access_enabled = false

  tags = var.tags
}

# Storage Account (additional example resource)
resource "azurerm_storage_account" "example" {
  #checkov:skip=CKV2_AZURE_40:Shared access key configuration is controlled by variable
  #checkov:skip=CKV2_AZURE_38:Soft delete configuration is controlled by variable
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

# Private DNS Zones
resource "azurerm_private_dns_zone" "servicebus" {
  name                = "privatelink.servicebus.windows.net"
  resource_group_name = data.azurerm_resource_group.example.name

  tags = var.tags
}

resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = data.azurerm_resource_group.example.name

  tags = var.tags
}

resource "azurerm_private_dns_zone" "file" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = data.azurerm_resource_group.example.name

  tags = var.tags
}

# Link Private DNS Zones to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "servicebus" {
  name                  = "link-servicebus-${data.azurerm_virtual_network.example.name}"
  resource_group_name   = data.azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.servicebus.name
  virtual_network_id    = data.azurerm_virtual_network.example.id
  registration_enabled  = false

  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name                  = "link-blob-${data.azurerm_virtual_network.example.name}"
  resource_group_name   = data.azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = data.azurerm_virtual_network.example.id
  registration_enabled  = false

  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "file" {
  name                  = "link-file-${data.azurerm_virtual_network.example.name}"
  resource_group_name   = data.azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.file.name
  virtual_network_id    = data.azurerm_virtual_network.example.id
  registration_enabled  = false

  tags = var.tags
}

# Service Bus Private Endpoint with DNS integration
module "servicebus_private_endpoint" {
  source = "../../"

  name                           = "pe-${azurerm_servicebus_namespace.example.name}-namespace"
  location                       = data.azurerm_resource_group.example.location
  resource_group_name            = data.azurerm_resource_group.example.name
  subnet_id                      = data.azurerm_subnet.private_endpoints.id
  private_connection_resource_id = azurerm_servicebus_namespace.example.id
  subresource_names              = ["namespace"]

  # DNS Integration
  private_dns_zone_ids = [azurerm_private_dns_zone.servicebus.id]

  # Custom naming
  private_service_connection_name = "psc-${azurerm_servicebus_namespace.example.name}-namespace"
  private_dns_zone_group_name     = "pdzg-${azurerm_servicebus_namespace.example.name}-namespace"

  tags = var.tags
}

# Storage Account Private Endpoints (multiple subresources)
module "storage_private_endpoints" {
  source = "../../"

  for_each = {
    blob = {
      subresource_name = "blob"
      dns_zone_id      = azurerm_private_dns_zone.blob.id
    }
    file = {
      subresource_name = "file"
      dns_zone_id      = azurerm_private_dns_zone.file.id
    }
  }

  name                           = "pe-${azurerm_storage_account.example.name}-${each.key}"
  location                       = data.azurerm_resource_group.example.location
  resource_group_name            = data.azurerm_resource_group.example.name
  subnet_id                      = data.azurerm_subnet.private_endpoints.id
  private_connection_resource_id = azurerm_storage_account.example.id
  subresource_names              = [each.value.subresource_name]

  # DNS Integration
  private_dns_zone_ids = [each.value.dns_zone_id]

  # Custom naming
  private_service_connection_name = "psc-${azurerm_storage_account.example.name}-${each.key}"
  private_dns_zone_group_name     = "pdzg-${azurerm_storage_account.example.name}-${each.key}"

  tags = var.tags
}

# Example with manual connection approval (commented out by default)
# module "manual_approval_private_endpoint" {
#   source = "../../"
#
#   name                           = "pe-${azurerm_servicebus_namespace.example.name}-manual"
#   location                       = data.azurerm_resource_group.example.location
#   resource_group_name            = data.azurerm_resource_group.example.name
#   subnet_id                      = data.azurerm_subnet.private_endpoints.id
#   private_connection_resource_id = azurerm_servicebus_namespace.example.id
#   subresource_names              = ["namespace"]
#
#   # Manual approval configuration
#   is_manual_connection = true
#   request_message      = "Please approve this private endpoint connection for Service Bus namespace"
#
#   tags = var.tags
# }
