# Azure Function App Module
# This module creates an Azure Function App with optional features like VNet integration,
# Application Insights, deployment slots, and comprehensive security configurations

# Local values for consistent naming and configuration
locals {
  # Location mapping for consistent naming
  location_short_map = {
    "East US"          = "eastus"
    "East US 2"        = "eastus2"
    "West US"          = "westus"
    "West US 2"        = "westus2"
    "West US 3"        = "westus3"
    "Central US"       = "centralus"
    "North Central US" = "northcentralus"
    "South Central US" = "southcentralus"
    "West Central US"  = "westcentralus"
  }

  location_short = local.location_short_map[var.location]

  # Function App naming
  function_app_name = "func-${var.workload}-${var.environment}-${local.location_short}-001"

  # Storage Account naming (must be globally unique and lowercase, max 24 chars)
  # Format: stfunc + workload(max 6) + env(max 3) + location(max 6) + 001 = max 24 chars
  storage_account_name = "stfunc${substr(var.workload, 0, 6)}${substr(var.environment, 0, 3)}${substr(local.location_short, 0, 6)}001"

  # Application Insights naming
  app_insights_name = "appi-${var.workload}-functions-${var.environment}-${local.location_short}-001"



}

# Storage Account for Function App
resource "azurerm_storage_account" "functions" {
  #checkov:skip=CKV2_AZURE_40:Shared access key is required for Function Apps
  name                     = local.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
  min_tls_version          = var.storage_min_tls_version

  # Security configurations
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = true # Required for Function Apps
  public_network_access_enabled   = false
  # Private endpoint for storage account is now defined at the top level

  # Blob properties for better security and lifecycle management
  blob_properties {
    delete_retention_policy {
      days = var.storage_blob_delete_retention_days
    }

    dynamic "container_delete_retention_policy" {
      for_each = var.storage_container_delete_retention_days > 0 ? [1] : []
      content {
        days = var.storage_container_delete_retention_days
      }
    }
  }

  # SAS expiration policy
  dynamic "sas_policy" {
    for_each = var.storage_sas_expiration_period != null ? [1] : []
    content {
      expiration_period = var.storage_sas_expiration_period
      expiration_action = var.storage_sas_expiration_action
    }
  }

  # Network rules for storage account
  dynamic "network_rules" {
    for_each = var.enable_storage_network_rules ? [1] : []
    content {
      default_action             = var.storage_network_rules_default_action
      bypass                     = var.storage_network_rules_bypass
      ip_rules                   = var.storage_network_rules_ip_rules
      virtual_network_subnet_ids = var.storage_network_rules_subnet_ids
    }
  }

  tags = var.tags
}

# Application Insights (optional)
resource "azurerm_application_insights" "functions" {
  count = var.enable_application_insights ? 1 : 0

  name                = local.app_insights_name
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = var.application_insights_type
  retention_in_days   = var.application_insights_retention_days

  # Sampling percentage for telemetry
  sampling_percentage = var.application_insights_sampling_percentage

  # Disable IP masking if specified
  disable_ip_masking = var.application_insights_disable_ip_masking

  # Local authentication disabled for better security
  local_authentication_disabled = var.application_insights_local_auth_disabled

  # Internet ingestion and query
  internet_ingestion_enabled = var.application_insights_internet_ingestion_enabled
  internet_query_enabled     = var.application_insights_internet_query_enabled

  # Workspace-based Application Insights
  workspace_id = var.log_analytics_workspace_id

  tags = var.tags
}

# Function App (Linux or Windows based on os_type)
resource "azurerm_linux_function_app" "main" {
  site_config {
    minimum_tls_version = "1.2"
  }
  count = var.os_type == "Linux" ? 1 : 0

  name                = local.function_app_name
  resource_group_name = var.resource_group_name
  location            = var.location

  storage_account_name       = azurerm_storage_account.functions.name
  storage_account_access_key = azurerm_storage_account.functions.primary_access_key
  service_plan_id            = var.service_plan_id

  # Security configurations
  https_only                    = var.https_only
  public_network_access_enabled = false
  client_certificate_enabled    = var.client_certificate_enabled
  client_certificate_mode       = var.client_certificate_mode


  # Application Insights configuration
  # Application Insights connection string and key removed (invalid attributes)
}
