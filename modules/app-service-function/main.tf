# Azure App Service Plan for Functions Module
# This module creates an Azure App Service Plan specifically designed for Function Apps

# App Service Plan for Functions
resource "azurerm_service_plan" "functions" {
  name                = "asp-${var.workload}-functions-${var.environment}-001"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = var.os_type
  sku_name            = var.sku_name

  # Elastic Premium specific configurations
  maximum_elastic_worker_count = var.maximum_elastic_worker_count

  tags = var.tags
}
