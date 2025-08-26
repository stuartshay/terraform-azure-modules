# Complete App Service Plan for Functions Example
# This example demonstrates all available configuration options for the app-service-plan-function module

terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.40"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create a resource group for this example
resource "azurerm_resource_group" "example" {
  name     = "rg-app-service-plan-function-complete-example"
  location = "East US"

  tags = local.common_tags
}

# Local values for consistent configuration
locals {
  workload    = "funcapp"
  environment = "prod"

  common_tags = {
    Environment = local.environment
    Project     = "app-service-plan-function-complete-example"
    Owner       = "platform-team"
    Example     = "complete"
    CostCenter  = "engineering"
  }
}

# Create a virtual network for the example
resource "azurerm_virtual_network" "example" {
  name                = "vnet-${local.workload}-${local.environment}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  tags = local.common_tags
}

# Create a subnet for Function App integration
resource "azurerm_subnet" "functions" {
  name                 = "subnet-functions"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  # Delegate subnet to App Service
  delegation {
    name = "function-delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# Complete App Service Plan for Functions configuration
module "function_app_service_plan" {
  source = "../../"

  # Required variables
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  workload            = local.workload
  environment         = local.environment
  subnet_id           = azurerm_subnet.functions.id

  # Use EP2 SKU with Windows OS for this example
  sku_name = "EP2"
  os_type  = "Windows"

  # Custom scaling configuration
  maximum_elastic_worker_count = 10 # Scale up to 10 instances

  # Comprehensive tagging
  tags = merge(local.common_tags, {
    Tier       = "Premium"
    Backup     = "Required"
    Monitoring = "Enhanced"
    Compliance = "SOC2"
    OS         = "Windows"
    SKU        = "EP2"
  })
}

# Example: Create storage account for Function Apps that will use this plan
resource "azurerm_storage_account" "functions" {
  name                     = "stfuncapp${local.environment}001"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Security configurations
  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  tags = local.common_tags
}

# Example: Create Application Insights for Function Apps that will use this plan
resource "azurerm_application_insights" "functions" {
  name                = "appi-${local.workload}-functions-${local.environment}-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  application_type    = "web"

  tags = local.common_tags
}

# Function App creation is intentionally decoupled from this module example.
# To deploy a Function App, reference the created plan via
# module.function_app_service_plan.app_service_plan_id in your own configuration.
