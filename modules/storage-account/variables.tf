# Storage Account Module - Variables
# This file defines all input variables for the storage account module

# Required Variables
variable "resource_group_name" {
  description = "Name of the resource group where storage account will be created"
  type        = string

  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "Resource group name must not be empty."
  }
}

variable "location" {
  description = "Azure region for storage account"
  type        = string

  validation {
    condition     = length(var.location) > 0
    error_message = "Location must not be empty."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "workload" {
  description = "Workload name for resource naming"
  type        = string

  validation {
    condition     = length(var.workload) > 0 && length(var.workload) <= 10
    error_message = "Workload name must not be empty and must be 10 characters or less for storage account naming."
  }
}

variable "location_short" {
  description = "Short name for the Azure region"
  type        = string

  validation {
    condition     = length(var.location_short) > 0 && length(var.location_short) <= 6
    error_message = "Location short name must not be empty and must be 6 characters or less for storage account naming."
  }
}

variable "tags" {
  description = "Tags to apply to all storage account resources"
  type        = map(string)
  default     = {}
}

# Storage Account Configuration
variable "account_tier" {
  description = "Storage account tier (Standard or Premium)"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "Account tier must be Standard or Premium."
  }
}

variable "account_replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "Account replication type must be one of: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  }
}

variable "account_kind" {
  description = "Storage account kind"
  type        = string
  default     = "StorageV2"

  validation {
    condition     = contains(["BlobStorage", "BlockBlobStorage", "FileStorage", "Storage", "StorageV2"], var.account_kind)
    error_message = "Account kind must be one of: BlobStorage, BlockBlobStorage, FileStorage, Storage, StorageV2."
  }
}

variable "access_tier" {
  description = "Access tier for the storage account (Hot, Cool, Archive)"
  type        = string
  default     = "Hot"

  validation {
    condition     = contains(["Hot", "Cool", "Archive"], var.access_tier)
    error_message = "Access tier must be Hot, Cool, or Archive."
  }
}

# Security Configuration
variable "enable_https_traffic_only" {
  description = "Enable HTTPS traffic only"
  type        = bool
  default     = true
}

variable "min_tls_version" {
  description = "Minimum TLS version"
  type        = string
  default     = "TLS1_2"

  validation {
    condition     = contains(["TLS1_0", "TLS1_1", "TLS1_2"], var.min_tls_version)
    error_message = "Minimum TLS version must be TLS1_0, TLS1_1, or TLS1_2."
  }
}

variable "shared_access_key_enabled" {
  description = "Enable shared access key"
  type        = bool
  default     = true
}

variable "allow_blob_public_access" {
  description = "Allow blob public access"
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Enable public network access"
  type        = bool
  default     = true
}

# Advanced Features
variable "enable_data_lake_gen2" {
  description = "Enable Data Lake Gen2 (Hierarchical Namespace)"
  type        = bool
  default     = false
}

variable "enable_nfsv3" {
  description = "Enable NFSv3 protocol"
  type        = bool
  default     = false
}

variable "enable_large_file_share" {
  description = "Enable large file share"
  type        = bool
  default     = false
}

variable "enable_cross_tenant_replication" {
  description = "Enable cross-tenant replication"
  type        = bool
  default     = false
}

variable "enable_infrastructure_encryption" {
  description = "Enable infrastructure encryption"
  type        = bool
  default     = false
}

# SAS Policy
variable "sas_expiration_period" {
  description = "SAS expiration period (e.g., '1.00:00:00' for 1 day)"
  type        = string
  default     = null
}

variable "sas_expiration_action" {
  description = "SAS expiration action (Log)"
  type        = string
  default     = "Log"

  validation {
    condition     = var.sas_expiration_action == "Log"
    error_message = "SAS expiration action must be 'Log'."
  }
}

# Blob Properties
variable "enable_blob_properties" {
  description = "Enable blob properties configuration"
  type        = bool
  default     = true
}

variable "enable_blob_versioning" {
  description = "Enable blob versioning"
  type        = bool
  default     = false
}

variable "enable_change_feed" {
  description = "Enable change feed"
  type        = bool
  default     = false
}

variable "change_feed_retention_days" {
  description = "Change feed retention in days"
  type        = number
  default     = 7

  validation {
    condition     = var.change_feed_retention_days >= 1 && var.change_feed_retention_days <= 146000
    error_message = "Change feed retention days must be between 1 and 146000."
  }
}

variable "enable_last_access_time_tracking" {
  description = "Enable last access time tracking"
  type        = bool
  default     = false
}

variable "blob_delete_retention_days" {
  description = "Blob delete retention in days (0 to disable)"
  type        = number
  default     = 7

  validation {
    condition     = var.blob_delete_retention_days >= 0 && var.blob_delete_retention_days <= 365
    error_message = "Blob delete retention days must be between 0 and 365."
  }
}

variable "container_delete_retention_days" {
  description = "Container delete retention in days (0 to disable)"
  type        = number
  default     = 7

  validation {
    condition     = var.container_delete_retention_days >= 0 && var.container_delete_retention_days <= 365
    error_message = "Container delete retention days must be between 0 and 365."
  }
}

# CORS Rules
variable "cors_rules" {
  description = "CORS rules for blob service"
  type = list(object({
    allowed_headers    = list(string)
    allowed_methods    = list(string)
    allowed_origins    = list(string)
    exposed_headers    = list(string)
    max_age_in_seconds = number
  }))
  default = []
}

# Queue Properties
variable "enable_queue_properties" {
  description = "Enable queue properties configuration"
  type        = bool
  default     = false
}

variable "queue_cors_rules" {
  description = "CORS rules for queue service"
  type = list(object({
    allowed_headers    = list(string)
    allowed_methods    = list(string)
    allowed_origins    = list(string)
    exposed_headers    = list(string)
    max_age_in_seconds = number
  }))
  default = []
}

variable "enable_queue_logging" {
  description = "Enable queue logging"
  type        = bool
  default     = false
}

variable "queue_logging_delete" {
  description = "Log delete operations for queues"
  type        = bool
  default     = false
}

variable "queue_logging_read" {
  description = "Log read operations for queues"
  type        = bool
  default     = false
}

variable "queue_logging_write" {
  description = "Log write operations for queues"
  type        = bool
  default     = false
}

variable "queue_logging_version" {
  description = "Queue logging version"
  type        = string
  default     = "1.0"
}

variable "queue_logging_retention_days" {
  description = "Queue logging retention in days"
  type        = number
  default     = 7

  validation {
    condition     = var.queue_logging_retention_days >= 1 && var.queue_logging_retention_days <= 365
    error_message = "Queue logging retention days must be between 1 and 365."
  }
}

variable "enable_queue_minute_metrics" {
  description = "Enable queue minute metrics"
  type        = bool
  default     = false
}

variable "enable_queue_hour_metrics" {
  description = "Enable queue hour metrics"
  type        = bool
  default     = false
}

variable "queue_metrics_version" {
  description = "Queue metrics version"
  type        = string
  default     = "1.0"
}

variable "queue_metrics_include_apis" {
  description = "Include APIs in queue metrics"
  type        = bool
  default     = false
}

variable "queue_metrics_retention_days" {
  description = "Queue metrics retention in days"
  type        = number
  default     = 7

  validation {
    condition     = var.queue_metrics_retention_days >= 1 && var.queue_metrics_retention_days <= 365
    error_message = "Queue metrics retention days must be between 1 and 365."
  }
}

# Share Properties
variable "enable_share_properties" {
  description = "Enable share properties configuration"
  type        = bool
  default     = false
}

variable "share_cors_rules" {
  description = "CORS rules for file share service"
  type = list(object({
    allowed_headers    = list(string)
    allowed_methods    = list(string)
    allowed_origins    = list(string)
    exposed_headers    = list(string)
    max_age_in_seconds = number
  }))
  default = []
}

variable "share_retention_days" {
  description = "File share retention in days (0 to disable)"
  type        = number
  default     = 0

  validation {
    condition     = var.share_retention_days >= 0 && var.share_retention_days <= 365
    error_message = "Share retention days must be between 0 and 365."
  }
}

variable "enable_smb_settings" {
  description = "Enable SMB settings configuration"
  type        = bool
  default     = false
}

variable "smb_versions" {
  description = "SMB protocol versions"
  type        = list(string)
  default     = ["SMB2.1", "SMB3.0", "SMB3.1.1"]
}

variable "smb_authentication_types" {
  description = "SMB authentication types"
  type        = list(string)
  default     = ["NTLMv2", "Kerberos"]
}

variable "smb_kerberos_ticket_encryption_type" {
  description = "SMB Kerberos ticket encryption type"
  type        = list(string)
  default     = ["RC4-HMAC", "AES-256"]
}

variable "smb_channel_encryption_type" {
  description = "SMB channel encryption type"
  type        = list(string)
  default     = ["AES-128-CCM", "AES-128-GCM", "AES-256-GCM"]
}

variable "smb_multichannel_enabled" {
  description = "Enable SMB multichannel"
  type        = bool
  default     = false
}

# Static Website
variable "enable_static_website" {
  description = "Enable static website hosting"
  type        = bool
  default     = false
}

variable "static_website_index_document" {
  description = "Index document for static website"
  type        = string
  default     = "index.html"
}

variable "static_website_error_404_document" {
  description = "Error 404 document for static website"
  type        = string
  default     = "404.html"
}

# Network Rules
variable "enable_network_rules" {
  description = "Enable network rules"
  type        = bool
  default     = false
}

variable "network_rules_default_action" {
  description = "Default action for network rules"
  type        = string
  default     = "Allow"

  validation {
    condition     = contains(["Allow", "Deny"], var.network_rules_default_action)
    error_message = "Network rules default action must be Allow or Deny."
  }
}

variable "network_rules_bypass" {
  description = "Bypass network rules for Azure services"
  type        = list(string)
  default     = ["AzureServices"]

  validation {
    condition = alltrue([
      for bypass in var.network_rules_bypass : contains(["Logging", "Metrics", "AzureServices", "None"], bypass)
    ])
    error_message = "Network rules bypass must contain only: Logging, Metrics, AzureServices, None."
  }
}

variable "network_rules_ip_rules" {
  description = "IP rules for network access"
  type        = list(string)
  default     = []
}

variable "network_rules_subnet_ids" {
  description = "Subnet IDs for network access"
  type        = list(string)
  default     = []
}

variable "private_link_access_rules" {
  description = "Private link access rules"
  type = list(object({
    endpoint_resource_id = string
    endpoint_tenant_id   = string
  }))
  default = []
}

# Customer Managed Key
variable "customer_managed_key_vault_key_id" {
  description = "Key Vault key ID for customer managed key"
  type        = string
  default     = null
}

variable "customer_managed_key_user_assigned_identity_id" {
  description = "User assigned identity ID for customer managed key"
  type        = string
  default     = null
}

# Identity
variable "identity_type" {
  description = "Type of managed identity"
  type        = string
  default     = null

  validation {
    condition     = var.identity_type == null || contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type)
    error_message = "Identity type must be SystemAssigned, UserAssigned, or 'SystemAssigned, UserAssigned'."
  }
}

variable "identity_ids" {
  description = "List of user assigned identity IDs"
  type        = list(string)
  default     = []
}

# Azure Files Authentication
variable "enable_azure_files_authentication" {
  description = "Enable Azure Files authentication"
  type        = bool
  default     = false
}

variable "azure_files_authentication_directory_type" {
  description = "Directory type for Azure Files authentication"
  type        = string
  default     = "AADDS"

  validation {
    condition     = contains(["AADDS", "AD", "AADKERB"], var.azure_files_authentication_directory_type)
    error_message = "Azure Files authentication directory type must be AADDS, AD, or AADKERB."
  }
}

variable "azure_files_ad_storage_sid" {
  description = "Storage SID for Active Directory authentication"
  type        = string
  default     = null
}

variable "azure_files_ad_domain_name" {
  description = "Domain name for Active Directory authentication"
  type        = string
  default     = null
}

variable "azure_files_ad_domain_sid" {
  description = "Domain SID for Active Directory authentication"
  type        = string
  default     = null
}

variable "azure_files_ad_domain_guid" {
  description = "Domain GUID for Active Directory authentication"
  type        = string
  default     = null
}

variable "azure_files_ad_forest_name" {
  description = "Forest name for Active Directory authentication"
  type        = string
  default     = null
}

variable "azure_files_ad_netbios_domain_name" {
  description = "NetBIOS domain name for Active Directory authentication"
  type        = string
  default     = null
}

# Routing
variable "enable_routing_preference" {
  description = "Enable routing preference"
  type        = bool
  default     = false
}

variable "routing_publish_internet_endpoints" {
  description = "Publish internet endpoints"
  type        = bool
  default     = false
}

variable "routing_publish_microsoft_endpoints" {
  description = "Publish Microsoft endpoints"
  type        = bool
  default     = false
}

variable "routing_choice" {
  description = "Routing choice"
  type        = string
  default     = "MicrosoftRouting"

  validation {
    condition     = contains(["MicrosoftRouting", "InternetRouting"], var.routing_choice)
    error_message = "Routing choice must be MicrosoftRouting or InternetRouting."
  }
}

# Immutability Policy
variable "enable_immutability_policy" {
  description = "Enable immutability policy"
  type        = bool
  default     = false
}

variable "immutability_allow_protected_append_writes" {
  description = "Allow protected append writes in immutability policy"
  type        = bool
  default     = false
}

variable "immutability_state" {
  description = "Immutability policy state"
  type        = string
  default     = "Unlocked"

  validation {
    condition     = contains(["Locked", "Unlocked"], var.immutability_state)
    error_message = "Immutability state must be Locked or Unlocked."
  }
}

variable "immutability_period_days" {
  description = "Immutability period in days"
  type        = number
  default     = 7

  validation {
    condition     = var.immutability_period_days >= 1 && var.immutability_period_days <= 146000
    error_message = "Immutability period days must be between 1 and 146000."
  }
}

# Blob Containers
variable "blob_containers" {
  description = "Map of blob containers to create"
  type = map(object({
    access_type = optional(string, "private")
    metadata    = optional(map(string), null)
  }))
  default = {}

  validation {
    condition = alltrue([
      for container in var.blob_containers : contains(["blob", "container", "private"], container.access_type)
    ])
    error_message = "Container access type must be blob, container, or private."
  }
}

# File Shares
variable "file_shares" {
  description = "Map of file shares to create"
  type = map(object({
    quota_gb         = number
    enabled_protocol = optional(string, "SMB")
    access_tier      = optional(string, "TransactionOptimized")
    metadata         = optional(map(string), null)
    acl = optional(list(object({
      id = string
      access_policy = optional(object({
        permissions = string
        start       = string
        expiry      = string
      }), null)
    })), null)
  }))
  default = {}

  validation {
    condition = alltrue([
      for share in var.file_shares : contains(["SMB", "NFS"], share.enabled_protocol)
    ])
    error_message = "File share enabled protocol must be SMB or NFS."
  }

  validation {
    condition = alltrue([
      for share in var.file_shares : contains(["TransactionOptimized", "Hot", "Cool"], share.access_tier)
    ])
    error_message = "File share access tier must be TransactionOptimized, Hot, or Cool."
  }
}

# Queues
variable "queues" {
  description = "List of queue names to create"
  type        = list(string)
  default     = []
}

variable "queue_metadata" {
  description = "Metadata for queues"
  type        = map(string)
  default     = {}
}

# Tables
variable "tables" {
  description = "List of table names to create"
  type        = list(string)
  default     = []
}

variable "table_acl" {
  description = "ACL for tables"
  type = list(object({
    id = string
    access_policy = optional(object({
      permissions = string
      start       = string
      expiry      = string
    }), null)
  }))
  default = []
}

# Lifecycle Management
variable "enable_lifecycle_management" {
  description = "Enable lifecycle management"
  type        = bool
  default     = false
}

variable "lifecycle_rules" {
  description = "Lifecycle management rules"
  type = list(object({
    name    = string
    enabled = bool
    filters = object({
      prefix_match = list(string)
      blob_types   = list(string)
      match_blob_index_tag = optional(list(object({
        name      = string
        operation = string
        value     = string
      })), null)
    })
    actions = object({
      base_blob = optional(object({
        tier_to_cool_after_days    = optional(number, null)
        tier_to_archive_after_days = optional(number, null)
        delete_after_days          = optional(number, null)
      }), null)
      snapshot = optional(object({
        tier_to_cool_after_days    = optional(number, null)
        tier_to_archive_after_days = optional(number, null)
        delete_after_days          = optional(number, null)
      }), null)
      version = optional(object({
        tier_to_cool_after_days    = optional(number, null)
        tier_to_archive_after_days = optional(number, null)
        delete_after_days          = optional(number, null)
      }), null)
    })
  }))
  default = []
}

# Private Endpoints
variable "private_endpoints" {
  description = "Map of private endpoints to create"
  type = map(object({
    subnet_id            = string
    subresource_name     = string
    private_dns_zone_ids = optional(list(string), null)
  }))
  default = {}

  validation {
    condition = alltrue([
      for pe in var.private_endpoints : contains([
        "blob", "blob_secondary", "file", "file_secondary", "queue", "queue_secondary",
        "table", "table_secondary", "web", "web_secondary", "dfs", "dfs_secondary"
      ], pe.subresource_name)
    ])
    error_message = "Private endpoint subresource name must be one of: blob, blob_secondary, file, file_secondary, queue, queue_secondary, table, table_secondary, web, web_secondary, dfs, dfs_secondary."
  }
}

# Diagnostic Settings
variable "enable_diagnostic_settings" {
  description = "Enable diagnostic settings"
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostic settings"
  type        = string
  default     = null
}

variable "diagnostic_storage_account_id" {
  description = "Storage account ID for diagnostic settings"
  type        = string
  default     = null
}

variable "eventhub_authorization_rule_id" {
  description = "Event Hub authorization rule ID for diagnostic settings"
  type        = string
  default     = null
}

variable "eventhub_name" {
  description = "Event Hub name for diagnostic settings"
  type        = string
  default     = null
}

variable "diagnostic_logs" {
  description = "List of diagnostic log categories to enable"
  type        = list(string)
  default     = ["StorageRead", "StorageWrite", "StorageDelete"]
}

variable "diagnostic_metrics" {
  description = "List of diagnostic metric categories to enable"
  type        = list(string)
  default     = ["Transaction"]
}
