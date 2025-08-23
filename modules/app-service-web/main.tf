# Azure App Service Module
# This module creates an Azure App Service with associated resources

# App Service Plan
resource "azurerm_service_plan" "main" {
  name                = "asp-${var.workload}-${var.environment}-001"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.sku_name

  tags = var.tags
}

# App Service
resource "azurerm_linux_web_app" "main" {
  name                = "app-${var.workload}-${var.environment}-001"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.main.id

  # Security settings
  https_only = true # Force HTTPS

  site_config {
    always_on     = true       # Always on for better performance
    http2_enabled = true       # Enable HTTP/2 for latest version
    ftps_state    = "Disabled" # Disable FTP

    application_stack {
      python_version = var.python_version
    }
  }

  app_settings = var.app_settings

  tags = var.tags
}

# VNET Integration
resource "azurerm_app_service_virtual_network_swift_connection" "main" {
  app_service_id = azurerm_linux_web_app.main.id
  subnet_id      = var.subnet_id
}
