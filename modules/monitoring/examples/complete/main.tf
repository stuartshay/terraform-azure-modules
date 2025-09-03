# Complete Monitoring Example
# This example demonstrates a full-featured monitoring setup with all options enabled

terraform {
  required_version = ">= 1.12.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.42"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create a resource group for this example
resource "azurerm_resource_group" "example" {
  name     = "rg-monitoring-complete-example"
  location = "East US"

  tags = local.common_tags
}

# Create a VNet and subnet for private endpoints
resource "azurerm_virtual_network" "example" {
  name                = "vnet-monitoring-example"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  tags = local.common_tags
}

resource "azurerm_subnet" "private_endpoints" {
  name                 = "snet-privateendpoints"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
  # NSG association is handled by a separate resource below
}

# Add a Network Security Group for the subnet
resource "azurerm_network_security_group" "example" {
  name                = "nsg-monitoring-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  security_rule {
    name                       = "AllowAzureMonitor"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureMonitor"
    destination_address_prefix = "*"
  }
}

# Associate NSG with subnet
resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.private_endpoints.id
  network_security_group_id = azurerm_network_security_group.example.id
}

# Example Function Apps to monitor
resource "azurerm_service_plan" "example" {
  name                = "asp-monitoring-example"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  os_type             = "Linux"
  sku_name            = "Y1"
  tags                = local.common_tags
}

resource "azurerm_storage_account" "example" {
  name                            = "stmonitoringexample001"
  resource_group_name             = azurerm_resource_group.example.name
  location                        = azurerm_resource_group.example.location
  account_tier                    = "Standard"
  account_replication_type        = "GRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false
  public_network_access_enabled   = false
  is_hns_enabled                  = true

  blob_properties {
    delete_retention_policy {
      days = 7
    }
    versioning_enabled  = true
    change_feed_enabled = true
    container_delete_retention_policy {
      days = 7
    }
  }

  sas_policy {
    expiration_period = "01.00:00:00" # 1 day
    expiration_action = "Log"
  }

  # Customer Managed Key (CMK) encryption (requires a key vault, user must fill in details)
  # customer_managed_key {
  #   key_vault_key_id = "<your-key-vault-key-id>"
  #   user_assigned_identity_id = "<your-identity-id>"
  # }

  tags = local.common_tags
}

# Private endpoint for storage account
resource "azurerm_private_endpoint" "storage" {
  name                = "pe-storage-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "psc-storage-example"
    private_connection_resource_id = azurerm_storage_account.example.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
}

resource "azurerm_linux_function_app" "example_basic" {
  name                = "func-example-basic-${local.environment}-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key
  service_plan_id            = azurerm_service_plan.example.id

  https_only                    = true
  public_network_access_enabled = false

  site_config {
    always_on  = true
    ftps_state = "Disabled"
  }

  tags = local.common_tags
}

resource "azurerm_linux_function_app" "example_advanced" {
  name                = "func-example-advanced-${local.environment}-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key = azurerm_storage_account.example.primary_access_key
  service_plan_id            = azurerm_service_plan.example.id

  https_only                    = true
  public_network_access_enabled = false

  site_config {
    always_on  = true
    ftps_state = "Disabled"
  }

  tags = local.common_tags
}

# Local values for consistent configuration
locals {
  workload       = "example"
  environment    = "prod"
  location_short = "eastus"

  common_tags = {
    Environment = local.environment
    Project     = "monitoring-example"
    Owner       = "platform-team"
    CostCenter  = "engineering"
    Example     = "complete"
  }
}

# Complete monitoring module configuration with all features enabled
module "monitoring" {
  source = "../../"

  # Required variables
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  workload            = local.workload
  environment         = local.environment
  location_short      = local.location_short
  subscription_id     = data.azurerm_client_config.current.subscription_id

  # Function Apps to monitor
  monitored_function_apps = {
    basic = {
      resource_id = azurerm_linux_function_app.example_basic.id
      name        = azurerm_linux_function_app.example_basic.name
    }
    advanced = {
      resource_id = azurerm_linux_function_app.example_advanced.id
      name        = azurerm_linux_function_app.example_advanced.name
    }
  }

  # Cost optimization settings
  log_retention_days      = 90
  daily_quota_gb          = 5
  reservation_capacity_gb = 100
  sampling_percentage     = 75

  # Enhanced notification configuration
  notification_emails = {
    admin    = "admin@example.com"
    oncall   = "oncall@example.com"
    platform = "platform@example.com"
  }

  notification_sms = {
    oncall = {
      country_code = "1"
      phone_number = "5551234567"
    }
  }

  notification_webhooks = {
    slack = "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"
  }

  # Stricter alert thresholds for production
  cpu_threshold           = 70
  memory_threshold        = 80
  error_threshold         = 5
  response_time_threshold = 3
  exception_threshold     = 3
  availability_threshold  = 99
  performance_threshold   = 3000

  # Enable all features
  enable_storage_monitoring    = true
  enable_vm_insights           = true
  enable_workspace_diagnostics = true
  enable_private_endpoints     = true
  enable_security_center       = true
  enable_update_management     = true
  enable_workbook              = true
  enable_log_alerts            = true
  enable_activity_log_alerts   = true
  enable_budget_alerts         = true
  enable_smart_detection       = true
  enable_availability_tests    = true

  # Private endpoint configuration
  private_endpoint_subnet_id = azurerm_subnet.private_endpoints.id
  private_dns_zone_ids       = [] # Add your private DNS zone IDs here

  # Budget configuration
  budget_amount = 200
  budget_notification_emails = [
    "finance@example.com",
    "admin@example.com"
  ]

  # Smart detection configuration
  smart_detection_emails = [
    "devops@example.com",
    "platform@example.com"
  ]

  tags = local.common_tags
}

# Data source to get current Azure configuration
data "azurerm_client_config" "current" {}
