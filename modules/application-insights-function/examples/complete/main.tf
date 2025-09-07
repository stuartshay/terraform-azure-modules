# Complete example for Application Insights Function module
# This example demonstrates all features including advanced monitoring and dashboards

terraform {
  required_version = ">= 1.13.1"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.42.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

provider "azurerm" {
  features {}
}

# Random suffix for unique resource names
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Resource Group
resource "azurerm_resource_group" "example" {
  name     = "rg-function-monitoring-${random_string.suffix.result}"
  location = var.location
  tags     = var.tags
}

# Log Analytics Workspace for advanced monitoring
resource "azurerm_log_analytics_workspace" "example" {
  name                = "log-function-${random_string.suffix.result}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

# Application Insights
resource "azurerm_application_insights" "example" {
  name                = "appi-function-${random_string.suffix.result}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  workspace_id        = azurerm_log_analytics_workspace.example.id
  application_type    = "web"
  tags                = var.tags
}

# Storage Account for Function Apps
resource "azurerm_storage_account" "example" {
  name                     = "stfunc${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags
}

# App Service Plan
resource "azurerm_service_plan" "example" {
  name                = "asp-function-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  os_type             = "Linux"
  sku_name            = "Y1"
  tags                = var.tags
}

# Function Apps
resource "azurerm_linux_function_app" "example" {
  count = length(var.function_app_names)

  name                = "${var.function_app_names[count.index]}-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key
  service_plan_id            = azurerm_service_plan.example.id

  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.example.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.example.connection_string
  }

  site_config {
    application_stack {
      node_version = "18"
    }
  }

  tags = var.tags
}

# Application Insights Function Monitoring Module
module "function_monitoring" {
  source = "../../"

  # Basic Configuration
  resource_group_name       = azurerm_resource_group.example.name
  location                  = azurerm_resource_group.example.location
  application_insights_name = azurerm_application_insights.example.name
  workload                  = var.workload
  environment               = var.environment

  # Function Apps and App Service Plans to monitor
  function_app_names     = [for app in azurerm_linux_function_app.example : app.name]
  app_service_plan_names = [azurerm_service_plan.example.name]

  # Enable all monitoring features
  enable_function_alerts    = true
  enable_app_service_alerts = true
  enable_function_dashboard = true

  # Advanced monitoring with Log Analytics
  log_analytics_workspace_name = azurerm_log_analytics_workspace.example.name
  enable_cold_start_detection  = true
  enable_exception_detection   = true

  # Alert thresholds (customized for production workload)
  function_duration_threshold_ms  = var.function_duration_threshold_ms
  function_failure_rate_threshold = var.function_failure_rate_threshold
  cpu_threshold_percent           = var.cpu_threshold_percent
  memory_threshold_percent        = var.memory_threshold_percent

  # Cold start and exception thresholds
  cold_start_threshold     = var.cold_start_threshold
  exception_rate_threshold = var.exception_rate_threshold

  # Alert severities
  function_duration_alert_severity  = var.function_duration_alert_severity
  function_failure_alert_severity   = var.function_failure_alert_severity
  app_service_cpu_alert_severity    = var.app_service_cpu_alert_severity
  app_service_memory_alert_severity = var.app_service_memory_alert_severity
  cold_start_alert_severity         = var.cold_start_alert_severity
  exception_alert_severity          = var.exception_alert_severity

  # Dashboard configuration
  dashboard_display_name = var.dashboard_display_name
  dashboard_time_range   = var.dashboard_time_range

  # Low activity monitoring
  function_min_invocations_threshold = var.function_min_invocations_threshold
  function_activity_alert_severity   = var.function_activity_alert_severity

  tags = var.tags

  depends_on = [
    azurerm_linux_function_app.example,
    azurerm_service_plan.example,
    azurerm_application_insights.example,
    azurerm_log_analytics_workspace.example
  ]
}
