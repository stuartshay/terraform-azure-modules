# Storage Account Module - Setup Documentation Test
# This file provides documentation and examples for the testing structure

# Mock the AzureRM provider to avoid authentication requirements
mock_provider "azurerm" {}

# Test 1: Documentation example - minimum required configuration
run "minimum_configuration_example" {
  command = plan

  variables {
    workload            = "minimal"
    environment         = "dev"
    resource_group_name = "rg-minimal-dev-001"
    location            = "East US"
    location_short      = "eus"
  }

  # This test demonstrates the minimum required variables to create a storage account
  # The module will use default values for all optional parameters
  assert {
    condition     = azurerm_storage_account.main.name == "stminimaldeveus001"
    error_message = "Storage account should be created with minimum configuration"
  }

  assert {
    condition     = azurerm_storage_account.main.account_tier == "Standard"
    error_message = "Default account tier should be Standard"
  }

  assert {
    condition     = azurerm_storage_account.main.account_replication_type == "LRS"
    error_message = "Default replication type should be LRS"
  }
}

# Test 2: Documentation example - comprehensive configuration
run "comprehensive_configuration_example" {
  command = plan

  variables {
    # Required parameters
    workload            = "complete"
    environment         = "prod"
    resource_group_name = "rg-complete-prod-001"
    location            = "West US 2"
    location_short      = "wus2"

    # Storage account configuration
    account_tier             = "Standard"
    account_replication_type = "GRS"
    account_kind             = "StorageV2"
    access_tier              = "Hot"

    # Security configuration
    enable_https_traffic_only        = true
    min_tls_version                  = "TLS1_2"
    shared_access_key_enabled        = true
    allow_blob_public_access         = false
    public_network_access_enabled    = false
    enable_infrastructure_encryption = true

    # Advanced features
    enable_data_lake_gen2      = true
    enable_blob_versioning     = true
    enable_change_feed         = true
    change_feed_retention_days = 14

    # Blob containers
    blob_containers = {
      data = {
        metadata = {
          purpose   = "application-data"
          tier      = "hot"
          retention = "7-years"
        }
      }
      logs = {
        metadata = {
          purpose   = "application-logs"
          tier      = "cool"
          retention = "1-year"
        }
      }
      backups = {
        metadata = {
          purpose   = "database-backups"
          tier      = "archive"
          retention = "10-years"
        }
      }
    }

    # File shares
    file_shares = {
      shared = {
        quota_gb         = 100
        enabled_protocol = "SMB"
        access_tier      = "TransactionOptimized"
        metadata = {
          purpose = "shared-documents"
          team    = "development"
        }
      }
      backup = {
        quota_gb         = 1000
        enabled_protocol = "SMB"
        access_tier      = "Cool"
        metadata = {
          purpose = "backup-storage"
          team    = "operations"
        }
      }
    }

    # Queues and tables
    queues = ["messages", "tasks", "notifications", "events"]
    tables = ["entities", "logs", "metrics", "audit"]

    # Network security
    enable_network_rules         = true
    network_rules_default_action = "Deny"
    network_rules_bypass         = ["AzureServices", "Logging"]
    network_rules_ip_rules       = ["203.0.113.0/24"]

    # Private endpoints
    private_endpoints = {
      blob = {
        subnet_id        = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-prod/subnets/subnet-pe"
        subresource_name = "blob"
        private_dns_zone_ids = [
          "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
        ]
      }
      file = {
        subnet_id        = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-prod/subnets/subnet-pe"
        subresource_name = "file"
        private_dns_zone_ids = [
          "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.file.core.windows.net"
        ]
      }
    }

    # Identity and encryption
    identity_type                                  = "SystemAssigned"
    customer_managed_key_vault_key_id              = "https://kv-prod.vault.azure.net/keys/storage-key"
    customer_managed_key_user_assigned_identity_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-identity/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-storage"

    # Lifecycle management
    enable_lifecycle_management = true
    lifecycle_rules = [
      {
        name    = "archive-old-logs"
        enabled = true
        filters = {
          prefix_match         = ["logs/"]
          blob_types           = ["blockBlob"]
          match_blob_index_tag = null
        }
        actions = {
          base_blob = {
            tier_to_cool_after_days    = 30
            tier_to_archive_after_days = 90
            delete_after_days          = 2555 # 7 years
          }
          snapshot = {
            tier_to_cool_after_days    = 7
            tier_to_archive_after_days = 30
            delete_after_days          = 365
          }
          version = {
            tier_to_cool_after_days    = 7
            tier_to_archive_after_days = 30
            delete_after_days          = 365
          }
        }
      },
      {
        name    = "cleanup-temp-data"
        enabled = true
        filters = {
          prefix_match         = ["temp/"]
          blob_types           = ["blockBlob"]
          match_blob_index_tag = null
        }
        actions = {
          base_blob = {
            tier_to_cool_after_days    = null
            tier_to_archive_after_days = null
            delete_after_days          = 30
          }
          snapshot = null
          version  = null
        }
      }
    ]

    # Diagnostics
    enable_diagnostics         = true
    log_analytics_workspace_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-monitoring/providers/Microsoft.OperationalInsights/workspaces/law-prod"
    diagnostics_retention_days = 90

    # SAS token integration
    enable_sas_secret     = true
    key_vault_id          = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-keyvault/providers/Microsoft.KeyVault/vaults/kv-prod"
    key_vault_secret_name = "storage-account-sas-token"
    sas_services          = "bqtf"
    sas_resource_types    = "sco"
    sas_permissions       = "rl" # Read and list only for security
    sas_ttl_hours         = 24

    # Tags
    tags = {
      Environment        = "Production"
      Project            = "Enterprise Storage"
      Owner              = "Platform Team"
      CostCenter         = "Infrastructure"
      Backup             = "Required"
      DataClassification = "Confidential"
      Compliance         = "SOX,GDPR"
    }
  }

  # This test demonstrates a comprehensive configuration with all major features enabled
  assert {
    condition     = azurerm_storage_account.main.name == "stcompleteprodwus2001"
    error_message = "Storage account should be created with comprehensive configuration"
  }

  # Verify security features are enabled
  assert {
    condition     = azurerm_storage_account.main.https_traffic_only_enabled == true
    error_message = "HTTPS traffic only should be enabled for production"
  }

  assert {
    condition     = azurerm_storage_account.main.public_network_access_enabled == false
    error_message = "Public network access should be disabled for production security"
  }

  assert {
    condition     = azurerm_storage_account.main.is_hns_enabled == true
    error_message = "Data Lake Gen2 should be enabled when specified"
  }

  # Verify containers are created
  assert {
    condition     = length(azurerm_storage_container.main) == 3
    error_message = "All blob containers should be created"
  }

  # Verify file shares are created
  assert {
    condition     = length(azurerm_storage_share.main) == 2
    error_message = "All file shares should be created"
  }

  # Verify queues and tables are created
  assert {
    condition     = length(azurerm_storage_queue.main) == 4
    error_message = "All queues should be created"
  }

  assert {
    condition     = length(azurerm_storage_table.main) == 4
    error_message = "All tables should be created"
  }

  # Verify private endpoints are created
  assert {
    condition     = length(azurerm_private_endpoint.main) == 2
    error_message = "All private endpoints should be created"
  }
}

# Test 3: Documentation example - development environment
run "development_environment_example" {
  command = plan

  variables {
    # Basic configuration for development
    workload            = "devapp"
    environment         = "dev"
    resource_group_name = "rg-devapp-dev-001"
    location            = "Central US"
    location_short      = "cus"

    # Simple configuration for development
    account_tier             = "Standard"
    account_replication_type = "LRS" # Cost-effective for dev

    # Basic security (less restrictive for dev)
    public_network_access_enabled = true
    shared_access_key_enabled     = true

    # Development containers
    blob_containers = {
      uploads = {
        metadata = {
          purpose = "user-uploads"
          env     = "development"
        }
      }
      cache = {
        metadata = {
          purpose = "application-cache"
          env     = "development"
        }
      }
    }

    # Basic diagnostics
    enable_diagnostics         = true
    log_analytics_workspace_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-dev-monitoring/providers/Microsoft.OperationalInsights/workspaces/law-dev"

    # Development tags
    tags = {
      Environment  = "Development"
      Project      = "Application Development"
      Owner        = "Development Team"
      CostCenter   = "Engineering"
      AutoShutdown = "Enabled"
    }
  }

  # This test demonstrates a typical development environment setup
  assert {
    condition     = azurerm_storage_account.main.name == "stdevappdevcus001"
    error_message = "Development storage account should follow naming convention"
  }

  assert {
    condition     = azurerm_storage_account.main.account_replication_type == "LRS"
    error_message = "Development should use LRS for cost optimization"
  }

  assert {
    condition     = length(azurerm_storage_container.main) == 2
    error_message = "Development containers should be created"
  }
}

# Test 4: Documentation example - static website hosting
run "static_website_example" {
  command = plan

  variables {
    workload            = "website"
    environment         = "prod"
    resource_group_name = "rg-website-prod-001"
    location            = "East US"
    location_short      = "eus"

    # Static website configuration
    enable_static_website             = true
    static_website_index_document     = "index.html"
    static_website_error_404_document = "404.html"

    # Website-optimized settings
    account_tier             = "Standard"
    account_replication_type = "GRS"
    access_tier              = "Hot"

    # CDN-friendly configuration
    enable_https_traffic_only = true
    min_tls_version           = "TLS1_2"

    # Website containers
    blob_containers = {
      web = {
        metadata = {
          purpose = "static-website-content"
          type    = "public-website"
        }
      }
      assets = {
        metadata = {
          purpose = "website-assets"
          type    = "images-css-js"
        }
      }
    }

    tags = {
      Environment = "Production"
      Project     = "Corporate Website"
      Owner       = "Marketing Team"
      Website     = "corporate.example.com"
    }
  }

  # This test demonstrates static website hosting configuration
  assert {
    condition     = azurerm_storage_account.main.name == "stwebsiteprodeus001"
    error_message = "Website storage account should follow naming convention"
  }

  assert {
    condition     = var.enable_static_website == true
    error_message = "Static website hosting should be enabled"
  }
}

# Test 5: Documentation example - data lake configuration
run "data_lake_example" {
  command = plan

  variables {
    workload            = "datalake"
    environment         = "prod"
    resource_group_name = "rg-datalake-prod-001"
    location            = "West US 2"
    location_short      = "wus2"

    # Data Lake Gen2 configuration
    enable_data_lake_gen2 = true
    account_kind          = "StorageV2"
    account_tier          = "Standard"

    # Data protection features
    enable_blob_versioning     = true
    enable_change_feed         = true
    change_feed_retention_days = 90

    # Data lake containers
    blob_containers = {
      raw = {
        metadata = {
          zone    = "raw"
          purpose = "raw-data-ingestion"
        }
      }
      processed = {
        metadata = {
          zone    = "processed"
          purpose = "processed-analytics-data"
        }
      }
      curated = {
        metadata = {
          zone    = "curated"
          purpose = "curated-business-data"
        }
      }
    }

    # Data lifecycle management
    enable_lifecycle_management = true
    lifecycle_rules = [
      {
        name    = "raw-data-lifecycle"
        enabled = true
        filters = {
          prefix_match         = ["raw/"]
          blob_types           = ["blockBlob"]
          match_blob_index_tag = null
        }
        actions = {
          base_blob = {
            tier_to_cool_after_days    = 30
            tier_to_archive_after_days = 180
            delete_after_days          = 2555 # 7 years
          }
          snapshot = null
          version  = null
        }
      }
    ]

    # Security for data lake
    public_network_access_enabled    = false
    enable_infrastructure_encryption = true

    tags = {
      Environment = "Production"
      Project     = "Data Analytics Platform"
      Owner       = "Data Engineering Team"
      DataLake    = "true"
    }
  }

  # This test demonstrates data lake configuration
  assert {
    condition     = azurerm_storage_account.main.name == "stdatalakeprodwus2001"
    error_message = "Data lake storage account should follow naming convention"
  }

  assert {
    condition     = azurerm_storage_account.main.is_hns_enabled == true
    error_message = "Hierarchical namespace should be enabled for data lake"
  }

  assert {
    condition     = length(azurerm_storage_container.main) == 3
    error_message = "Data lake should have raw, processed, and curated containers"
  }
}

# Test 6: Test framework documentation
run "test_framework_documentation" {
  command = plan

  variables {
    workload            = "testdemo"
    environment         = "dev"
    resource_group_name = "rg-testdemo-dev-001"
    location            = "North Central US"
    location_short      = "ncus"
  }

  # This test serves as documentation for the testing framework capabilities
  # It demonstrates how to write assertions and validate module behavior

  # Example 1: String matching assertions
  assert {
    condition     = azurerm_storage_account.main.name == "sttestdemodevncus001"
    error_message = "Storage account name should match expected naming pattern"
  }

  # Example 2: Boolean assertions
  assert {
    condition     = azurerm_storage_account.main.https_traffic_only_enabled == true
    error_message = "HTTPS traffic should be enforced by default"
  }

  # Example 3: Numeric assertions
  assert {
    condition     = length(azurerm_storage_container.main) == 0
    error_message = "No containers should be created when blob_containers is empty"
  }

  # Example 4: Complex object assertions
  assert {
    condition     = azurerm_storage_account.main.resource_group_name == var.resource_group_name
    error_message = "Storage account should be created in the specified resource group"
  }
}

# Documentation: Test File Categories
#
# This module includes four main test files:
#
# 1. basic.tftest.hcl - Tests core functionality
#    - Default value verification
#    - Configuration variations
#    - Naming convention compliance
#    - Feature combinations
#    - Cross-platform compatibility
#
# 2. validation.tftest.hcl - Tests input validation
#    - Invalid parameter rejection
#    - Boundary condition testing
#    - Type validation
#    - Range validation
#    - Valid boundary values
#
# 3. outputs.tftest.hcl - Tests output correctness
#    - Output value accuracy
#    - Output format validation
#    - Null/non-null output conditions
#    - Complex output structures
#    - Cross-reference validation
#
# 4. setup.tftest.hcl (this file) - Provides documentation and examples
#    - Usage examples for different scenarios
#    - Best practice demonstrations
#    - Configuration patterns
#    - Test framework documentation
#
# Running Tests:
#
# Individual test files:
# terraform test tests/basic.tftest.hcl
# terraform test tests/validation.tftest.hcl
# terraform test tests/outputs.tftest.hcl
# terraform test tests/setup.tftest.hcl
#
# All tests:
# terraform test
#
# Specific test run:
# terraform test -filter="basic_storage_account_creation"
#
# With Makefile:
# make terraform-test-module MODULE=storage-account
# make terraform-test-file MODULE=storage-account FILE=basic.tftest.hcl
#
# Expected Test Coverage:
# - Basic functionality: 15 test scenarios
# - Validation rules: 39 test scenarios
# - Output verification: 21 test scenarios
# - Documentation examples: 6 scenarios
# Total: 81 comprehensive test scenarios
