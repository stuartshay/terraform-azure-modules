# Storage Account Module - Validation Tests
# Tests input validation rules and error conditions

# Mock the AzureRM provider to avoid authentication requirements
mock_provider "azurerm" {}

# Test 1: Invalid environment value
run "invalid_environment" {
  command = plan

  variables {
    workload            = "test"
    environment         = "invalid"
    resource_group_name = "rg-test-invalid-001"
    location            = "East US"
    location_short      = "eus"
  }

  expect_failures = [
    var.environment,
  ]
}

# Test 2: Empty workload name
run "empty_workload" {
  command = plan

  variables {
    workload            = ""
    environment         = "dev"
    resource_group_name = "rg-empty-dev-001"
    location            = "East US"
    location_short      = "eus"
  }

  expect_failures = [
    var.workload,
  ]
}

# Test 3: Workload name too long (exceeds 10 characters)
run "workload_name_too_long" {
  command = plan

  variables {
    workload            = "verylongworkloadname" # 20 characters, exceeds 10 limit
    environment         = "dev"
    resource_group_name = "rg-long-dev-001"
    location            = "East US"
    location_short      = "eus"
  }

  expect_failures = [
    var.workload,
  ]
}

# Test 4: Empty resource group name
run "empty_resource_group_name" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = ""
    location            = "East US"
    location_short      = "eus"
  }

  expect_failures = [
    var.resource_group_name,
  ]
}

# Test 5: Empty location
run "empty_location" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = ""
    location_short      = "eus"
  }

  expect_failures = [
    var.location,
  ]
}

# Test 6: Location short name too long (exceeds 6 characters)
run "location_short_too_long" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    location_short      = "verylongshortname" # Exceeds 6 characters
  }

  expect_failures = [
    var.location_short,
  ]
}

# Test 7: Invalid account tier
run "invalid_account_tier" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    location_short      = "eus"
    account_tier        = "Basic" # Invalid tier
  }

  expect_failures = [
    var.account_tier,
  ]
}

# Test 8: Invalid account replication type
run "invalid_replication_type" {
  command = plan

  variables {
    workload                 = "test"
    environment              = "dev"
    resource_group_name      = "rg-test-dev-001"
    location                 = "East US"
    location_short           = "eus"
    account_replication_type = "INVALID" # Invalid replication type
  }

  expect_failures = [
    var.account_replication_type,
  ]
}

# Test 9: Invalid account kind
run "invalid_account_kind" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    location_short      = "eus"
    account_kind        = "InvalidKind" # Invalid account kind
  }

  expect_failures = [
    var.account_kind,
  ]
}

# Test 10: Invalid access tier
run "invalid_access_tier" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    location_short      = "eus"
    access_tier         = "Warm" # Invalid access tier
  }

  expect_failures = [
    var.access_tier,
  ]
}

# Test 11: Invalid minimum TLS version
run "invalid_min_tls_version" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    location_short      = "eus"
    min_tls_version     = "TLS1_3" # Invalid TLS version
  }

  expect_failures = [
    var.min_tls_version,
  ]
}

# Test 12: Invalid SAS expiration action
run "invalid_sas_expiration_action" {
  command = plan

  variables {
    workload              = "test"
    environment           = "dev"
    resource_group_name   = "rg-test-dev-001"
    location              = "East US"
    location_short        = "eus"
    sas_expiration_action = "Block" # Invalid action, should be "Log"
  }

  expect_failures = [
    var.sas_expiration_action,
  ]
}

# Test 13: Change feed retention days out of range (too low)
run "change_feed_retention_too_low" {
  command = plan

  variables {
    workload                   = "test"
    environment                = "dev"
    resource_group_name        = "rg-test-dev-001"
    location                   = "East US"
    location_short             = "eus"
    change_feed_retention_days = 0 # Below minimum of 1
  }

  expect_failures = [
    var.change_feed_retention_days,
  ]
}

# Test 14: Change feed retention days out of range (too high)
run "change_feed_retention_too_high" {
  command = plan

  variables {
    workload                   = "test"
    environment                = "dev"
    resource_group_name        = "rg-test-dev-001"
    location                   = "East US"
    location_short             = "eus"
    change_feed_retention_days = 150000 # Above maximum of 146000
  }

  expect_failures = [
    var.change_feed_retention_days,
  ]
}

# Test 15: Blob delete retention days out of range (too high)
run "blob_delete_retention_too_high" {
  command = plan

  variables {
    workload                   = "test"
    environment                = "dev"
    resource_group_name        = "rg-test-dev-001"
    location                   = "East US"
    location_short             = "eus"
    blob_delete_retention_days = 400 # Above maximum of 365
  }

  expect_failures = [
    var.blob_delete_retention_days,
  ]
}

# Test 16: Container delete retention days out of range (too high)
run "container_delete_retention_too_high" {
  command = plan

  variables {
    workload                        = "test"
    environment                     = "dev"
    resource_group_name             = "rg-test-dev-001"
    location                        = "East US"
    location_short                  = "eus"
    container_delete_retention_days = 400 # Above maximum of 365
  }

  expect_failures = [
    var.container_delete_retention_days,
  ]
}

# Test 17: Container immutability days out of range (too low)
run "container_immutability_too_low" {
  command = plan

  variables {
    workload                    = "test"
    environment                 = "dev"
    resource_group_name         = "rg-test-dev-001"
    location                    = "East US"
    location_short              = "eus"
    container_immutability_days = 0 # Below minimum of 1
  }

  expect_failures = [
    var.container_immutability_days,
  ]
}

# Test 18: Invalid network rules default action
run "invalid_network_rules_default_action" {
  command = plan

  variables {
    workload                     = "test"
    environment                  = "dev"
    resource_group_name          = "rg-test-dev-001"
    location                     = "East US"
    location_short               = "eus"
    network_rules_default_action = "Block" # Invalid, should be "Allow" or "Deny"
  }

  expect_failures = [
    var.network_rules_default_action,
  ]
}

# Test 19: Invalid network rules bypass values
run "invalid_network_rules_bypass" {
  command = plan

  variables {
    workload             = "test"
    environment          = "dev"
    resource_group_name  = "rg-test-dev-001"
    location             = "East US"
    location_short       = "eus"
    network_rules_bypass = ["Invalid", "BadValue"] # Invalid bypass values
  }

  expect_failures = [
    var.network_rules_bypass,
  ]
}

# Test 20: Invalid identity type
run "invalid_identity_type" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    location_short      = "eus"
    identity_type       = "ManagedIdentity" # Invalid type
  }

  expect_failures = [
    var.identity_type,
  ]
}

# Test 21: Invalid Azure Files authentication directory type
run "invalid_azure_files_auth_directory_type" {
  command = plan

  variables {
    workload                                  = "test"
    environment                               = "dev"
    resource_group_name                       = "rg-test-dev-001"
    location                                  = "East US"
    location_short                            = "eus"
    azure_files_authentication_directory_type = "InvalidDir" # Invalid directory type
  }

  expect_failures = [
    var.azure_files_authentication_directory_type,
  ]
}

# Test 22: Invalid routing choice
run "invalid_routing_choice" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    location_short      = "eus"
    routing_choice      = "FastRouting" # Invalid routing choice
  }

  expect_failures = [
    var.routing_choice,
  ]
}

# Test 23: Invalid immutability state
run "invalid_immutability_state" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    location_short      = "eus"
    immutability_state  = "Pending" # Invalid state, should be "Locked" or "Unlocked"
  }

  expect_failures = [
    var.immutability_state,
  ]
}

# Test 24: Invalid file share enabled protocol
run "invalid_file_share_protocol" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    location_short      = "eus"
    file_shares = {
      test = {
        quota_gb         = 100
        enabled_protocol = "FTP" # Invalid protocol, should be "SMB" or "NFS"
      }
    }
  }

  expect_failures = [
    var.file_shares,
  ]
}

# Test 25: Invalid file share access tier
run "invalid_file_share_access_tier" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    location_short      = "eus"
    file_shares = {
      test = {
        quota_gb    = 100
        access_tier = "Warm" # Invalid tier, should be "TransactionOptimized", "Hot", or "Cool"
      }
    }
  }

  expect_failures = [
    var.file_shares,
  ]
}

# Test 26: Invalid private endpoint subresource name
run "invalid_private_endpoint_subresource" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    location_short      = "eus"
    private_endpoints = {
      invalid = {
        subnet_id        = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet-pe"
        subresource_name = "invalid_subresource" # Invalid subresource name
      }
    }
  }

  expect_failures = [
    var.private_endpoints,
  ]
}

# Test 27: Queue logging retention days out of range
run "queue_logging_retention_too_high" {
  command = plan

  variables {
    workload                     = "test"
    environment                  = "dev"
    resource_group_name          = "rg-test-dev-001"
    location                     = "East US"
    location_short               = "eus"
    queue_logging_retention_days = 400 # Above maximum of 365
  }

  expect_failures = [
    var.queue_logging_retention_days,
  ]
}

# Test 28: Queue metrics retention days out of range
run "queue_metrics_retention_too_high" {
  command = plan

  variables {
    workload                     = "test"
    environment                  = "dev"
    resource_group_name          = "rg-test-dev-001"
    location                     = "East US"
    location_short               = "eus"
    queue_metrics_retention_days = 400 # Above maximum of 365
  }

  expect_failures = [
    var.queue_metrics_retention_days,
  ]
}

# Test 29: Share retention days out of range
run "share_retention_too_high" {
  command = plan

  variables {
    workload             = "test"
    environment          = "dev"
    resource_group_name  = "rg-test-dev-001"
    location             = "East US"
    location_short       = "eus"
    share_retention_days = 400 # Above maximum of 365
  }

  expect_failures = [
    var.share_retention_days,
  ]
}

# Test 30: Diagnostics retention days out of range
run "diagnostics_retention_too_high" {
  command = plan

  variables {
    workload                   = "test"
    environment                = "dev"
    resource_group_name        = "rg-test-dev-001"
    location                   = "East US"
    location_short             = "eus"
    diagnostics_retention_days = 400 # Above maximum of 365
  }

  expect_failures = [
    var.diagnostics_retention_days,
  ]
}

# Test 31: Invalid SAS services string
run "invalid_sas_services" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    location_short      = "eus"
    sas_services        = "bqtfx" # 'x' is invalid, should only contain b,q,t,f
  }

  expect_failures = [
    var.sas_services,
  ]
}

# Test 32: Invalid SAS resource types string
run "invalid_sas_resource_types" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    location_short      = "eus"
    sas_resource_types  = "scox" # 'x' is invalid, should only contain s,c,o
  }

  expect_failures = [
    var.sas_resource_types,
  ]
}

# Test 33: Invalid SAS permissions string
run "invalid_sas_permissions" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    location_short      = "eus"
    sas_permissions     = "rwdlx" # 'x' is invalid, should only contain r,w,d,l,a
  }

  expect_failures = [
    var.sas_permissions,
  ]
}

# Test 34: SAS TTL hours out of range (too low)
run "sas_ttl_too_low" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    location_short      = "eus"
    sas_ttl_hours       = 0 # Below minimum of 1
  }

  expect_failures = [
    var.sas_ttl_hours,
  ]
}

# Test 35: SAS TTL hours out of range (too high)
run "sas_ttl_too_high" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    location_short      = "eus"
    sas_ttl_hours       = 10000 # Above maximum of 8760 (1 year)
  }

  expect_failures = [
    var.sas_ttl_hours,
  ]
}

# Test 36: Start time offset minutes out of range (too low)
run "start_time_offset_too_low" {
  command = plan

  variables {
    workload                  = "test"
    environment               = "dev"
    resource_group_name       = "rg-test-dev-001"
    location                  = "East US"
    location_short            = "eus"
    start_time_offset_minutes = -120 # Below minimum of -60
  }

  expect_failures = [
    var.start_time_offset_minutes,
  ]
}

# Test 37: Start time offset minutes out of range (too high)
run "start_time_offset_too_high" {
  command = plan

  variables {
    workload                  = "test"
    environment               = "dev"
    resource_group_name       = "rg-test-dev-001"
    location                  = "East US"
    location_short            = "eus"
    start_time_offset_minutes = 120 # Above maximum of 60
  }

  expect_failures = [
    var.start_time_offset_minutes,
  ]
}

# Test 38: Valid boundary values - minimum values
run "valid_boundary_minimums" {
  command = plan

  variables {
    workload                        = "min"
    environment                     = "dev"
    resource_group_name             = "rg-min-dev-001"
    location                        = "East US"
    location_short                  = "eus"
    change_feed_retention_days      = 1   # Minimum valid value
    blob_delete_retention_days      = 0   # Minimum valid value (0 = disabled)
    container_delete_retention_days = 0   # Minimum valid value (0 = disabled)
    container_immutability_days     = 1   # Minimum valid value
    immutability_period_days        = 1   # Minimum valid value
    queue_logging_retention_days    = 1   # Minimum valid value
    queue_metrics_retention_days    = 1   # Minimum valid value
    share_retention_days            = 0   # Minimum valid value (0 = disabled)
    diagnostics_retention_days      = 0   # Minimum valid value (0 = disabled)
    sas_ttl_hours                   = 1   # Minimum valid value
    start_time_offset_minutes       = -60 # Minimum valid value
  }

  # This test should pass - verifying minimum boundary values are accepted
  assert {
    condition     = azurerm_storage_account.main.name == "stmindeveus001"
    error_message = "Storage account should be created with minimum valid boundary values"
  }
}

# Test 39: Valid boundary values - maximum values
run "valid_boundary_maximums" {
  command = plan

  variables {
    workload                        = "max"
    environment                     = "dev"
    resource_group_name             = "rg-max-dev-001"
    location                        = "East US"
    location_short                  = "eus"
    change_feed_retention_days      = 146000 # Maximum valid value
    blob_delete_retention_days      = 365    # Maximum valid value
    container_delete_retention_days = 365    # Maximum valid value
    container_immutability_days     = 146000 # Maximum valid value
    immutability_period_days        = 146000 # Maximum valid value
    queue_logging_retention_days    = 365    # Maximum valid value
    queue_metrics_retention_days    = 365    # Maximum valid value
    share_retention_days            = 365    # Maximum valid value
    diagnostics_retention_days      = 365    # Maximum valid value
    sas_ttl_hours                   = 8760   # Maximum valid value (1 year)
    start_time_offset_minutes       = 60     # Maximum valid value
  }

  # This test should pass - verifying maximum boundary values are accepted
  assert {
    condition     = azurerm_storage_account.main.name == "stmaxdeveus001"
    error_message = "Storage account should be created with maximum valid boundary values"
  }
}
