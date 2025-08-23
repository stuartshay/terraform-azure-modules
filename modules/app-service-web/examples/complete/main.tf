# Complete App Service Example
# This example demonstrates all available configuration options for the app-service module

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
  name     = "rg-app-service-web-complete-example"
  location = "East US"

  tags = local.common_tags
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

# Local values for consistent configuration
locals {
  workload    = "webapp"
  environment = "prod"

  common_tags = {
    Environment = local.environment
    Project     = "app-service-web-complete-example"
    Owner       = "platform-team"
    Example     = "complete"
    CostCenter  = "engineering"
  }
}

# Complete app service module configuration
module "app_service" {
  source = "../../"

  # Required variables
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  workload            = local.workload
  environment         = local.environment
  subnet_id           = azurerm_subnet.app_service.id

  # Use S2 SKU for higher performance (only S1 and S2 are allowed)
  sku_name       = "S2"
  python_version = "3.11" # Specific Python version

  # Custom app settings
  app_settings = {
    "ENVIRONMENT"                           = local.environment
    "WEBSITE_RUN_FROM_PACKAGE"              = "1"
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = "your-app-insights-key"
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = "your-connection-string"
    "DATABASE_URL"                          = "your-database-connection-string"
    "REDIS_URL"                             = "your-redis-connection-string"
    "STORAGE_ACCOUNT_NAME"                  = "yourstorageaccount"
    "STORAGE_ACCOUNT_KEY"                   = "your-storage-key"
    "API_BASE_URL"                          = "https://api.example.com"
    "LOG_LEVEL"                             = "INFO"
    "MAX_WORKERS"                           = "4"
  }

  # Comprehensive tagging
  tags = merge(local.common_tags, {
    Tier       = "Premium"
    Backup     = "Required"
    Monitoring = "Enhanced"
    Compliance = "SOC2"
  })
}
