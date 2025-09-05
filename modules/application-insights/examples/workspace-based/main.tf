# Workspace-based Application Insights Example
# This example creates Application Insights with Log Analytics Workspace integration

terraform {
  required_version = ">= 1.13.1"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.42.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "example" {
  name     = "rg-appinsights-workspace-example"
  location = "East US"

  tags = {
    Environment = "Example"
    Purpose     = "Application Insights Workspace Demo"
  }
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "example" {
  name                = "log-workspace-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    Environment = "Example"
    Purpose     = "Log Analytics for Application Insights"
  }
}

# Application Insights with Workspace integration
module "application_insights" {
  source = "../../"

  # Required variables
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Custom naming
  name = "appi-workspace-example"

  # Workspace-based configuration
  workspace_id        = azurerm_log_analytics_workspace.example.id
  application_type    = "web"
  sampling_percentage = 100

  # Enable features
  enable_smart_detection = true
  smart_detection_emails = ["admin@example.com"]
  enable_workbook        = true

  # Web tests for availability monitoring
  web_tests = {
    homepage = {
      url           = "https://example.com"
      geo_locations = ["us-east-1", "us-west-1"]
      frequency     = 300
      timeout       = 30
      enabled       = true
    }
  }

  tags = {
    Environment = "Example"
    Purpose     = "Workspace-based Application Insights"
  }
}
