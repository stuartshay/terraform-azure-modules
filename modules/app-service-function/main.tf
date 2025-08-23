# Azure App Service Function Module
# This module creates an Azure Function App with associated resources

# Storage Account for Functions
resource "azurerm_storage_account" "functions" {
  #checkov:skip=CKV2_AZURE_40:Shared access key is required for Function Apps
  name                     = "stfunc${var.workload}${var.environment}001"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  # Security configurations
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = true # Required for Function Apps
  public_network_access_enabled   = true # Required for Function Apps

  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }

  # SAS expiration policy
  sas_policy {
    expiration_period = "01.00:00:00" # 1 day
    expiration_action = "Log"
  }

  tags = var.tags
}

# App Service Plan for Functions
resource "azurerm_service_plan" "functions" {
  name                = "asp-${var.workload}-functions-${var.environment}-001"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.sku_name

  # Elastic Premium specific configurations
  maximum_elastic_worker_count = var.maximum_elastic_worker_count

  tags = var.tags
}

# Function App
resource "azurerm_linux_function_app" "main" {
  name                = "func-${var.workload}-${var.environment}-001"
  resource_group_name = var.resource_group_name
  location            = var.location

  storage_account_name       = azurerm_storage_account.functions.name
  storage_account_access_key = azurerm_storage_account.functions.primary_access_key
  service_plan_id            = azurerm_service_plan.functions.id

  # Security configurations
  https_only                    = true
  public_network_access_enabled = false # Force VNet integration

  site_config {
    application_stack {
      python_version = var.python_version
    }

    # Performance configurations
    always_on                 = true
    pre_warmed_instance_count = var.always_ready_instances
    elastic_instance_minimum  = var.always_ready_instances

    # VNet integration settings
    vnet_route_all_enabled = true

    # Application Insights integration
    application_insights_connection_string = var.enable_application_insights ? azurerm_application_insights.functions[0].connection_string : null
    application_insights_key               = var.enable_application_insights ? azurerm_application_insights.functions[0].instrumentation_key : null
  }

  app_settings = merge(
    var.function_app_settings,
    {
      "FUNCTIONS_WORKER_RUNTIME"           = "python"
      "PYTHON_ISOLATE_WORKER_DEPENDENCIES" = "1"
      "WEBSITE_VNET_ROUTE_ALL"             = "1"
    }
  )

  tags = var.tags
}

# VNet Integration for Function App
resource "azurerm_app_service_virtual_network_swift_connection" "functions" {
  app_service_id = azurerm_linux_function_app.main.id
  subnet_id      = var.subnet_id
}

# Application Insights (optional)
resource "azurerm_application_insights" "functions" {
  count = var.enable_application_insights ? 1 : 0

  name                = "appi-${var.workload}-functions-${var.environment}-001"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"

  tags = var.tags
}
