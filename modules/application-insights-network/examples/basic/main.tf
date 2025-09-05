# Basic Example for Application Insights Network Module
# This example demonstrates how to use the application-insights-network module

# Configure the Azure Provider
terraform {
  required_version = ">= 1.13.1"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.42.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Example resource group (in real usage, this would likely already exist)
resource "azurerm_resource_group" "example" {
  name     = "rg-appinsights-network-example"
  location = "East US"

  tags = {
    Environment = "Example"
    Purpose     = "Application Insights Network Module Demo"
  }
}

# Example Application Insights (in real usage, this would be created by the application-insights module)
resource "azurerm_log_analytics_workspace" "example" {
  name                = "log-example-dev-eus-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    Environment = "Example"
    Purpose     = "Application Insights Network Module Demo"
  }
}

resource "azurerm_application_insights" "example" {
  name                = "appi-example-dev-eus-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  workspace_id        = azurerm_log_analytics_workspace.example.id
  application_type    = "web"

  tags = {
    Environment = "Example"
    Purpose     = "Application Insights Network Module Demo"
  }
}

# Application Insights Network Module
module "app_insights_network" {
  source = "../../"

  # Required variables
  resource_group_name       = azurerm_resource_group.example.name
  location                  = azurerm_resource_group.example.location
  application_insights_name = azurerm_application_insights.example.name

  # Optional naming
  workload       = "example"
  environment    = "dev"
  location_short = "eus"

  # Optional Log Analytics integration
  log_analytics_workspace_name = azurerm_log_analytics_workspace.example.name

  # Use default alert thresholds and enable all alerts
  enable_response_time_alert  = true
  enable_failed_request_alert = true
  enable_exception_alert      = true
  enable_availability_alert   = true
  enable_server_error_alert   = true

  # Enable dashboard
  enable_dashboard       = true
  dashboard_display_name = "Example Application Monitoring"

  tags = {
    Environment = "Example"
    Purpose     = "Application Insights Network Module Demo"
  }

  depends_on = [azurerm_application_insights.example]
}
