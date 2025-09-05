# Basic Function App Example
# This example demonstrates the minimal configuration required to deploy a Function App

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

# Data source for existing resource group
data "azurerm_resource_group" "example" {
  name = var.resource_group_name
}

# App Service Plan for Functions
module "app_service_plan" {
  source  = "app.terraform.io/azure-policy-cloud/app-service-plan-function/azurerm"
  version = "1.1.34"

  workload            = var.workload
  environment         = var.environment
  resource_group_name = data.azurerm_resource_group.example.name
  location            = data.azurerm_resource_group.example.location
  sku_name            = "EP1"

  tags = local.common_tags
}

# Function App
module "function_app" {
  websockets_enabled         = false
  enable_cors                = false
  cors_allowed_origins       = []
  cors_support_credentials   = false
  enable_vnet_integration    = false
  vnet_integration_subnet_id = null
  scm_minimum_tls_version    = "1.2"
  enable_diagnostic_settings = false
  source                     = "../../"

  # Required variables
  workload            = var.workload
  environment         = var.environment
  resource_group_name = data.azurerm_resource_group.example.name
  location            = data.azurerm_resource_group.example.location
  service_plan_id     = module.app_service_plan.app_service_plan_id

  # Runtime configuration
  runtime_name                = "python"
  runtime_version             = "3.11"
  os_type                     = "Linux"
  functions_extension_version = "~4"
  use_dotnet_isolated_runtime = false

  # Storage account configuration
  storage_account_tier                    = "Standard"
  storage_account_replication_type        = "LRS"
  storage_min_tls_version                 = "TLS1_2"
  storage_blob_delete_retention_days      = 7
  storage_container_delete_retention_days = 7
  storage_sas_expiration_period           = "01.00:00:00"
  storage_sas_expiration_action           = "Log"
  enable_storage_network_rules            = false
  storage_network_rules_default_action    = "Allow"
  storage_network_rules_bypass            = ["AzureServices"]
  storage_network_rules_ip_rules          = []
  storage_network_rules_subnet_ids        = []

  # Application Insights
  enable_application_insights                     = false
  application_insights_type                       = "web"
  application_insights_retention_days             = 90
  application_insights_sampling_percentage        = 100
  application_insights_disable_ip_masking         = false
  application_insights_local_auth_disabled        = true
  application_insights_internet_ingestion_enabled = true
  application_insights_internet_query_enabled     = true
  log_analytics_workspace_id                      = null

  # Security and networking
  https_only                    = true
  public_network_access_enabled = true
  client_certificate_enabled    = false
  client_certificate_mode       = "Optional"
  use_32_bit_worker             = false
  always_on                     = true
  pre_warmed_instance_count     = 1
  elastic_instance_minimum      = 1
  function_app_scale_limit      = 10
  worker_count                  = 1
  remote_debugging_enabled      = false
  remote_debugging_version      = "VS2019"
  deployment_slots              = {}

  # Basic app settings
  app_settings = {
    "ENVIRONMENT" = var.environment
  }

  tags = local.common_tags
}

# Local values
locals {
  common_tags = {
    Environment = var.environment
    Project     = "function-app-example"
    ManagedBy   = "terraform"
    Example     = "basic"
  }
}
