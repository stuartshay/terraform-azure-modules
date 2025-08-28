# Basic Function App Example
# This example demonstrates the minimal configuration required to deploy a Function App

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
  source = "../../"

  # Required variables
  workload            = var.workload
  environment         = var.environment
  resource_group_name = data.azurerm_resource_group.example.name
  location            = data.azurerm_resource_group.example.location
  service_plan_id     = module.app_service_plan.app_service_plan_id

  # Runtime configuration
  runtime_name    = "python"
  runtime_version = "3.11"

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
