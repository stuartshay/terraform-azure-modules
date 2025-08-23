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
  name     = "rg-app-service-complete-example"
  location = "East US"

  tags = local.common_tags
}

# Local values for consistent configuration
locals {
  workload    = "webapp"
  environment = "prod"

  common_tags = {
    Environment = local.environment
    Project     = "app-service-complete-example"
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

  # Optional variables with custom values
  sku_name       = "P1v3" # Premium v3 tier for production
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
