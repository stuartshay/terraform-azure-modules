# Complete Function App Example
# This example demonstrates all features and configuration options of the Function App module

terraform {
  required_version = ">= 1.6"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.40"
    }
  }
}

provider "azurerm" {
  features {}
}

# Data sources for existing resources
data "azurerm_resource_group" "example" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "example" {
  name                = var.virtual_network_name
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "functions" {
  name                 = var.subnet_name
  virtual_network_name = data.azurerm_virtual_network.example.name
  resource_group_name  = var.resource_group_name
}

# Log Analytics Workspace for Application Insights
resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-${var.workload}-${var.environment}-001"
  location            = data.azurerm_resource_group.example.location
  resource_group_name = data.azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = local.common_tags
}

# Key Vault for storing secrets
resource "azurerm_key_vault" "example" {
  name                = "kv-${var.workload}-${var.environment}-001"
  location            = data.azurerm_resource_group.example.location
  resource_group_name = data.azurerm_resource_group.example.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  # Enable for template deployment
  enabled_for_template_deployment = true

  # Network access
  public_network_access_enabled = false
  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    virtual_network_subnet_ids = [
      data.azurerm_subnet.functions.id
    ]
  }

  tags = local.common_tags
}

# Key Vault secret for database connection
resource "azurerm_key_vault_secret" "database_connection" {
  name         = "database-connection-string"
  value        = var.database_connection_string
  key_vault_id = azurerm_key_vault.example.id

  tags = local.common_tags
}

# App Service Plan for Functions
module "app_service_plan" {
  source  = "app.terraform.io/azure-policy-cloud/app-service-plan-function/azurerm"
  version = "1.1.34"

  workload                     = var.workload
  environment                  = var.environment
  resource_group_name          = data.azurerm_resource_group.example.name
  location                     = data.azurerm_resource_group.example.location
  sku_name                     = var.app_service_plan_sku
  maximum_elastic_worker_count = var.maximum_elastic_worker_count

  tags = local.common_tags
}

# User Assigned Managed Identity
resource "azurerm_user_assigned_identity" "example" {
  name                = "id-${var.workload}-${var.environment}-001"
  location            = data.azurerm_resource_group.example.location
  resource_group_name = data.azurerm_resource_group.example.name

  tags = local.common_tags
}

# Key Vault access policy for the managed identity
resource "azurerm_key_vault_access_policy" "function_app" {
  key_vault_id = azurerm_key_vault.example.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.example.principal_id

  secret_permissions = [
    "Get",
    "List"
  ]
}

# Function App with all features
module "function_app" {
  source = "../../"

  # Required variables
  workload            = var.workload
  environment         = var.environment
  resource_group_name = data.azurerm_resource_group.example.name
  location            = data.azurerm_resource_group.example.location
  service_plan_id     = module.app_service_plan.app_service_plan_id

  # Runtime configuration
  os_type                     = var.os_type
  runtime_name                = var.runtime_name
  runtime_version             = var.runtime_version
  use_dotnet_isolated_runtime = var.use_dotnet_isolated_runtime

  # Security configuration
  https_only                    = true
  public_network_access_enabled = var.public_network_access_enabled
  client_certificate_enabled    = var.client_certificate_enabled
  client_certificate_mode       = var.client_certificate_mode
  minimum_tls_version           = "1.2"
  scm_minimum_tls_version       = "1.2"
  ftps_state                    = "Disabled"

  # Performance configuration
  always_on                 = true
  pre_warmed_instance_count = var.pre_warmed_instance_count
  elastic_instance_minimum  = var.elastic_instance_minimum
  function_app_scale_limit  = var.function_app_scale_limit
  worker_count              = var.worker_count
  use_32_bit_worker         = false

  # Health check
  health_check_path                 = var.health_check_path
  health_check_eviction_time_in_min = 5

  # VNet integration
  enable_vnet_integration    = var.enable_vnet_integration
  vnet_integration_subnet_id = var.enable_vnet_integration ? data.azurerm_subnet.functions.id : null

  # Network features
  websockets_enabled       = var.websockets_enabled
  remote_debugging_enabled = false

  # CORS configuration
  enable_cors              = var.enable_cors
  cors_allowed_origins     = var.cors_allowed_origins
  cors_support_credentials = var.cors_support_credentials

  # IP restrictions
  ip_restrictions = var.ip_restrictions

  # SCM IP restrictions
  scm_ip_restrictions = var.scm_ip_restrictions

  # Application Insights
  enable_application_insights                     = true
  log_analytics_workspace_id                      = azurerm_log_analytics_workspace.example.id
  application_insights_retention_days             = 90
  application_insights_sampling_percentage        = 100
  application_insights_local_auth_disabled        = true
  application_insights_internet_ingestion_enabled = true
  application_insights_internet_query_enabled     = true

  # Storage account configuration
  storage_account_tier                    = "Standard"
  storage_account_replication_type        = "LRS"
  storage_min_tls_version                 = "TLS1_2"
  storage_public_network_access_enabled   = var.storage_public_network_access_enabled
  storage_blob_delete_retention_days      = 7
  storage_container_delete_retention_days = 7
  storage_sas_expiration_period           = "01.00:00:00"

  # Storage network rules
  enable_storage_network_rules         = var.enable_storage_network_rules
  storage_network_rules_default_action = var.enable_storage_network_rules ? "Deny" : "Allow"
  storage_network_rules_bypass         = ["AzureServices"]
  storage_network_rules_subnet_ids     = var.enable_storage_network_rules ? [data.azurerm_subnet.functions.id] : []

  # Identity configuration
  identity_type = "SystemAssigned, UserAssigned"
  identity_ids  = [azurerm_user_assigned_identity.example.id]

  # Key Vault reference identity
  key_vault_reference_identity_id = azurerm_user_assigned_identity.example.id

  # Deployment slots
  deployment_slots = var.deployment_slots

  # Sticky settings for deployment slots
  sticky_app_setting_names = [
    "ENVIRONMENT",
    "SLOT_NAME",
    "DATABASE_CONNECTION_STRING"
  ]

  # App settings with Key Vault references
  app_settings = merge(
    var.app_settings,
    {
      "ENVIRONMENT"                = var.environment
      "WORKLOAD"                   = var.workload
      "DATABASE_CONNECTION_STRING" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.database_connection.id})"
      "ENABLE_MONITORING"          = "true"
      "LOG_LEVEL"                  = var.environment == "prod" ? "INFO" : "DEBUG"
    }
  )

  # Connection strings
  connection_strings = var.connection_strings

  # Authentication settings
  enable_auth_settings                        = var.enable_auth_settings
  auth_settings_default_provider              = var.auth_settings_default_provider
  auth_settings_unauthenticated_client_action = var.auth_settings_unauthenticated_client_action
  auth_settings_token_store_enabled           = var.auth_settings_token_store_enabled
  auth_settings_active_directory              = var.auth_settings_active_directory

  # Backup configuration
  enable_backup                            = var.enable_backup
  backup_name                              = "backup-${var.workload}-${var.environment}"
  backup_storage_account_url               = var.backup_storage_account_url
  backup_schedule_frequency_interval       = 1
  backup_schedule_frequency_unit           = "Day"
  backup_schedule_keep_at_least_one_backup = true
  backup_schedule_retention_period_days    = 30

  # Diagnostic settings
  enable_diagnostic_settings = true
  diagnostic_metrics         = ["AllMetrics"]

  tags = local.common_tags

  depends_on = [
    azurerm_key_vault_access_policy.function_app
  ]
}

# Data source for current client configuration
data "azurerm_client_config" "current" {}

# Local values
locals {
  common_tags = {
    Environment = var.environment
    Project     = "function-app-complete-example"
    ManagedBy   = "terraform"
    Example     = "complete"
    CostCenter  = var.cost_center
    Owner       = var.owner
  }
}
