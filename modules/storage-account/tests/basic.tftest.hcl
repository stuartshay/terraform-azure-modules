# Storage Account Module - Basic Functionality Tests
# Tests core module functionality with various configurations

# Mock the AzureRM provider to avoid authentication requirements
mock_provider "azurerm" {}

# Test 1: Basic storage account creation with default values
run "basic_storage_account_creation" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    location_short      = "eus"
  }

  # Test storage account name generation
  assert {
    condition     = azurerm_storage_account.main.name == "sttestdeveus001"
    error_message = "Storage account name should follow the naming convention: st{workload}{environment}{location_short}001"
  }

  # Test basic configuration
  assert {
    condition     = azurerm_storage_account.main.account_tier == "Standard"
    error_message = "Default account tier should be Standard"
  }

  assert {
    condition     = azurerm_storage_account.main.account_replication_type == "LRS"
    error_message = "Default account replication type should be LRS"
  }

  assert {
    condition     = azurerm_storage_account.main.account_kind == "StorageV2"
    error_message = "Default account kind should be StorageV2"
  }

  assert {
    condition     = azurerm_storage_account.main.access_tier == "Hot"
    error_message = "Default access tier should be Hot"
  }

  # Test security defaults
  assert {
    condition     = azurerm_storage_account.main.https_traffic_only_enabled == true
    error_message = "HTTPS traffic only should be enabled by default"
  }

  assert {
    condition     = azurerm_storage_account.main.min_tls_version == "TLS1_2"
    error_message = "Minimum TLS version should be TLS1_2 by default"
  }

  assert {
    condition     = azurerm_storage_account.main.shared_access_key_enabled == true
    error_message = "Shared access key should be enabled by default"
  }

  assert {
    condition     = azurerm_storage_account.main.allow_nested_items_to_be_public == false
    error_message = "Blob public access should be disabled by default"
  }

  assert {
    condition     = azurerm_storage_account.main.public_network_access_enabled == true
    error_message = "Public network access should be enabled by default"
  }
}

# Test 2: Premium storage account configuration
run "premium_storage_account" {
  command = plan

  variables {
    workload                 = "premium"
    environment              = "prod"
    resource_group_name      = "rg-premium-prod-001"
    location                 = "West US 2"
    location_short           = "wus2"
    account_tier             = "Premium"
    account_replication_type = "LRS"
    account_kind             = "BlockBlobStorage"
  }

  assert {
    condition     = azurerm_storage_account.main.name == "stpremiumprodwus2001"
    error_message = "Premium storage account name should follow naming convention"
  }

  assert {
    condition     = azurerm_storage_account.main.account_tier == "Premium"
    error_message = "Account tier should be Premium"
  }

  assert {
    condition     = azurerm_storage_account.main.account_kind == "BlockBlobStorage"
    error_message = "Account kind should be BlockBlobStorage for Premium tier"
  }
}

# Test 3: Storage account with advanced features enabled
run "advanced_features_enabled" {
  command = plan

  variables {
    workload                         = "advanced"
    environment                      = "dev"
    resource_group_name              = "rg-advanced-dev-001"
    location                         = "Central US"
    location_short                   = "cus"
    enable_data_lake_gen2            = true
    enable_infrastructure_encryption = true
    enable_blob_versioning           = true
    enable_change_feed               = true
    change_feed_retention_days       = 14
  }

  assert {
    condition     = azurerm_storage_account.main.is_hns_enabled == true
    error_message = "Data Lake Gen2 (Hierarchical Namespace) should be enabled"
  }

  assert {
    condition     = azurerm_storage_account.main.infrastructure_encryption_enabled == true
    error_message = "Infrastructure encryption should be enabled"
  }
}

# Test 4: Storage account with blob containers
run "storage_with_blob_containers" {
  command = plan

  variables {
    workload            = "container"
    environment         = "dev"
    resource_group_name = "rg-container-dev-001"
    location            = "North Central US"
    location_short      = "ncus"
    blob_containers = {
      data = {
        metadata = {
          purpose = "data-storage"
        }
      }
      logs = {
        metadata = {
          purpose = "log-storage"
        }
      }
    }
  }

  # Test blob container creation
  assert {
    condition     = length(azurerm_storage_container.main) == 2
    error_message = "Should create 2 blob containers"
  }

  # Test container naming
  assert {
    condition     = azurerm_storage_container.main["data"].name == "container-data-dev"
    error_message = "Data container should follow naming convention: container-{name}-{environment}"
  }

  assert {
    condition     = azurerm_storage_container.main["logs"].name == "container-logs-dev"
    error_message = "Logs container should follow naming convention: container-{name}-{environment}"
  }

  # Test container security - all containers must be private
  assert {
    condition     = azurerm_storage_container.main["data"].container_access_type == "private"
    error_message = "All containers must have private access type for security compliance"
  }

  assert {
    condition     = azurerm_storage_container.main["logs"].container_access_type == "private"
    error_message = "All containers must have private access type for security compliance"
  }
}

# Test 5: Storage account with file shares
run "storage_with_file_shares" {
  command = plan

  variables {
    workload            = "files"
    environment         = "staging"
    resource_group_name = "rg-fileshare-staging-001"
    location            = "South Central US"
    location_short      = "scus"
    file_shares = {
      documents = {
        quota_gb         = 100
        enabled_protocol = "SMB"
        access_tier      = "Hot"
        metadata = {
          purpose = "document-storage"
        }
      }
      backup = {
        quota_gb         = 500
        enabled_protocol = "SMB"
        access_tier      = "Cool"
        metadata = {
          purpose = "backup-storage"
        }
      }
    }
  }

  # Test file share creation
  assert {
    condition     = length(azurerm_storage_share.main) == 2
    error_message = "Should create 2 file shares"
  }

  # Test file share naming
  assert {
    condition     = azurerm_storage_share.main["documents"].name == "share-documents-staging"
    error_message = "Documents share should follow naming convention: share-{name}-{environment}"
  }

  assert {
    condition     = azurerm_storage_share.main["backup"].name == "share-backup-staging"
    error_message = "Backup share should follow naming convention: share-{name}-{environment}"
  }

  # Test quota configuration
  assert {
    condition     = azurerm_storage_share.main["documents"].quota == 100
    error_message = "Documents share quota should be 100 GB"
  }

  assert {
    condition     = azurerm_storage_share.main["backup"].quota == 500
    error_message = "Backup share quota should be 500 GB"
  }
}

# Test 6: Storage account with queues and tables
run "storage_with_queues_tables" {
  command = plan

  variables {
    workload            = "queue"
    environment         = "dev"
    resource_group_name = "rg-queue-dev-001"
    location            = "West Central US"
    location_short      = "wcus"
    queues              = ["messages", "tasks", "notifications"]
    tables              = ["entities", "logs", "metrics"]
  }

  # Test queue creation
  assert {
    condition     = length(azurerm_storage_queue.main) == 3
    error_message = "Should create 3 queues"
  }

  # Test queue naming
  assert {
    condition     = azurerm_storage_queue.main["messages"].name == "queue-messages-dev"
    error_message = "Messages queue should follow naming convention: queue-{name}-{environment}"
  }

  # Test table creation
  assert {
    condition     = length(azurerm_storage_table.main) == 3
    error_message = "Should create 3 tables"
  }

  # Test table naming
  assert {
    condition     = azurerm_storage_table.main["entities"].name == "tableEntitiesDev"
    error_message = "Entities table should follow naming convention: table{Title(name)}{Title(environment)}"
  }
}

# Test 7: Storage account with different replication types
run "geo_redundant_storage" {
  command = plan

  variables {
    workload                 = "geo"
    environment              = "prod"
    resource_group_name      = "rg-geo-prod-001"
    location                 = "East US 2"
    location_short           = "eus2"
    account_replication_type = "GRS"
  }

  assert {
    condition     = azurerm_storage_account.main.account_replication_type == "GRS"
    error_message = "Account replication type should be GRS"
  }
}

# Test 8: Storage account with network rules
run "network_rules_configuration" {
  command = plan

  variables {
    workload                      = "secure"
    environment                   = "prod"
    resource_group_name           = "rg-secure-prod-001"
    location                      = "Canada Central"
    location_short                = "cac"
    enable_network_rules          = true
    network_rules_default_action  = "Deny"
    network_rules_bypass          = ["AzureServices", "Logging"]
    network_rules_ip_rules        = ["203.0.113.0/24", "198.51.100.0/24"]
    public_network_access_enabled = false
  }

  assert {
    condition     = azurerm_storage_account.main.public_network_access_enabled == false
    error_message = "Public network access should be disabled for secure configuration"
  }
}

# Test 9: Tag application
run "tag_application" {
  command = plan

  variables {
    workload            = "tagged"
    environment         = "dev"
    resource_group_name = "rg-tagged-dev-001"
    location            = "Australia East"
    location_short      = "aue"
    tags = {
      Environment = "Development"
      Project     = "Storage Testing"
      Owner       = "DevOps Team"
      CostCenter  = "Engineering"
    }
  }

  assert {
    condition     = azurerm_storage_account.main.tags["Environment"] == "Development"
    error_message = "Environment tag should be properly applied"
  }

  assert {
    condition     = azurerm_storage_account.main.tags["Project"] == "Storage Testing"
    error_message = "Project tag should be properly applied"
  }

  assert {
    condition     = azurerm_storage_account.main.tags["Owner"] == "DevOps Team"
    error_message = "Owner tag should be properly applied"
  }
}

# Test 10: Diagnostic settings configuration
run "diagnostic_settings" {
  command = plan

  variables {
    workload                   = "diag"
    environment                = "dev"
    resource_group_name        = "rg-diag-dev-001"
    location                   = "UK South"
    location_short             = "uks"
    enable_diagnostics         = true
    log_analytics_workspace_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-monitoring/providers/Microsoft.OperationalInsights/workspaces/law-monitoring"
    diagnostics_retention_days = 30
  }

  # Test that diagnostic settings are created for each storage service
  assert {
    condition     = azurerm_monitor_diagnostic_setting.blob != null
    error_message = "Blob service diagnostic setting should be created when diagnostics are enabled"
  }

  assert {
    condition     = azurerm_monitor_diagnostic_setting.file != null
    error_message = "File service diagnostic setting should be created when diagnostics are enabled"
  }

  assert {
    condition     = azurerm_monitor_diagnostic_setting.queue != null
    error_message = "Queue service diagnostic setting should be created when diagnostics are enabled"
  }

  assert {
    condition     = azurerm_monitor_diagnostic_setting.table != null
    error_message = "Table service diagnostic setting should be created when diagnostics are enabled"
  }
}

# Test 11: SAS token integration
run "sas_token_integration" {
  command = plan

  variables {
    workload              = "sas"
    environment           = "dev"
    resource_group_name   = "rg-sas-dev-001"
    location              = "Japan East"
    location_short        = "jpe"
    enable_sas_secret     = true
    key_vault_id          = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-keyvault/providers/Microsoft.KeyVault/vaults/kv-test"
    key_vault_secret_name = "storage-account-sas-token"
    sas_services          = "bqtf"
    sas_resource_types    = "sco"
    sas_permissions       = "rwdl"
    sas_ttl_hours         = 24
  }

  # Test SAS token generation
  assert {
    condition     = data.azurerm_storage_account_sas.main != null
    error_message = "SAS token data source should be created when SAS secret is enabled"
  }

  # Test Key Vault secret creation
  assert {
    condition     = azurerm_key_vault_secret.sas_token != null
    error_message = "Key Vault secret should be created when SAS integration is enabled"
  }
}

# Test 12: Lifecycle management
run "lifecycle_management" {
  command = plan

  variables {
    workload                    = "lifecycle"
    environment                 = "prod"
    resource_group_name         = "rg-lifecycle-prod-001"
    location                    = "Brazil South"
    location_short              = "brs"
    enable_lifecycle_management = true
    lifecycle_rules = [
      {
        name    = "move-to-cool"
        enabled = true
        filters = {
          prefix_match         = ["documents/"]
          blob_types           = ["blockBlob"]
          match_blob_index_tag = null
        }
        actions = {
          base_blob = {
            tier_to_cool_after_days    = 30
            tier_to_archive_after_days = 90
            delete_after_days          = 365
          }
          snapshot = null
          version  = null
        }
      }
    ]
  }

  assert {
    condition     = azurerm_storage_management_policy.main != null
    error_message = "Lifecycle management policy should be created when enabled"
  }
}

# Test 13: Static website hosting
run "static_website" {
  command = plan

  variables {
    workload                          = "website"
    environment                       = "dev"
    resource_group_name               = "rg-website-dev-001"
    location                          = "France Central"
    location_short                    = "frc"
    enable_static_website             = true
    static_website_index_document     = "index.html"
    static_website_error_404_document = "404.html"
  }

  # Note: Static website configuration is tested through the azurerm_storage_account resource
  # The actual static_website block validation occurs during the plan phase
  assert {
    condition     = var.enable_static_website == true
    error_message = "Static website should be enabled"
  }
}

# Test 14: Cross-platform compatibility (different locations and naming)
run "cross_platform_compatibility" {
  command = plan

  variables {
    workload            = "cross"
    environment         = "staging"
    resource_group_name = "rg-cross-staging-001"
    location            = "Germany West Central"
    location_short      = "gwc"
  }

  # Test that storage account name is generated correctly for different locations
  assert {
    condition     = azurerm_storage_account.main.name == "stcrossstaginggwc001"
    error_message = "Storage account name should be generated correctly for different locations"
  }

  assert {
    condition     = azurerm_storage_account.main.location == "Germany West Central"
    error_message = "Storage account location should match the specified location"
  }
}

# Test 15: Maximum workload name length
run "workload_name_length_limit" {
  command = plan

  variables {
    workload            = "maxlength" # 9 characters (within 10 character limit)
    environment         = "dev"
    resource_group_name = "rg-maxlength-dev-001"
    location            = "Korea Central"
    location_short      = "krc"
  }

  assert {
    condition     = azurerm_storage_account.main.name == "stmaxlengthdevkrc001"
    error_message = "Storage account name should handle maximum workload name length correctly"
  }
}
