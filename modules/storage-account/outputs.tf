# Storage Account Module - Outputs
# This file defines all output values from the storage account module

# Storage Account Outputs
output "storage_account_id" {
  description = "ID of the created storage account"
  value       = azurerm_storage_account.main.id
}

output "storage_account_name" {
  description = "Name of the created storage account"
  value       = azurerm_storage_account.main.name
}

output "storage_account_location" {
  description = "Location of the storage account"
  value       = azurerm_storage_account.main.location
}

output "storage_account_resource_group_name" {
  description = "Resource group name of the storage account"
  value       = azurerm_storage_account.main.resource_group_name
}

output "storage_account_tier" {
  description = "Tier of the storage account"
  value       = azurerm_storage_account.main.account_tier
}

output "storage_account_replication_type" {
  description = "Replication type of the storage account"
  value       = azurerm_storage_account.main.account_replication_type
}

output "storage_account_kind" {
  description = "Kind of the storage account"
  value       = azurerm_storage_account.main.account_kind
}

output "storage_account_access_tier" {
  description = "Access tier of the storage account"
  value       = azurerm_storage_account.main.access_tier
}

# Storage Account Endpoints
output "primary_blob_endpoint" {
  description = "Primary blob endpoint of the storage account"
  value       = azurerm_storage_account.main.primary_blob_endpoint
}

output "secondary_blob_endpoint" {
  description = "Secondary blob endpoint of the storage account"
  value       = azurerm_storage_account.main.secondary_blob_endpoint
}

output "primary_queue_endpoint" {
  description = "Primary queue endpoint of the storage account"
  value       = azurerm_storage_account.main.primary_queue_endpoint
}

output "secondary_queue_endpoint" {
  description = "Secondary queue endpoint of the storage account"
  value       = azurerm_storage_account.main.secondary_queue_endpoint
}

output "primary_table_endpoint" {
  description = "Primary table endpoint of the storage account"
  value       = azurerm_storage_account.main.primary_table_endpoint
}

output "secondary_table_endpoint" {
  description = "Secondary table endpoint of the storage account"
  value       = azurerm_storage_account.main.secondary_table_endpoint
}

output "primary_file_endpoint" {
  description = "Primary file endpoint of the storage account"
  value       = azurerm_storage_account.main.primary_file_endpoint
}

output "secondary_file_endpoint" {
  description = "Secondary file endpoint of the storage account"
  value       = azurerm_storage_account.main.secondary_file_endpoint
}

output "primary_dfs_endpoint" {
  description = "Primary DFS endpoint of the storage account (Data Lake Gen2)"
  value       = azurerm_storage_account.main.primary_dfs_endpoint
}

output "secondary_dfs_endpoint" {
  description = "Secondary DFS endpoint of the storage account (Data Lake Gen2)"
  value       = azurerm_storage_account.main.secondary_dfs_endpoint
}

output "primary_web_endpoint" {
  description = "Primary web endpoint of the storage account (Static Website)"
  value       = azurerm_storage_account.main.primary_web_endpoint
}

output "secondary_web_endpoint" {
  description = "Secondary web endpoint of the storage account (Static Website)"
  value       = azurerm_storage_account.main.secondary_web_endpoint
}

# Storage Account Keys
output "primary_access_key" {
  description = "Primary access key of the storage account"
  value       = azurerm_storage_account.main.primary_access_key
  sensitive   = true
}

output "secondary_access_key" {
  description = "Secondary access key of the storage account"
  value       = azurerm_storage_account.main.secondary_access_key
  sensitive   = true
}

output "primary_connection_string" {
  description = "Primary connection string of the storage account"
  value       = azurerm_storage_account.main.primary_connection_string
  sensitive   = true
}

output "secondary_connection_string" {
  description = "Secondary connection string of the storage account"
  value       = azurerm_storage_account.main.secondary_connection_string
  sensitive   = true
}

output "primary_blob_connection_string" {
  description = "Primary blob connection string of the storage account"
  value       = azurerm_storage_account.main.primary_blob_connection_string
  sensitive   = true
}

output "secondary_blob_connection_string" {
  description = "Secondary blob connection string of the storage account"
  value       = azurerm_storage_account.main.secondary_blob_connection_string
  sensitive   = true
}

# Identity Outputs
output "identity" {
  description = "Identity block of the storage account"
  value = var.identity_type != null ? {
    type         = azurerm_storage_account.main.identity[0].type
    principal_id = azurerm_storage_account.main.identity[0].principal_id
    tenant_id    = azurerm_storage_account.main.identity[0].tenant_id
    identity_ids = azurerm_storage_account.main.identity[0].identity_ids
  } : null
}

# Blob Container Outputs
output "blob_container_ids" {
  description = "Map of blob container names to their IDs"
  value = {
    for container_name, container in azurerm_storage_container.main : container_name => container.id
  }
}

output "blob_container_names" {
  description = "Map of blob container keys to their actual names"
  value = {
    for container_name, container in azurerm_storage_container.main : container_name => container.name
  }
}

output "blob_container_urls" {
  description = "Map of blob container names to their URLs"
  value = {
    for container_name, container in azurerm_storage_container.main : container_name => "${azurerm_storage_account.main.primary_blob_endpoint}${container.name}"
  }
}

# File Share Outputs
output "file_share_ids" {
  description = "Map of file share names to their IDs"
  value = {
    for share_name, share in azurerm_storage_share.main : share_name => share.id
  }
}

output "file_share_names" {
  description = "Map of file share keys to their actual names"
  value = {
    for share_name, share in azurerm_storage_share.main : share_name => share.name
  }
}

output "file_share_urls" {
  description = "Map of file share names to their URLs"
  value = {
    for share_name, share in azurerm_storage_share.main : share_name => share.url
  }
}

# Queue Outputs
output "queue_ids" {
  description = "Map of queue names to their IDs"
  value = {
    for queue_name, queue in azurerm_storage_queue.main : queue_name => queue.id
  }
}

output "queue_names" {
  description = "Map of queue keys to their actual names"
  value = {
    for queue_name, queue in azurerm_storage_queue.main : queue_name => queue.name
  }
}

# Table Outputs
output "table_ids" {
  description = "Map of table names to their IDs"
  value = {
    for table_name, table in azurerm_storage_table.main : table_name => table.id
  }
}

output "table_names" {
  description = "Map of table keys to their actual names"
  value = {
    for table_name, table in azurerm_storage_table.main : table_name => table.name
  }
}

# Private Endpoint Outputs
output "private_endpoint_ids" {
  description = "Map of private endpoint names to their IDs"
  value = {
    for pe_name, pe in azurerm_private_endpoint.main : pe_name => pe.id
  }
}

output "private_endpoint_ips" {
  description = "Map of private endpoint names to their private IP addresses"
  value = {
    for pe_name, pe in azurerm_private_endpoint.main : pe_name => pe.private_service_connection[0].private_ip_address
  }
}

output "private_endpoint_fqdns" {
  description = "Map of private endpoint names to their FQDNs"
  value = {
    for pe_name, pe in azurerm_private_endpoint.main : pe_name => pe.custom_dns_configs
  }
}

# Management Policy Output
output "lifecycle_management_policy_id" {
  description = "ID of the lifecycle management policy (if enabled)"
  value       = var.enable_lifecycle_management ? azurerm_storage_management_policy.main[0].id : null
}

# Diagnostic Settings Output
output "diagnostic_setting_id" {
  description = "ID of the diagnostic setting (if enabled)"
  value       = var.enable_diagnostic_settings ? azurerm_monitor_diagnostic_setting.main[0].id : null
}

# Storage Account Configuration Summary
output "storage_account_summary" {
  description = "Summary of storage account configuration"
  value = {
    name                        = azurerm_storage_account.main.name
    location                    = azurerm_storage_account.main.location
    resource_group_name         = azurerm_storage_account.main.resource_group_name
    account_tier                = azurerm_storage_account.main.account_tier
    account_replication_type    = azurerm_storage_account.main.account_replication_type
    account_kind                = azurerm_storage_account.main.account_kind
    access_tier                 = azurerm_storage_account.main.access_tier
    https_traffic_only          = azurerm_storage_account.main.https_traffic_only_enabled
    min_tls_version             = azurerm_storage_account.main.min_tls_version
    blob_containers_count       = length(azurerm_storage_container.main)
    file_shares_count           = length(azurerm_storage_share.main)
    queues_count                = length(azurerm_storage_queue.main)
    tables_count                = length(azurerm_storage_table.main)
    private_endpoints_count     = length(azurerm_private_endpoint.main)
    data_lake_gen2_enabled      = azurerm_storage_account.main.is_hns_enabled
    static_website_enabled      = var.enable_static_website
    lifecycle_mgmt_enabled      = var.enable_lifecycle_management
    diagnostic_settings_enabled = var.enable_diagnostic_settings
  }
}

# Security Configuration Summary
output "security_summary" {
  description = "Summary of storage account security configuration"
  value = {
    https_traffic_only            = azurerm_storage_account.main.https_traffic_only_enabled
    min_tls_version               = azurerm_storage_account.main.min_tls_version
    shared_access_key_enabled     = azurerm_storage_account.main.shared_access_key_enabled
    public_network_access_enabled = azurerm_storage_account.main.public_network_access_enabled
    allow_blob_public_access      = azurerm_storage_account.main.allow_nested_items_to_be_public
    infrastructure_encryption     = azurerm_storage_account.main.infrastructure_encryption_enabled
    customer_managed_key_enabled  = var.customer_managed_key_vault_key_id != null
    identity_enabled              = var.identity_type != null
    azure_files_auth_enabled      = var.enable_azure_files_authentication
    network_rules_enabled         = var.enable_network_rules
    private_endpoints_configured  = length(azurerm_private_endpoint.main) > 0
    immutability_policy_enabled   = var.enable_immutability_policy
  }
}

# Connectivity Information
output "connectivity_info" {
  description = "Information for connecting to the storage account"
  value = {
    storage_account_id   = azurerm_storage_account.main.id
    storage_account_name = azurerm_storage_account.main.name
    resource_group_name  = azurerm_storage_account.main.resource_group_name
    location             = azurerm_storage_account.main.location

    # Primary endpoints
    blob_endpoint  = azurerm_storage_account.main.primary_blob_endpoint
    queue_endpoint = azurerm_storage_account.main.primary_queue_endpoint
    table_endpoint = azurerm_storage_account.main.primary_table_endpoint
    file_endpoint  = azurerm_storage_account.main.primary_file_endpoint
    dfs_endpoint   = azurerm_storage_account.main.primary_dfs_endpoint
    web_endpoint   = azurerm_storage_account.main.primary_web_endpoint

    # Container information
    blob_containers = {
      for container_name, container in azurerm_storage_container.main : container_name => {
        name = container.name
        url  = "${azurerm_storage_account.main.primary_blob_endpoint}${container.name}"
      }
    }

    # File share information
    file_shares = {
      for share_name, share in azurerm_storage_share.main : share_name => {
        name = share.name
        url  = share.url
      }
    }

    # Private endpoint information
    private_endpoints = {
      for pe_name, pe in azurerm_private_endpoint.main : pe_name => {
        id          = pe.id
        ip_address  = pe.private_service_connection[0].private_ip_address
        subresource = pe.private_service_connection[0].subresource_names[0]
      }
    }
  }
}

# Resource Names for Reference
output "resource_names" {
  description = "Map of all created resource names for reference"
  value = {
    storage_account_name = azurerm_storage_account.main.name
    blob_container_names = {
      for container_name, container in azurerm_storage_container.main : container_name => container.name
    }
    file_share_names = {
      for share_name, share in azurerm_storage_share.main : share_name => share.name
    }
    queue_names = {
      for queue_name, queue in azurerm_storage_queue.main : queue_name => queue.name
    }
    table_names = {
      for table_name, table in azurerm_storage_table.main : table_name => table.name
    }
    private_endpoint_names = {
      for pe_name, pe in azurerm_private_endpoint.main : pe_name => pe.name
    }
    lifecycle_policy_name   = var.enable_lifecycle_management ? azurerm_storage_management_policy.main[0].id : null
    diagnostic_setting_name = var.enable_diagnostic_settings ? azurerm_monitor_diagnostic_setting.main[0].name : null
  }
}

# Integration Information for Other Modules
output "integration_info" {
  description = "Information for integrating with other modules"
  value = {
    # For App Service integration
    storage_account_name = azurerm_storage_account.main.name
    storage_account_key  = azurerm_storage_account.main.primary_access_key
    blob_endpoint        = azurerm_storage_account.main.primary_blob_endpoint

    # For Function App integration
    connection_string = azurerm_storage_account.main.primary_connection_string

    # For monitoring integration
    storage_account_id = azurerm_storage_account.main.id

    # For backup integration
    backup_container_name = length(azurerm_storage_container.main) > 0 ? values(azurerm_storage_container.main)[0].name : null

    # For private endpoint integration
    private_endpoint_subnet_requirements = var.enable_network_rules ? {
      required = true
      subnets  = var.network_rules_subnet_ids
      } : {
      required = false
      subnets  = []
    }
  }
}

# Cost Optimization Information
output "cost_optimization_info" {
  description = "Information for cost optimization"
  value = {
    account_tier             = azurerm_storage_account.main.account_tier
    account_replication_type = azurerm_storage_account.main.account_replication_type
    access_tier              = azurerm_storage_account.main.access_tier
    lifecycle_rules_count    = length(var.lifecycle_rules)
    blob_versioning_enabled  = var.enable_blob_versioning
    change_feed_enabled      = var.enable_change_feed
    last_access_tracking     = var.enable_last_access_time_tracking

    # Recommendations
    recommendations = {
      enable_lifecycle_management = !var.enable_lifecycle_management ? "Consider enabling lifecycle management to automatically tier or delete old data" : null
      optimize_replication        = azurerm_storage_account.main.account_replication_type == "GRS" ? "Consider if GRS replication is necessary for cost optimization" : null
      review_access_tier          = azurerm_storage_account.main.access_tier == "Hot" ? "Review if Cool access tier would be more cost-effective for infrequently accessed data" : null
    }
  }
}

# Compliance and Governance Information
output "compliance_info" {
  description = "Information for compliance and governance"
  value = {
    encryption_at_rest = {
      enabled                   = true
      infrastructure_encryption = azurerm_storage_account.main.infrastructure_encryption_enabled
      customer_managed_key      = var.customer_managed_key_vault_key_id != null
    }

    encryption_in_transit = {
      https_only      = azurerm_storage_account.main.https_traffic_only_enabled
      min_tls_version = azurerm_storage_account.main.min_tls_version
    }

    access_control = {
      shared_access_key_enabled = azurerm_storage_account.main.shared_access_key_enabled
      public_access_allowed     = azurerm_storage_account.main.allow_nested_items_to_be_public
      azure_ad_auth_enabled     = var.enable_azure_files_authentication
      network_restrictions      = var.enable_network_rules
    }

    data_protection = {
      blob_soft_delete_days      = var.blob_delete_retention_days
      container_soft_delete_days = var.container_delete_retention_days
      versioning_enabled         = var.enable_blob_versioning
      change_feed_enabled        = var.enable_change_feed
      immutability_policy        = var.enable_immutability_policy
    }

    monitoring = {
      diagnostic_settings       = var.enable_diagnostic_settings
      log_analytics_integration = var.log_analytics_workspace_id != null
    }

    backup_and_recovery = {
      geo_replication      = contains(["GRS", "RAGRS", "GZRS", "RAGZRS"], azurerm_storage_account.main.account_replication_type)
      cross_region_restore = contains(["RAGRS", "RAGZRS"], azurerm_storage_account.main.account_replication_type)
    }
  }
}
