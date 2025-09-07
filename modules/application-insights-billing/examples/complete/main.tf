# Complete Application Insights Billing Example
# This example demonstrates advanced usage with all features enabled

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
  name     = "rg-billing-complete-prod-eus-001"
  location = "East US"

  tags = {
    Environment = "Production"
    Project     = "BillingComplete"
    CostCenter  = "Engineering"
    Owner       = "Platform Team"
  }
}

# Log Analytics Workspace for advanced cost queries
resource "azurerm_log_analytics_workspace" "example" {
  name                = "log-billing-complete-prod-eus-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    Environment = "Production"
    Project     = "BillingComplete"
    CostCenter  = "Engineering"
  }
}

# Example Application Insights with workspace integration
resource "azurerm_application_insights" "example" {
  name                = "appi-billing-complete-prod-eus-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  workspace_id        = azurerm_log_analytics_workspace.example.id
  application_type    = "web"

  tags = {
    Environment = "Production"
    Project     = "BillingComplete"
    CostCenter  = "Engineering"
  }
}

# Example additional resources to generate costs
resource "azurerm_storage_account" "example" {
  name                     = "stbillingcompleteprod001"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    Environment  = "Production"
    Project      = "BillingComplete"
    CostCenter   = "Engineering"
    ResourceType = "Storage"
  }
}

resource "azurerm_service_plan" "example" {
  name                = "asp-billing-complete-prod-eus-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  os_type             = "Linux"
  sku_name            = "B1"

  tags = {
    Environment  = "Production"
    Project      = "BillingComplete"
    CostCenter   = "Engineering"
    ResourceType = "Compute"
  }
}

# Complete Application Insights Billing module usage with all features
module "app_insights_billing" {
  source = "../../"

  # Required variables
  resource_group_name       = azurerm_resource_group.example.name
  location                  = azurerm_resource_group.example.location
  application_insights_name = azurerm_application_insights.example.name

  # Log Analytics integration for advanced features
  log_analytics_workspace_name = azurerm_log_analytics_workspace.example.name

  # Production budget configuration
  monthly_budget_amount   = 2000  # $2000/month for production
  quarterly_budget_amount = 6000  # $6000/quarter
  annual_budget_amount    = 24000 # $24000/year

  # Comprehensive alert thresholds
  budget_alert_thresholds    = [75, 85, 95, 100, 110] # Multiple alert levels
  budget_forecast_thresholds = [100, 110, 125]        # Forecast alerts

  # Multiple notification recipients
  budget_notification_emails = [
    "finance@company.com",
    "engineering-leads@company.com",
    "platform-team@company.com",
    "cost-management@company.com"
  ]

  # Advanced cost alert configuration
  enable_cost_alerts        = true
  daily_spend_threshold     = 100 # Alert if daily spend > $100
  daily_cost_alert_severity = 1   # Error severity

  # Anomaly detection configuration
  enable_anomaly_detection = true
  cost_anomaly_sensitivity = 2.0 # 2 standard deviations
  anomaly_alert_severity   = 2   # Warning severity

  # Cost filtering - monitor specific resource types
  cost_filter_resource_types = [
    "Microsoft.Web/sites",
    "Microsoft.Web/serverfarms",
    "Microsoft.Insights/components",
    "Microsoft.Storage/storageAccounts",
    "Microsoft.OperationalInsights/workspaces"
  ]

  # Cost filtering by tags - only production resources
  cost_filter_tags = {
    Environment = ["Production"]
    Project     = ["BillingComplete"]
    CostCenter  = ["Engineering"]
  }

  # Dashboard configuration
  enable_billing_dashboard = true
  dashboard_display_name   = "Production Cost Management Dashboard"
  dashboard_time_range     = 90 # 90 days of historical data

  # Enable all forecast features
  enable_forecast_alerts = true

  # Custom budget end date (2 years from now)
  budget_end_date = formatdate("YYYY-MM-01'T'00:00:00'Z'", timeadd(timestamp(), "17520h"))

  # Naming convention
  workload    = "billing-complete"
  environment = "prod"

  tags = {
    Environment = "Production"
    Project     = "BillingComplete"
    CostCenter  = "Engineering"
    Owner       = "Platform Team"
    Criticality = "High"
    Monitoring  = "Enabled"
  }

  depends_on = [
    azurerm_log_analytics_workspace.example,
    azurerm_application_insights.example
  ]
}

# Example Action Group for advanced notifications (optional)
resource "azurerm_monitor_action_group" "billing_alerts" {
  name                = "ag-billing-alerts-prod"
  resource_group_name = azurerm_resource_group.example.name
  short_name          = "billing"

  email_receiver {
    name          = "finance-team"
    email_address = "finance@company.com"
  }

  email_receiver {
    name          = "platform-team"
    email_address = "platform-team@company.com"
  }

  webhook_receiver {
    name        = "slack-webhook"
    service_uri = "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"
  }

  tags = {
    Environment = "Production"
    Project     = "BillingComplete"
  }
}
