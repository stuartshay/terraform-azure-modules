# Complete Enhanced Storage Account Example
# This example demonstrates all the new storage account features:
# - Per-service diagnostic settings with retention
# - Blob versioning and data protection
# - Container immutability policies
# - SAS token generation with Key Vault storage

terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.40"
    }
  }
}

# Configure the Azure Provider
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

# Get current client configuration
data "azurerm_client_config" "current" {}

# Create a resource group for this example
resource "azurerm_resource_group" "example" {
  name     = "rg-storage-enhanced-example"
  location = "East US"

  tags = {
    Environment = "dev"
    Project     = "storage-enhanced-example"
    Example     = "complete-enhanced"
  }
}

# Create Log Analytics Workspace for diagnostic logs
resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-storage-enhanced-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = azurerm_resource_group.example.tags
}

# Create Key Vault for SAS token storage
resource "azurerm_key_vault" "example" {
  name                = "kv-storage-example-001"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Recover",
      "Backup",
      "Restore",
      "Purge"
    ]
  }

  tags = azurerm_resource_group.example.tags
}

# Enhanced storage account module usage with all new features
module "storage_account_enhanced" {
  source = "../../"

  # Required variables
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  environment         = "dev"
  workload            = "enhanced"
  location_short      = "eastus"

  # Basic configuration
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  access_tier              = "Hot"

  # Enhanced Diagnostics Configuration
  enable_diagnostics              = true
  log_analytics_workspace_id      = azurerm_log_analytics_workspace.example.id
  diagnostics_retention_days      = 30

  # Blob Properties with Enhanced Data Protection
  enable_blob_properties          = true
  enable_blob_versioning          = true  # Now defaults to true
  enable_change_feed              = true  # Now defaults to true
  change_feed_retention_days      = 30
  blob_delete_retention_days      = 14    # Updated default
  container_delete_retention_days = 7

  # Container Immutability for Compliance
  enable_container_immutability = true
  container_immutability_days   = 30
  immutable_containers          = ["audit", "compliance"]

  # SAS Token and Key Vault Integration
  enable_sas_secret      = true
  key_vault_id           = azurerm_key_vault.example.id
  key_vault_secret_name  = "storage-sas-token"
  sas_services           = "bqtf"  # blob, queue, table, file
  sas_resource_types     = "sco"   # service, container, object
  sas_permissions        = "rwdl"  # read, write, delete, list
  sas_ttl_hours          = 24
  sas_https_only         = true

  # Security configurations
  enable_https_traffic_only = true
  min_tls_version          = "TLS1_2"
  public_network_access_enabled = false

  # Create multiple blob containers including immutable ones
  blob_containers = {
    documents = {
      metadata = {
        purpose = "document-storage"
        tier    = "hot"
      }
    }
    audit = {
      metadata = {
        purpose = "audit-logs"
        retention = "30-days"
      }
    }
    compliance = {
      metadata = {
        purpose = "compliance-data"
        retention = "30-days"
      }
    }
    backups = {
      metadata = {
        purpose = "backup-storage"
        tier = "cool"
      }
    }
  }

  # File shares for shared storage
  file_shares = {
    shared = {
      quota_gb         = 100
      enabled_protocol = "SMB"
      access_tier      = "Hot"
      metadata = {
        purpose = "shared-files"
      }
      acl = []
    }
  }

  # Create queues for messaging
  queues = ["notifications", "processing"]

  # Create tables for NoSQL storage
  tables = ["logs", "metrics"]

  tags = azurerm_resource_group.example.tags
}