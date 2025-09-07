# Basic Application Insights Billing Example
# This example demonstrates basic usage of the Application Insights Billing module

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

# Example resource group (in real usage, this would likely already exist)
resource "azurerm_resource_group" "example" {
  name     = "rg-billing-example-dev-eus-001"
  location = "East US"

  tags = {
    Environment = "Development"
    Project     = "BillingExample"
    Purpose     = "Testing"
  }
}

# Example Application Insights (in real usage, this would likely already exist)
resource "azurerm_application_insights" "example" {
  name                = "appi-billing-example-dev-eus-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  application_type    = "web"

  tags = {
    Environment = "Development"
    Project     = "BillingExample"
  }
}

# Basic Application Insights Billing module usage
module "app_insights_billing" {
  source = "../../"

  # Required variables
  resource_group_name       = azurerm_resource_group.example.name
  location                  = azurerm_resource_group.example.location
  application_insights_name = azurerm_application_insights.example.name

  # Basic budget configuration
  monthly_budget_amount   = 100  # $100/month for development
  quarterly_budget_amount = 300  # $300/quarter
  annual_budget_amount    = 1200 # $1200/year

  # Notification emails for budget alerts
  budget_notification_emails = [
    "dev-team@example.com"
  ]

  # Simplified alerting for development environment
  budget_alert_thresholds  = [90, 100] # Alert at 90% and 100%
  enable_forecast_alerts   = false     # Disable forecast alerts for dev
  enable_anomaly_detection = false     # Disable anomaly detection for dev
  enable_cost_alerts       = false     # Disable advanced cost alerts for dev

  # Optional naming
  workload    = "billing-example"
  environment = "dev"

  tags = {
    Environment = "Development"
    Project     = "BillingExample"
    Purpose     = "Testing"
  }
}
