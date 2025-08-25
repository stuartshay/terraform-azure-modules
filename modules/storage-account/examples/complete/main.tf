# Complete Storage Account Example
# This example demonstrates all features of the storage account module

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
  features {}
}

# Create a resource group for this example
resource "azurerm_resource_group" "example" {
  name     = "rg-storage-complete-example"
  location = "East US"

  tags = {
    Environment = "prod"
    Project     = "storage-example"
    Example     = "complete"
    CostCenter  = "IT"
  }
}

# Create a Log Analytics workspace for diagnostic settings
resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-storage-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    Environment = "prod"
    Project     = "storage-example"
    Example     = "complete"
  }
}

# Create a virtual network for private endpoints
resource "azurerm_virtual_network" "example" {
  name                = "vnet-storage-example"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  tags = {
    Environment = "prod"
    Project     = "storage-example"
    Example     = "complete"
  }
}

# Create a subnet for private endpoints
resource "azurerm_subnet" "private_endpoints" {
  name                 = "snet-private-endpoints"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Complete storage account module usage with all features
module "storage_account" {
  source = "../../"

  # Required variables
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  environment         = "prod"
  workload            = "example"
  location_short      = "eastus"

  # Storage account configuration
  account_tier             = "Standard"
  account_replication_type = "GRS"
  account_kind             = "StorageV2"
  access_tier              = "Hot"

  # Security configuration
  enable_https_traffic_only     = true
  min_tls_version               = "TLS1_2"
  shared_access_key_enabled     = true
  allow_blob_public_access      = false
  public_network_access_enabled = false

  # Advanced features
  enable_data_lake_gen2            = true
  enable_large_file_share          = true
  enable_cross_tenant_replication  = false
  enable_infrastructure_encryption = true

  # SAS policy
  sas_expiration_period = "1.00:00:00"
  sas_expiration_action = "Log"

  # Blob properties
  enable_blob_properties           = true
  enable_blob_versioning           = true
  enable_change_feed               = true
  change_feed_retention_days       = 30
  enable_last_access_time_tracking = true
  blob_delete_retention_days       = 30
  container_delete_retention_days  = 30

  # CORS rules for blob service
  cors_rules = [
    {
      allowed_headers    = ["*"]
      allowed_methods    = ["GET", "HEAD", "POST", "PUT"]
      allowed_origins    = ["https://example.com"]
      exposed_headers    = ["*"]
      max_age_in_seconds = 3600
    }
  ]

  # Queue properties
  enable_queue_properties      = true
  enable_queue_logging         = true
  queue_logging_delete         = true
  queue_logging_read           = true
  queue_logging_write          = true
  queue_logging_version        = "1.0"
  queue_logging_retention_days = 7
  enable_queue_minute_metrics  = true
  enable_queue_hour_metrics    = true
  queue_metrics_version        = "1.0"
  queue_metrics_include_apis   = true
  queue_metrics_retention_days = 7

  # Share properties
  enable_share_properties             = true
  share_retention_days                = 30
  enable_smb_settings                 = true
  smb_versions                        = ["SMB3.0", "SMB3.1.1B3.0", "SMB3.1.1"]
  smb_authentication_types            = ["Kerberos"]
  smb_kerberos_ticket_encryption_type = ["AES-256"]
  smb_channel_encryption_type         = ["AES-128-GCM", "AES-256-GCM"]
  smb_multichannel_enabled            = true

  # Static website
  enable_static_website             = true
  static_website_index_document     = "index.html"
  static_website_error_404_document = "404.html"

  # Network rules
  enable_network_rules         = true
  network_rules_default_action = "Deny"
  network_rules_bypass         = ["AzureServices", "Logging", "Metrics"]
  network_rules_ip_rules       = ["203.0.113.0/24"]
  network_rules_subnet_ids     = [azurerm_subnet.private_endpoints.id]

  # Identity
  identity_type = "SystemAssigned"

  # Azure Files Authentication
  enable_azure_files_authentication         = true
  azure_files_authentication_directory_type = "AADDS"

  # Routing preference
  enable_routing_preference           = true
  routing_publish_internet_endpoints  = false
  routing_publish_microsoft_endpoints = true
  routing_choice                      = "MicrosoftRouting"

  # Immutability policy
  enable_immutability_policy                 = true
  immutability_allow_protected_append_writes = false
  immutability_state                         = "Unlocked"
  immutability_period_days                   = 30

  # Blob containers
  blob_containers = {
    documents = {
      access_type = "private"
      metadata = {
        purpose = "document-storage"
        tier    = "production"
      }
    }
    backups = {
      access_type = "private"
      metadata = {
        purpose = "backup-storage"
        tier    = "production"
      }
    }
    logs = {
      access_type = "private"
      metadata = {
        purpose = "log-storage"
        tier    = "production"
      }
    }
  }

  # File shares
  file_shares = {
    shared = {
      quota_gb         = 100
      enabled_protocol = "SMB"
      access_tier      = "Hot"
      metadata = {
        purpose = "shared-files"
        tier    = "production"
      }
    }
    backup = {
      quota_gb         = 500
      enabled_protocol = "SMB"
      access_tier      = "Cool"
      metadata = {
        purpose = "backup-files"
        tier    = "production"
      }
    }
  }

  # Queues
  queues = ["notifications", "processing", "deadletter"]
  queue_metadata = {
    environment = "production"
    purpose     = "message-processing"
  }

  # Tables
  tables = ["users", "sessions", "audit"]

  # Lifecycle management
  enable_lifecycle_management = true
  lifecycle_rules = [
    {
      name    = "delete-old-blobs"
      enabled = true
      filters = {
        prefix_match         = ["logs/", "temp/"]
        blob_types           = ["blockBlob"]
        match_blob_index_tag = null
      }
      actions = {
        base_blob = {
          tier_to_cool_after_days    = 30
          tier_to_archive_after_days = 90
          delete_after_days          = 365
        }
        snapshot = {
          tier_to_cool_after_days    = 7
          tier_to_archive_after_days = 30
          delete_after_days          = 90
        }
        version = {
          tier_to_cool_after_days    = 7
          tier_to_archive_after_days = 30
          delete_after_days          = 90
        }
      }
    }
  ]

  # Private endpoints
  private_endpoints = {
    blob = {
      subnet_id        = azurerm_subnet.private_endpoints.id
      subresource_name = "blob"
    }
    file = {
      subnet_id        = azurerm_subnet.private_endpoints.id
      subresource_name = "file"
    }
    dfs = {
      subnet_id        = azurerm_subnet.private_endpoints.id
      subresource_name = "dfs"
    }
  }

  # Diagnostic settings
  enable_diagnostic_settings = true
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
  diagnostic_logs            = ["StorageRead", "StorageWrite", "StorageDelete"]
  diagnostic_metrics         = ["Transaction", "Capacity"]

  tags = {
    Environment = "prod"
    Project     = "storage-example"
    Example     = "complete"
    CostCenter  = "IT"
    Compliance  = "required"
  }
}
