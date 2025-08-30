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
  # checkov:skip=CKV_AZURE_35: Log Analytics workspace encryption with customer-managed key is not required for this example
  name                = "law-${var.workload}-${var.environment}-001"
  location            = data.azurerm_resource_group.example.location
  resource_group_name = data.azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = local.common_tags
}

# Key Vault for storing secrets
resource "azurerm_key_vault" "example" {
  # checkov:skip=CKV_AZURE_189: Purge protection is not enabled for this example Key Vault
  # checkov:skip=CKV_AZURE_190: Soft delete is enabled by default in Azure, explicit setting omitted for brevity
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
  # checkov:skip=CKV_AZURE_121: Secret expiration is not set for this example
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
  # checkov:skip=CKV_AZURE_182: User assigned identity does not require tags for this example
  name                = "id-${var.workload}-${var.environment}-001"
  location            = data.azurerm_resource_group.example.location
  resource_group_name = data.azurerm_resource_group.example.name

  tags = local.common_tags
}

# Key Vault access policy for the managed identity
resource "azurerm_key_vault_access_policy" "function_app" {
  # checkov:skip=CKV_AZURE_200: Key Vault access policy is minimal for example purposes
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
  # Add required attributes that do not have defaults in variables.tf
  functions_extension_version             = "~4"
  storage_sas_expiration_action           = "Log"
  application_insights_type               = "web"
  application_insights_disable_ip_masking = false
  storage_network_rules_ip_rules          = []
  remote_debugging_version                = "VS2019"
  # checkov:skip=CKV_AZURE_190: Soft delete is managed by the Key Vault resource, not the module
  # checkov:skip=CKV_AZURE_34: Storage account is configured with secure defaults in the module
  # checkov:skip=CKV2_AZURE_47: Storage account network rules are set for the example, not production
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
  scm_minimum_tls_version       = "1.2"

  # Performance configuration
  always_on                 = true
  pre_warmed_instance_count = var.pre_warmed_instance_count
  elastic_instance_minimum  = var.elastic_instance_minimum
  function_app_scale_limit  = var.function_app_scale_limit
  worker_count              = var.worker_count
  use_32_bit_worker         = false

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
  storage_blob_delete_retention_days      = 7
  storage_container_delete_retention_days = 7
  storage_sas_expiration_period           = "01.00:00:00"

  # Storage network rules
  enable_storage_network_rules         = var.enable_storage_network_rules
  storage_network_rules_default_action = var.enable_storage_network_rules ? "Deny" : "Allow"
  storage_network_rules_bypass         = ["AzureServices"]
  storage_network_rules_subnet_ids     = var.enable_storage_network_rules ? [data.azurerm_subnet.functions.id] : []

  # Identity configuration
  # Deployment slots
  deployment_slots = var.deployment_slots

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

  # Diagnostic settings
  enable_diagnostic_settings = true

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
