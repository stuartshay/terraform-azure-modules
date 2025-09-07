# Basic Application Insights Function Example
# This example demonstrates basic usage of the Application Insights Function module

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
  name     = "rg-function-monitoring-dev-eus-001"
  location = "East US"

  tags = {
    Environment = "Development"
    Project     = "FunctionMonitoring"
    Purpose     = "Testing"
  }
}

# Example Application Insights (in real usage, this would likely already exist)
resource "azurerm_application_insights" "example" {
  name                = "appi-function-monitoring-dev-eus-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  application_type    = "web"

  tags = {
    Environment = "Development"
    Project     = "FunctionMonitoring"
  }
}

# Example App Service Plan for Functions
resource "azurerm_service_plan" "example" {
  name                = "asp-function-monitoring-dev-eus-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  os_type             = "Linux"
  sku_name            = "Y1" # Consumption plan

  tags = {
    Environment = "Development"
    Project     = "FunctionMonitoring"
  }
}

# Example Storage Account for Function App
resource "azurerm_storage_account" "example" {
  name                     = "stfuncmonitoringdev001"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    Environment = "Development"
    Project     = "FunctionMonitoring"
  }
}

# Example Function App
resource "azurerm_linux_function_app" "example" {
  name                = "func-monitoring-example-dev-eus-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key
  service_plan_id            = azurerm_service_plan.example.id

  site_config {
    minimum_tls_version = "1.2"
  }

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.example.instrumentation_key
    "FUNCTIONS_WORKER_RUNTIME"       = "python"
  }

  tags = {
    Environment = "Development"
    Project     = "FunctionMonitoring"
  }
}

# Basic Application Insights Function module usage
module "app_insights_function" {
  source = "../../"

  # Required variables
  resource_group_name       = azurerm_resource_group.example.name
  location                  = azurerm_resource_group.example.location
  application_insights_name = azurerm_application_insights.example.name

  # Specify Function Apps to monitor
  function_app_names = [azurerm_linux_function_app.example.name]

  # Specify App Service Plans to monitor
  app_service_plan_names = [azurerm_service_plan.example.name]

  # Basic configuration for development environment
  function_duration_threshold_ms  = 60000 # 60 seconds (relaxed for dev)
  function_failure_rate_threshold = 10    # 10% (relaxed for dev)
  cpu_threshold_percent           = 90    # 90% (relaxed for dev)
  memory_threshold_percent        = 90    # 90% (relaxed for dev)

  # Disable advanced features for basic example
  enable_cold_start_detection = false
  enable_exception_detection  = false

  # Basic dashboard configuration
  dashboard_time_range = 3 # 3 days for development

  # Optional naming
  workload    = "function-monitoring"
  environment = "dev"

  tags = {
    Environment = "Development"
    Project     = "FunctionMonitoring"
    Purpose     = "Testing"
  }
}
