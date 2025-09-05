# Basic Application Insights Example
# This example creates a standalone Application Insights instance

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "example" {
  name     = "rg-appinsights-basic-example"
  location = "East US"

  tags = {
    Environment = "Example"
    Purpose     = "Application Insights Basic Demo"
  }
}

# Basic Application Insights (Classic mode)
module "application_insights" {
  source = "../../"

  # Required variables
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  # Custom naming
  name = "appi-basic-example"

  # Basic configuration
  application_type    = "web"
  sampling_percentage = 100

  # Enable smart detection with email notifications
  enable_smart_detection = true
  smart_detection_emails = ["admin@example.com"]

  tags = {
    Environment = "Example"
    Purpose     = "Basic Application Insights"
  }
}
