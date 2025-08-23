# Complete Networking Example
# This example demonstrates all features of the networking module

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
  name     = "rg-networking-complete-example"
  location = "East US"

  tags = {
    Environment = "prod"
    Project     = "networking-example"
    Example     = "complete"
    CostCenter  = "IT"
  }
}

# Create Log Analytics Workspace for traffic analytics
resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-networking-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 91

  tags = {
    Environment = "prod"
    Project     = "networking-example"
    Example     = "complete"
  }
}

# Complete networking module usage with all features
module "networking" {
  source = "../../"

  # Required variables
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  environment         = "prod"
  workload            = "example"
  location_short      = "eastus"

  # Network configuration
  vnet_address_space = ["10.0.0.0/16"]
  subnet_config = {
    appservice = {
      address_prefixes  = ["10.0.1.0/24"]
      service_endpoints = ["Microsoft.Web", "Microsoft.Storage"]
      delegation = {
        name = "app-service-delegation"
        service_delegation = {
          name    = "Microsoft.Web/serverFarms"
          actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
        }
      }
    }
    functions = {
      address_prefixes  = ["10.0.2.0/24"]
      service_endpoints = ["Microsoft.Web", "Microsoft.Storage", "Microsoft.KeyVault"]
      delegation = {
        name = "function-delegation"
        service_delegation = {
          name    = "Microsoft.Web/serverFarms"
          actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
        }
      }
    }
    privateendpoints = {
      address_prefixes  = ["10.0.3.0/24"]
      service_endpoints = []
    }
    database = {
      address_prefixes  = ["10.0.4.0/24"]
      service_endpoints = ["Microsoft.Sql"]
    }
    management = {
      address_prefixes  = ["10.0.5.0/24"]
      service_endpoints = ["Microsoft.Storage"]
    }
  }

  # Enable all optional features
  enable_custom_routes     = true
  enable_network_watcher   = true
  enable_flow_logs         = true
  enable_traffic_analytics = true
  flow_log_retention_days  = 91

  # Enable legacy NSG flow logs for demonstration (not recommended for production)
  enable_legacy_nsg_flow_logs = false

  # Log Analytics for traffic analytics
  log_analytics_workspace_id          = azurerm_log_analytics_workspace.example.workspace_id
  log_analytics_workspace_resource_id = azurerm_log_analytics_workspace.example.id

  tags = {
    Environment = "prod"
    Project     = "networking-example"
    Example     = "complete"
    CostCenter  = "IT"
  }
}
