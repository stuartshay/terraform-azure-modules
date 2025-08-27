# Storage Account Module - Main Configuration
# This module creates Azure Storage Account with configurable features

# Local values for consistent naming
locals {
  storage_account_name = "st${var.workload}${var.environment}${var.location_short}001"

  # Create container names
  container_names = {
    for container_name, container_config in var.blob_containers :
    container_name => "container-${container_name}-${var.environment}"
  }

  # Create file share names
  file_share_names = {
    for share_name, share_config in var.file_shares :
    share_name => "share-${share_name}-${var.environment}"
  }

  # Create queue names
  queue_names = {
    for queue_name in var.queues :
    queue_name => "queue-${queue_name}-${var.environment}"
  }

  # Create table names
  table_names = {
    for table_name in var.tables :
    table_name => "table${title(table_name)}${title(var.environment)}"
  }
}

# Storage Account
resource "azurerm_storage_account" "main" {
  #checkov:skip=CKV2_AZURE_40:Shared access key configuration is controlled by variable
  #checkov:skip=CKV2_AZURE_38:Soft delete configuration is controlled by variable
  name                     = local.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind             = var.account_kind
  access_tier              = var.access_tier

  # Security configurations
  https_traffic_only_enabled      = var.enable_https_traffic_only
  min_tls_version                 = var.min_tls_version
  shared_access_key_enabled       = var.shared_access_key_enabled
  allow_nested_items_to_be_public = var.allow_blob_public_access
  public_network_access_enabled   = var.public_network_access_enabled

  # Advanced features
  is_hns_enabled                   = var.enable_data_lake_gen2
  nfsv3_enabled                    = var.enable_nfsv3
  large_file_share_enabled         = var.enable_large_file_share
  cross_tenant_replication_enabled = var.enable_cross_tenant_replication

  # Infrastructure encryption
  infrastructure_encryption_enabled = var.enable_infrastructure_encryption

  # SAS expiration policy
  dynamic "sas_policy" {
    for_each = var.sas_expiration_period != null ? [1] : []
    content {
      expiration_period = var.sas_expiration_period
      expiration_action = var.sas_expiration_action
    }
  }

  # Blob properties
  dynamic "blob_properties" {
    for_each = var.enable_blob_properties ? [1] : []
    content {
      # Versioning
      versioning_enabled = var.enable_blob_versioning

      # Change feed
      change_feed_enabled           = var.enable_change_feed
      change_feed_retention_in_days = var.change_feed_retention_days

      # Last access time tracking
      last_access_time_enabled = var.enable_last_access_time_tracking

      # Delete retention policy
      dynamic "delete_retention_policy" {
        for_each = var.blob_delete_retention_days > 0 ? [1] : []
        content {
          days = var.blob_delete_retention_days
        }
      }

      # Container delete retention policy
      dynamic "container_delete_retention_policy" {
        for_each = var.container_delete_retention_days > 0 ? [1] : []
        content {
          days = var.container_delete_retention_days
        }
      }

      # CORS rules
      dynamic "cors_rule" {
        for_each = var.cors_rules
        content {
          allowed_headers    = cors_rule.value.allowed_headers
          allowed_methods    = cors_rule.value.allowed_methods
          allowed_origins    = cors_rule.value.allowed_origins
          exposed_headers    = cors_rule.value.exposed_headers
          max_age_in_seconds = cors_rule.value.max_age_in_seconds
        }
      }
    }
  }

  # Queue properties
  dynamic "queue_properties" {
    for_each = var.enable_queue_properties ? [1] : []
    content {
      # CORS rules for queues
      dynamic "cors_rule" {
        for_each = var.queue_cors_rules
        content {
          allowed_headers    = cors_rule.value.allowed_headers
          allowed_methods    = cors_rule.value.allowed_methods
          allowed_origins    = cors_rule.value.allowed_origins
          exposed_headers    = cors_rule.value.exposed_headers
          max_age_in_seconds = cors_rule.value.max_age_in_seconds
        }
      }

      # Logging
      dynamic "logging" {
        for_each = var.enable_queue_logging ? [1] : []
        content {
          delete                = var.queue_logging_delete
          read                  = var.queue_logging_read
          write                 = var.queue_logging_write
          version               = var.queue_logging_version
          retention_policy_days = var.queue_logging_retention_days
        }
      }

      # Metrics
      dynamic "minute_metrics" {
        for_each = var.enable_queue_minute_metrics ? [1] : []
        content {
          enabled               = true
          version               = var.queue_metrics_version
          include_apis          = var.queue_metrics_include_apis
          retention_policy_days = var.queue_metrics_retention_days
        }
      }

      dynamic "hour_metrics" {
        for_each = var.enable_queue_hour_metrics ? [1] : []
        content {
          enabled               = true
          version               = var.queue_metrics_version
          include_apis          = var.queue_metrics_include_apis
          retention_policy_days = var.queue_metrics_retention_days
        }
      }
    }
  }

  # Share properties
  dynamic "share_properties" {
    for_each = var.enable_share_properties ? [1] : []
    content {
      # CORS rules for file shares
      dynamic "cors_rule" {
        for_each = var.share_cors_rules
        content {
          allowed_headers    = cors_rule.value.allowed_headers
          allowed_methods    = cors_rule.value.allowed_methods
          allowed_origins    = cors_rule.value.allowed_origins
          exposed_headers    = cors_rule.value.exposed_headers
          max_age_in_seconds = cors_rule.value.max_age_in_seconds
        }
      }

      # Retention policy
      dynamic "retention_policy" {
        for_each = var.share_retention_days > 0 ? [1] : []
        content {
          days = var.share_retention_days
        }
      }

      # SMB settings
      dynamic "smb" {
        for_each = var.enable_smb_settings ? [1] : []
        content {
          versions                        = var.smb_versions
          authentication_types            = var.smb_authentication_types
          kerberos_ticket_encryption_type = var.smb_kerberos_ticket_encryption_type
          channel_encryption_type         = var.smb_channel_encryption_type
          multichannel_enabled            = var.smb_multichannel_enabled
        }
      }
    }
  }

  # Static website
  dynamic "static_website" {
    for_each = var.enable_static_website ? [1] : []
    content {
      index_document     = var.static_website_index_document
      error_404_document = var.static_website_error_404_document
    }
  }

  # Network rules
  dynamic "network_rules" {
    for_each = var.enable_network_rules ? [1] : []
    content {
      default_action             = var.network_rules_default_action
      bypass                     = var.network_rules_bypass
      ip_rules                   = var.network_rules_ip_rules
      virtual_network_subnet_ids = var.network_rules_subnet_ids

      # Private link access
      dynamic "private_link_access" {
        for_each = var.private_link_access_rules
        content {
          endpoint_resource_id = private_link_access.value.endpoint_resource_id
          endpoint_tenant_id   = private_link_access.value.endpoint_tenant_id
        }
      }
    }
  }

  # Customer managed key
  dynamic "customer_managed_key" {
    for_each = var.customer_managed_key_vault_key_id != null ? [1] : []
    content {
      key_vault_key_id          = var.customer_managed_key_vault_key_id
      user_assigned_identity_id = var.customer_managed_key_user_assigned_identity_id
    }
  }

  # Identity
  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  # Azure Files Authentication
  dynamic "azure_files_authentication" {
    for_each = var.enable_azure_files_authentication ? [1] : []
    content {
      directory_type = var.azure_files_authentication_directory_type

      dynamic "active_directory" {
        for_each = var.azure_files_authentication_directory_type == "AD" ? [1] : []
        content {
          storage_sid         = var.azure_files_ad_storage_sid
          domain_name         = var.azure_files_ad_domain_name
          domain_sid          = var.azure_files_ad_domain_sid
          domain_guid         = var.azure_files_ad_domain_guid
          forest_name         = var.azure_files_ad_forest_name
          netbios_domain_name = var.azure_files_ad_netbios_domain_name
        }
      }
    }
  }

  # Routing
  dynamic "routing" {
    for_each = var.enable_routing_preference ? [1] : []
    content {
      publish_internet_endpoints  = var.routing_publish_internet_endpoints
      publish_microsoft_endpoints = var.routing_publish_microsoft_endpoints
      choice                      = var.routing_choice
    }
  }

  # Immutability policy
  dynamic "immutability_policy" {
    for_each = var.enable_immutability_policy ? [1] : []
    content {
      allow_protected_append_writes = var.immutability_allow_protected_append_writes
      state                         = var.immutability_state
      period_since_creation_in_days = var.immutability_period_days
    }
  }

  tags = var.tags
}

######################################################################
# Blob Containers
# SECURITY: Public access is always set to "private" for all containers.
# This is enforced for compliance with CKV_AZURE_34 and Azure best practices.
# No user input or override is possible for public access.
######################################################################
resource "azurerm_storage_container" "main" {
  for_each = var.blob_containers

  name               = local.container_names[each.key]
  storage_account_id = azurerm_storage_account.main.id
  # Enforced for security: Only private access is allowed (CKV_AZURE_34 compliance)
  container_access_type = "private"

  metadata = each.value.metadata
}

# Container Immutability Policies
resource "azurerm_storage_container_immutability_policy" "main" {
  for_each = var.enable_container_immutability ? toset(var.immutable_containers) : toset([])

  storage_container_resource_manager_id = azurerm_storage_container.main[each.key].resource_manager_id
  immutability_period_in_days           = var.container_immutability_days
  protected_append_writes_all_enabled   = false
}

# File Shares
resource "azurerm_storage_share" "main" {
  for_each = var.file_shares

  name               = local.file_share_names[each.key]
  storage_account_id = azurerm_storage_account.main.id
  quota              = each.value.quota_gb
  enabled_protocol   = each.value.enabled_protocol
  access_tier        = each.value.access_tier

  dynamic "acl" {
    for_each = each.value.acl != null ? each.value.acl : []
    content {
      id = acl.value.id

      dynamic "access_policy" {
        for_each = acl.value.access_policy != null ? [acl.value.access_policy] : []
        content {
          permissions = access_policy.value.permissions
          start       = access_policy.value.start
          expiry      = access_policy.value.expiry
        }
      }
    }
  }

  metadata = each.value.metadata
}

# Queues
resource "azurerm_storage_queue" "main" {
  for_each = toset(var.queues)

  name                 = local.queue_names[each.key]
  storage_account_name = azurerm_storage_account.main.name

  metadata = var.queue_metadata
}

# Tables
resource "azurerm_storage_table" "main" {
  for_each = toset(var.tables)

  name                 = local.table_names[each.key]
  storage_account_name = azurerm_storage_account.main.name

  dynamic "acl" {
    for_each = var.table_acl
    content {
      id = acl.value.id

      dynamic "access_policy" {
        for_each = acl.value.access_policy != null ? [acl.value.access_policy] : []
        content {
          permissions = access_policy.value.permissions
          start       = access_policy.value.start
          expiry      = access_policy.value.expiry
        }
      }
    }
  }
}

# Management Policy (Lifecycle Management)
resource "azurerm_storage_management_policy" "main" {
  count = var.enable_lifecycle_management ? 1 : 0

  storage_account_id = azurerm_storage_account.main.id

  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      name    = rule.value.name
      enabled = rule.value.enabled

      filters {
        prefix_match = rule.value.filters.prefix_match
        blob_types   = rule.value.filters.blob_types

        dynamic "match_blob_index_tag" {
          for_each = rule.value.filters.match_blob_index_tag != null ? rule.value.filters.match_blob_index_tag : []
          content {
            name      = match_blob_index_tag.value.name
            operation = match_blob_index_tag.value.operation
            value     = match_blob_index_tag.value.value
          }
        }
      }

      actions {
        dynamic "base_blob" {
          for_each = rule.value.actions.base_blob != null ? [rule.value.actions.base_blob] : []
          content {
            tier_to_cool_after_days_since_modification_greater_than    = base_blob.value.tier_to_cool_after_days
            tier_to_archive_after_days_since_modification_greater_than = base_blob.value.tier_to_archive_after_days
            delete_after_days_since_modification_greater_than          = base_blob.value.delete_after_days
          }
        }

        dynamic "snapshot" {
          for_each = rule.value.actions.snapshot != null ? [rule.value.actions.snapshot] : []
          content {
            change_tier_to_archive_after_days_since_creation = snapshot.value.tier_to_archive_after_days
            change_tier_to_cool_after_days_since_creation    = snapshot.value.tier_to_cool_after_days
            delete_after_days_since_creation_greater_than    = snapshot.value.delete_after_days
          }
        }

        dynamic "version" {
          for_each = rule.value.actions.version != null ? [rule.value.actions.version] : []
          content {
            change_tier_to_archive_after_days_since_creation = version.value.tier_to_archive_after_days
            change_tier_to_cool_after_days_since_creation    = version.value.tier_to_cool_after_days
            delete_after_days_since_creation                 = version.value.delete_after_days
          }
        }
      }
    }
  }
}

# Private Endpoint
resource "azurerm_private_endpoint" "main" {
  for_each = var.private_endpoints

  name                = "pe-${local.storage_account_name}-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = each.value.subnet_id

  private_service_connection {
    name                           = "psc-${local.storage_account_name}-${each.key}"
    private_connection_resource_id = azurerm_storage_account.main.id
    subresource_names              = [each.value.subresource_name]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = each.value.private_dns_zone_ids != null ? [1] : []
    content {
      name                 = "pdzg-${local.storage_account_name}-${each.key}"
      private_dns_zone_ids = each.value.private_dns_zone_ids
    }
  }

  tags = var.tags
}

# Legacy Diagnostic Settings (for backwards compatibility)
resource "azurerm_monitor_diagnostic_setting" "main" {
  count = var.enable_diagnostic_settings && (var.log_analytics_workspace_id != null || var.diagnostic_storage_account_id != null || var.eventhub_authorization_rule_id != null) ? 1 : 0

  name                           = "diag-${local.storage_account_name}"
  target_resource_id             = azurerm_storage_account.main.id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  storage_account_id             = var.diagnostic_storage_account_id
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  eventhub_name                  = var.eventhub_name

  # Enable logging for Blob, Table, and Queue services (delete, read, write)
  enabled_log {
    category = "StorageRead"
  }
  enabled_log {
    category = "StorageWrite"
  }
  enabled_log {
    category = "StorageDelete"
  }
  # Metrics
  dynamic "metric" {
    for_each = var.diagnostic_metrics
    content {
      category = metric.value
      enabled  = true
    }
  }
}

# New Diagnostic Settings for individual storage services
# Blob Service Diagnostic Setting
resource "azurerm_monitor_diagnostic_setting" "blob" {
  count = var.enable_diagnostics && (var.log_analytics_workspace_id != null || var.diagnostic_storage_account_id != null || var.eventhub_authorization_rule_id != null) ? 1 : 0

  name                           = "diag-${local.storage_account_name}-blob"
  target_resource_id             = "${azurerm_storage_account.main.id}/blobServices/default"
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  storage_account_id             = var.diagnostic_storage_account_id
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  eventhub_name                  = var.eventhub_name

  enabled_log {
    category = "StorageRead"
    retention_policy {
      enabled = var.diagnostics_retention_days > 0
      days    = var.diagnostics_retention_days
    }
  }
  enabled_log {
    category = "StorageWrite"
    retention_policy {
      enabled = var.diagnostics_retention_days > 0
      days    = var.diagnostics_retention_days
    }
  }
  enabled_log {
    category = "StorageDelete"
    retention_policy {
      enabled = var.diagnostics_retention_days > 0
      days    = var.diagnostics_retention_days
    }
  }
}

# File Service Diagnostic Setting
resource "azurerm_monitor_diagnostic_setting" "file" {
  count = var.enable_diagnostics && (var.log_analytics_workspace_id != null || var.diagnostic_storage_account_id != null || var.eventhub_authorization_rule_id != null) ? 1 : 0

  name                           = "diag-${local.storage_account_name}-file"
  target_resource_id             = "${azurerm_storage_account.main.id}/fileServices/default"
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  storage_account_id             = var.diagnostic_storage_account_id
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  eventhub_name                  = var.eventhub_name

  enabled_log {
    category = "StorageRead"
    retention_policy {
      enabled = var.diagnostics_retention_days > 0
      days    = var.diagnostics_retention_days
    }
  }
  enabled_log {
    category = "StorageWrite"
    retention_policy {
      enabled = var.diagnostics_retention_days > 0
      days    = var.diagnostics_retention_days
    }
  }
  enabled_log {
    category = "StorageDelete"
    retention_policy {
      enabled = var.diagnostics_retention_days > 0
      days    = var.diagnostics_retention_days
    }
  }
}

# Queue Service Diagnostic Setting
resource "azurerm_monitor_diagnostic_setting" "queue" {
  count = var.enable_diagnostics && (var.log_analytics_workspace_id != null || var.diagnostic_storage_account_id != null || var.eventhub_authorization_rule_id != null) ? 1 : 0

  name                           = "diag-${local.storage_account_name}-queue"
  target_resource_id             = "${azurerm_storage_account.main.id}/queueServices/default"
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  storage_account_id             = var.diagnostic_storage_account_id
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  eventhub_name                  = var.eventhub_name

  enabled_log {
    category = "StorageRead"
    retention_policy {
      enabled = var.diagnostics_retention_days > 0
      days    = var.diagnostics_retention_days
    }
  }
  enabled_log {
    category = "StorageWrite"
    retention_policy {
      enabled = var.diagnostics_retention_days > 0
      days    = var.diagnostics_retention_days
    }
  }
  enabled_log {
    category = "StorageDelete"
    retention_policy {
      enabled = var.diagnostics_retention_days > 0
      days    = var.diagnostics_retention_days
    }
  }
}

# Table Service Diagnostic Setting
resource "azurerm_monitor_diagnostic_setting" "table" {
  count = var.enable_diagnostics && (var.log_analytics_workspace_id != null || var.diagnostic_storage_account_id != null || var.eventhub_authorization_rule_id != null) ? 1 : 0

  name                           = "diag-${local.storage_account_name}-table"
  target_resource_id             = "${azurerm_storage_account.main.id}/tableServices/default"
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  storage_account_id             = var.diagnostic_storage_account_id
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  eventhub_name                  = var.eventhub_name

  enabled_log {
    category = "StorageRead"
    retention_policy {
      enabled = var.diagnostics_retention_days > 0
      days    = var.diagnostics_retention_days
    }
  }
  enabled_log {
    category = "StorageWrite"
    retention_policy {
      enabled = var.diagnostics_retention_days > 0
      days    = var.diagnostics_retention_days
    }
  }
  enabled_log {
    category = "StorageDelete"
    retention_policy {
      enabled = var.diagnostics_retention_days > 0
      days    = var.diagnostics_retention_days
    }
  }
}

# SAS Token Generation and Key Vault Integration
data "azurerm_storage_account_sas" "main" {
  count = var.enable_sas_secret ? 1 : 0

  connection_string = azurerm_storage_account.main.primary_connection_string
  https_only        = var.sas_https_only
  signed_version    = "2017-07-29"

  resource_types {
    service   = contains(split("", var.sas_resource_types), "s")
    container = contains(split("", var.sas_resource_types), "c")
    object    = contains(split("", var.sas_resource_types), "o")
  }

  services {
    blob  = contains(split("", var.sas_services), "b")
    queue = contains(split("", var.sas_services), "q")
    table = contains(split("", var.sas_services), "t")
    file  = contains(split("", var.sas_services), "f")
  }

  start  = timeadd(timestamp(), "${var.start_time_offset_minutes}m")
  expiry = timeadd(timestamp(), "${var.sas_ttl_hours}h")

  permissions {
    read    = contains(split("", var.sas_permissions), "r")
    write   = contains(split("", var.sas_permissions), "w")
    delete  = contains(split("", var.sas_permissions), "d")
    list    = contains(split("", var.sas_permissions), "l")
    add     = contains(split("", var.sas_permissions), "a")
    create  = contains(split("", var.sas_permissions), "c")
    update  = contains(split("", var.sas_permissions), "u")
    process = contains(split("", var.sas_permissions), "p")
    tag     = false
    filter  = false
  }

  ip_addresses = var.sas_ip_addresses
}

# Store SAS token in Key Vault
resource "azurerm_key_vault_secret" "sas_token" {
  count = var.enable_sas_secret && var.key_vault_id != null && var.key_vault_secret_name != null ? 1 : 0

  name         = var.key_vault_secret_name
  value        = data.azurerm_storage_account_sas.main[0].sas
  key_vault_id = var.key_vault_id
  content_type = "application/x-sas-token"

  depends_on = [data.azurerm_storage_account_sas.main]
}
