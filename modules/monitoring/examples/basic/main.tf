# Basic Monitoring Example
# This example demonstrates the minimal configuration required for the monitoring module

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
  name     = "rg-monitoring-basic-example"
  location = "East US"

  tags = local.common_tags
}

# Local values for consistent configuration
locals {
  workload        = "example"
  environment     = "dev"
  location_short  = "eastus"

  common_tags = {
    Environment = local.environment
    Project     = "monitoring-example"
    Owner       = "platform-team"
    Example     = "basic"
  }
}

# Basic monitoring module configuration
module "monitoring" {
  source = "../../"

  # Required variables
  resource_group_name = azurerm_resource_group.example.name
  location           = azurerm_resource_group.example.location
  workload           = local.workload
  environment        = local.environment
  location_short     = local.location_short
  subscription_id    = data.azurerm_client_config.current.subscription_id

  # Basic notification configuration
  notification_emails = {
    admin = "admin@example.com"
  }

  # Use default settings for most options
  # This creates:
  # - Log Analytics Workspace with 30-day retention
  # - Application Insights with 100% sampling
  # - Action Group for notifications
  # - Basic alert rules (when Function Apps are monitored)
  # - Smart detection enabled
  # - Workbook enabled

  tags = local.common_tags
}

# Data source to get current Azure configuration
data "azurerm_client_config" "current" {}
