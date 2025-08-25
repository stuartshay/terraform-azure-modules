# Complete App Service Function Example
# This example demonstrates all available configuration options for the app-service-function module

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
  name     = "rg-app-service-function-complete-example"
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

# Local values for consistent configuration
locals {
  workload    = "funcapp"
  environment = "prod"

  common_tags = {
    Environment = local.environment
    Project     = "app-service-function-complete-example"
    Owner       = "platform-team"
    Example     = "complete"
    CostCenter  = "engineering"
  }
}

# Complete function app module configuration
module "function_app" {
  source = "../../"

  # Required variables
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  location_short      = "eus" # East US short name
  workload            = local.workload
  environment         = local.environment
  subnet_id           = azurerm_subnet.functions.id

  # Use EP1 SKU with custom scaling configuration
  sku_name                     = "EP1"
  python_version               = "3.11" # Specific Python version
  always_ready_instances       = 2      # Keep 2 instances always ready
  maximum_elastic_worker_count = 10     # Scale up to 10 instances

  # Enable Application Insights
  enable_application_insights = true

  # Storage account configuration
  storage_account_tier             = "Standard"
  storage_account_replication_type = "LRS"
  enable_storage_versioning        = true
  enable_storage_change_feed       = true
  storage_delete_retention_days    = 30

  # Custom function app settings
  function_app_settings = {
    "ENVIRONMENT"                    = local.environment
    "FUNCTIONS_EXTENSION_VERSION"    = "~4"
    "WEBSITE_RUN_FROM_PACKAGE"       = "1"
    "DATABASE_URL"                   = "your-database-connection-string"
    "REDIS_URL"                      = "your-redis-connection-string"
    "STORAGE_ACCOUNT_NAME"           = "yourstorageaccount"
    "STORAGE_ACCOUNT_KEY"            = "your-storage-key"
    "API_BASE_URL"                   = "https://api.example.com"
    "LOG_LEVEL"                      = "INFO"
    "MAX_WORKERS"                    = "8"
    "AZURE_CLIENT_ID"                = "your-managed-identity-client-id"
    "KEY_VAULT_URL"                  = "https://your-keyvault.vault.azure.net/"
    "EVENT_HUB_CONNECTION_STRING"    = "your-event-hub-connection-string"
    "SERVICE_BUS_CONNECTION_STRING"  = "your-service-bus-connection-string"
    "COSMOS_DB_CONNECTION_STRING"    = "your-cosmos-db-connection-string"
    "BLOB_STORAGE_CONNECTION_STRING" = "your-blob-storage-connection-string"
  }

  # Comprehensive tagging
  tags = merge(local.common_tags, {
    Tier       = "Premium"
    Backup     = "Required"
    Monitoring = "Enhanced"
    Compliance = "SOC2"
    Runtime    = "Python"
    SKU        = "EP1"
  })
}
