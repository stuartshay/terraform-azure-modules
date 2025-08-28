# Azure Function App Module - Variables
# This file defines all input variables for the Azure Function App module

#######################
# Required Variables
#######################

variable "workload" {
  description = "The workload name"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{2,10}$", var.workload))
    error_message = "Workload must be 2-10 characters, lowercase letters and numbers only."
  }
}

variable "environment" {
  description = "The environment name"
  type        = string

  validation {
    condition     = contains(["dev", "test", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, staging, prod."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region"
  type        = string

  validation {
    condition = contains([
      "East US", "East US 2", "West US", "West US 2", "West US 3", "Central US",
      "North Central US", "South Central US", "West Central US", "Canada Central",
      "Canada East", "Brazil South", "North Europe", "West Europe", "UK South",
      "UK West", "France Central", "France South", "Germany West Central",
      "Germany North", "Norway East", "Norway West", "Switzerland North",
      "Switzerland West", "Sweden Central", "Sweden South", "Poland Central",
      "Italy North", "Spain Central", "Israel Central", "UAE North", "UAE Central",
      "South Africa North", "South Africa West", "Australia East", "Australia Southeast",
      "Australia Central", "Australia Central 2", "East Asia", "Southeast Asia",
      "Japan East", "Japan West", "Korea Central", "Korea South", "Central India",
      "South India", "West India", "Jio India West", "Jio India Central"
    ], var.location)
    error_message = "Location must be a valid Azure region."
  }
}

variable "service_plan_id" {
  description = "The ID of the App Service Plan to use for the Function App"
  type        = string
}

#######################
# Function App Configuration
#######################

variable "os_type" {
  description = "The operating system type for the Function App (Linux or Windows)"
  type        = string
  default     = "Linux"

  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "OS type must be either 'Linux' or 'Windows'."
  }
}

variable "runtime_name" {
  description = "The runtime name for the Function App"
  type        = string
  default     = "python"

  validation {
    condition     = contains(["python", "node", "dotnet", "java", "powershell", "custom"], var.runtime_name)
    error_message = "Runtime name must be one of: python, node, dotnet, java, powershell, custom."
  }
}

variable "runtime_version" {
  description = "The runtime version for the Function App"
  type        = string
  default     = "3.11"

  validation {
    condition     = can(regex("^[0-9]+(\\.[0-9]+)*$", var.runtime_version))
    error_message = "Runtime version must be a valid version number (e.g., 3.11, 18, 6.0)."
  }
}

variable "functions_extension_version" {
  description = "The version of the Azure Functions runtime"
  type        = string
  default     = "~4"

  validation {
    condition     = contains(["~3", "~4"], var.functions_extension_version)
    error_message = "Functions extension version must be ~3 or ~4."
  }
}

variable "use_dotnet_isolated_runtime" {
  description = "Whether to use .NET isolated runtime"
  type        = bool
  default     = false
}

#######################
# Security Configuration
#######################

variable "https_only" {
  description = "Whether the Function App should only accept HTTPS requests"
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled for the Function App"
  type        = bool
  default     = true
}

variable "client_certificate_enabled" {
  description = "Whether client certificates are enabled"
  type        = bool
  default     = false
}

variable "client_certificate_mode" {
  description = "The client certificate mode"
  type        = string
  default     = "Optional"

  validation {
    condition     = contains(["Required", "Optional"], var.client_certificate_mode)
    error_message = "Client certificate mode must be 'Required' or 'Optional'."
  }
}

variable "key_vault_reference_identity_id" {
  description = "The identity ID to use for Key Vault references"
  type        = string
  default     = null
}

variable "minimum_tls_version" {
  description = "The minimum TLS version for the Function App"
  type        = string
  default     = "1.2"

  validation {
    condition     = contains(["1.0", "1.1", "1.2"], var.minimum_tls_version)
    error_message = "Minimum TLS version must be 1.0, 1.1, or 1.2."
  }
}

variable "scm_minimum_tls_version" {
  description = "The minimum TLS version for SCM"
  type        = string
  default     = "1.2"

  validation {
    condition     = contains(["1.0", "1.1", "1.2"], var.scm_minimum_tls_version)
    error_message = "SCM minimum TLS version must be 1.0, 1.1, or 1.2."
  }
}

variable "scm_use_main_ip_restriction" {
  description = "Whether SCM should use the main IP restrictions"
  type        = bool
  default     = false
}

variable "ftps_state" {
  description = "The FTPS state"
  type        = string
  default     = "Disabled"

  validation {
    condition     = contains(["AllAllowed", "FtpsOnly", "Disabled"], var.ftps_state)
    error_message = "FTPS state must be 'AllAllowed', 'FtpsOnly', or 'Disabled'."
  }
}

#######################
# Performance Configuration
#######################

variable "always_on" {
  description = "Whether the Function App should always be on (not applicable for Consumption plan)"
  type        = bool
  default     = true
}

variable "pre_warmed_instance_count" {
  description = "The number of pre-warmed instances for Premium plans"
  type        = number
  default     = 1

  validation {
    condition     = var.pre_warmed_instance_count >= 0 && var.pre_warmed_instance_count <= 20
    error_message = "Pre-warmed instance count must be between 0 and 20."
  }
}

variable "elastic_instance_minimum" {
  description = "The minimum number of elastic instances for Premium plans"
  type        = number
  default     = 1

  validation {
    condition     = var.elastic_instance_minimum >= 0 && var.elastic_instance_minimum <= 20
    error_message = "Elastic instance minimum must be between 0 and 20."
  }
}

variable "function_app_scale_limit" {
  description = "The maximum number of instances for the Function App"
  type        = number
  default     = 200

  validation {
    condition     = var.function_app_scale_limit >= 1 && var.function_app_scale_limit <= 1000
    error_message = "Function app scale limit must be between 1 and 1000."
  }
}

variable "worker_count" {
  description = "The number of workers for the Function App"
  type        = number
  default     = 1

  validation {
    condition     = var.worker_count >= 1 && var.worker_count <= 10
    error_message = "Worker count must be between 1 and 10."
  }
}

variable "use_32_bit_worker" {
  description = "Whether to use 32-bit worker process"
  type        = bool
  default     = false
}

#######################
# Health Check Configuration
#######################

variable "health_check_path" {
  description = "The health check path for the Function App"
  type        = string
  default     = null
}

variable "health_check_eviction_time_in_min" {
  description = "The time in minutes after which an instance is evicted if health check fails"
  type        = number
  default     = 10

  validation {
    condition     = var.health_check_eviction_time_in_min >= 2 && var.health_check_eviction_time_in_min <= 10
    error_message = "Health check eviction time must be between 2 and 10 minutes."
  }
}

#######################
# Network Configuration
#######################

variable "enable_vnet_integration" {
  description = "Whether to enable VNet integration for the Function App"
  type        = bool
  default     = false
}

variable "vnet_integration_subnet_id" {
  description = "The subnet ID for VNet integration"
  type        = string
  default     = null
}

variable "websockets_enabled" {
  description = "Whether WebSockets are enabled"
  type        = bool
  default     = false
}

variable "remote_debugging_enabled" {
  description = "Whether remote debugging is enabled"
  type        = bool
  default     = false
}

variable "remote_debugging_version" {
  description = "The remote debugging version"
  type        = string
  default     = "VS2019"

  validation {
    condition     = contains(["VS2017", "VS2019", "VS2022"], var.remote_debugging_version)
    error_message = "Remote debugging version must be VS2017, VS2019, or VS2022."
  }
}

#######################
# CORS Configuration
#######################

variable "enable_cors" {
  description = "Whether to enable CORS"
  type        = bool
  default     = false
}

variable "cors_allowed_origins" {
  description = "The allowed origins for CORS"
  type        = list(string)
  default     = []
}

variable "cors_support_credentials" {
  description = "Whether CORS should support credentials"
  type        = bool
  default     = false
}

#######################
# IP Restrictions
#######################

variable "ip_restrictions" {
  description = "List of IP restrictions for the Function App"
  type = list(object({
    ip_address                = optional(string)
    service_tag               = optional(string)
    virtual_network_subnet_id = optional(string)
    name                      = string
    priority                  = number
    action                    = string
    headers = optional(object({
      x_azure_fdid      = optional(list(string))
      x_fd_health_probe = optional(list(string))
      x_forwarded_for   = optional(list(string))
      x_forwarded_host  = optional(list(string))
    }))
  }))
  default = []

  validation {
    condition = alltrue([
      for restriction in var.ip_restrictions :
      restriction.priority >= 1 && restriction.priority <= 2147483647
    ])
    error_message = "IP restriction priority must be between 1 and 2147483647."
  }

  validation {
    condition = alltrue([
      for restriction in var.ip_restrictions :
      contains(["Allow", "Deny"], restriction.action)
    ])
    error_message = "IP restriction action must be 'Allow' or 'Deny'."
  }
}

variable "scm_ip_restrictions" {
  description = "List of SCM IP restrictions for the Function App"
  type = list(object({
    ip_address                = optional(string)
    service_tag               = optional(string)
    virtual_network_subnet_id = optional(string)
    name                      = string
    priority                  = number
    action                    = string
    headers = optional(object({
      x_azure_fdid      = optional(list(string))
      x_fd_health_probe = optional(list(string))
      x_forwarded_for   = optional(list(string))
      x_forwarded_host  = optional(list(string))
    }))
  }))
  default = []

  validation {
    condition = alltrue([
      for restriction in var.scm_ip_restrictions :
      restriction.priority >= 1 && restriction.priority <= 2147483647
    ])
    error_message = "SCM IP restriction priority must be between 1 and 2147483647."
  }

  validation {
    condition = alltrue([
      for restriction in var.scm_ip_restrictions :
      contains(["Allow", "Deny"], restriction.action)
    ])
    error_message = "SCM IP restriction action must be 'Allow' or 'Deny'."
  }
}

#######################
# App Settings and Configuration
#######################

variable "app_settings" {
  description = "Additional app settings for the Function App"
  type        = map(string)
  default     = {}
}

variable "run_from_package" {
  description = "Whether to run the Function App from a package"
  type        = bool
  default     = true
}

variable "connection_strings" {
  description = "Connection strings for the Function App"
  type = list(object({
    name  = string
    type  = string
    value = string
  }))
  default = []

  validation {
    condition = alltrue([
      for conn in var.connection_strings :
      contains(["APIHub", "Custom", "DocDb", "EventHub", "MySQL", "NotificationHub", "PostgreSQL", "RedisCache", "ServiceBus", "SQLAzure", "SQLServer"], conn.type)
    ])
    error_message = "Connection string type must be one of the supported types."
  }
}

#######################
# Identity Configuration
#######################

variable "identity_type" {
  description = "The type of managed identity for the Function App"
  type        = string
  default     = "SystemAssigned"

  validation {
    condition     = var.identity_type == null || contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type)
    error_message = "Identity type must be 'SystemAssigned', 'UserAssigned', or 'SystemAssigned, UserAssigned'."
  }
}

variable "identity_ids" {
  description = "List of user assigned identity IDs"
  type        = list(string)
  default     = []
}

#######################
# Storage Account Configuration
#######################

variable "storage_account_tier" {
  description = "The tier of the storage account"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "Storage account tier must be 'Standard' or 'Premium'."
  }
}

variable "storage_account_replication_type" {
  description = "The replication type of the storage account"
  type        = string
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.storage_account_replication_type)
    error_message = "Storage account replication type must be one of: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  }
}

variable "storage_min_tls_version" {
  description = "The minimum TLS version for the storage account"
  type        = string
  default     = "TLS1_2"

  validation {
    condition     = contains(["TLS1_0", "TLS1_1", "TLS1_2"], var.storage_min_tls_version)
    error_message = "Storage minimum TLS version must be TLS1_0, TLS1_1, or TLS1_2."
  }
}


variable "storage_blob_delete_retention_days" {
  description = "The number of days to retain deleted blobs"
  type        = number
  default     = 7

  validation {
    condition     = var.storage_blob_delete_retention_days >= 1 && var.storage_blob_delete_retention_days <= 365
    error_message = "Storage blob delete retention days must be between 1 and 365."
  }
}

variable "storage_container_delete_retention_days" {
  description = "The number of days to retain deleted containers"
  type        = number
  default     = 7

  validation {
    condition     = var.storage_container_delete_retention_days >= 1 && var.storage_container_delete_retention_days <= 365
    error_message = "Storage container delete retention days must be between 1 and 365."
  }
}

variable "storage_sas_expiration_period" {
  description = "The SAS expiration period for the storage account"
  type        = string
  default     = "01.00:00:00"
}

variable "storage_sas_expiration_action" {
  description = "The action to take when SAS expires"
  type        = string
  default     = "Log"

  validation {
    condition     = contains(["Log"], var.storage_sas_expiration_action)
    error_message = "Storage SAS expiration action must be 'Log'."
  }
}

variable "enable_storage_network_rules" {
  description = "Whether to enable network rules for the storage account"
  type        = bool
  default     = false
}

variable "storage_network_rules_default_action" {
  description = "The default action for storage network rules"
  type        = string
  default     = "Allow"

  validation {
    condition     = contains(["Allow", "Deny"], var.storage_network_rules_default_action)
    error_message = "Storage network rules default action must be 'Allow' or 'Deny'."
  }
}

variable "storage_network_rules_bypass" {
  description = "The bypass rules for storage network rules"
  type        = list(string)
  default     = ["AzureServices"]

  validation {
    condition = alltrue([
      for bypass in var.storage_network_rules_bypass :
      contains(["Logging", "Metrics", "AzureServices", "None"], bypass)
    ])
    error_message = "Storage network rules bypass must contain valid values: Logging, Metrics, AzureServices, None."
  }
}

variable "storage_network_rules_ip_rules" {
  description = "The IP rules for storage network rules"
  type        = list(string)
  default     = []
}

variable "storage_network_rules_subnet_ids" {
  description = "The subnet IDs for storage network rules"
  type        = list(string)
  default     = []
}

#######################
# Application Insights Configuration
#######################

variable "enable_application_insights" {
  description = "Whether to enable Application Insights"
  type        = bool
  default     = true
}

variable "application_insights_type" {
  description = "The type of Application Insights"
  type        = string
  default     = "web"

  validation {
    condition     = contains(["web", "other"], var.application_insights_type)
    error_message = "Application Insights type must be 'web' or 'other'."
  }
}

variable "application_insights_retention_days" {
  description = "The retention period in days for Application Insights"
  type        = number
  default     = 90

  validation {
    condition     = contains([30, 60, 90, 120, 180, 270, 365, 550, 730], var.application_insights_retention_days)
    error_message = "Application Insights retention days must be one of: 30, 60, 90, 120, 180, 270, 365, 550, 730."
  }
}

variable "application_insights_sampling_percentage" {
  description = "The sampling percentage for Application Insights"
  type        = number
  default     = 100

  validation {
    condition     = var.application_insights_sampling_percentage >= 0 && var.application_insights_sampling_percentage <= 100
    error_message = "Application Insights sampling percentage must be between 0 and 100."
  }
}

variable "application_insights_disable_ip_masking" {
  description = "Whether to disable IP masking in Application Insights"
  type        = bool
  default     = false
}

variable "application_insights_local_auth_disabled" {
  description = "Whether local authentication is disabled for Application Insights"
  type        = bool
  default     = true
}

variable "application_insights_internet_ingestion_enabled" {
  description = "Whether internet ingestion is enabled for Application Insights"
  type        = bool
  default     = true
}

variable "application_insights_internet_query_enabled" {
  description = "Whether internet query is enabled for Application Insights"
  type        = bool
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "The Log Analytics workspace ID for Application Insights"
  type        = string
  default     = null
}

#######################
# Deployment Slots Configuration
#######################

variable "deployment_slots" {
  description = "Map of deployment slots to create"
  type = map(object({
    public_network_access_enabled = optional(bool, true)
    app_settings                  = optional(map(string), {})
  }))
  default = {}
}

variable "sticky_app_setting_names" {
  description = "List of app setting names that should be sticky to deployment slots"
  type        = list(string)
  default     = []
}

variable "sticky_connection_string_names" {
  description = "List of connection string names that should be sticky to deployment slots"
  type        = list(string)
  default     = []
}

#######################
# Authentication Configuration
#######################

variable "enable_auth_settings" {
  description = "Whether to enable authentication settings"
  type        = bool
  default     = false
}

variable "auth_settings_default_provider" {
  description = "The default authentication provider"
  type        = string
  default     = "AzureActiveDirectory"

  validation {
    condition     = contains(["AzureActiveDirectory", "Facebook", "Google", "MicrosoftAccount", "Twitter"], var.auth_settings_default_provider)
    error_message = "Auth settings default provider must be one of the supported providers."
  }
}

variable "auth_settings_unauthenticated_client_action" {
  description = "The action to take for unauthenticated clients"
  type        = string
  default     = "RedirectToLoginPage"

  validation {
    condition     = contains(["RedirectToLoginPage", "AllowAnonymous"], var.auth_settings_unauthenticated_client_action)
    error_message = "Auth settings unauthenticated client action must be 'RedirectToLoginPage' or 'AllowAnonymous'."
  }
}

variable "auth_settings_token_store_enabled" {
  description = "Whether token store is enabled"
  type        = bool
  default     = false
}

variable "auth_settings_token_refresh_extension_hours" {
  description = "The token refresh extension hours"
  type        = number
  default     = 72

  validation {
    condition     = var.auth_settings_token_refresh_extension_hours >= 0 && var.auth_settings_token_refresh_extension_hours <= 999999
    error_message = "Auth settings token refresh extension hours must be between 0 and 999999."
  }
}

variable "auth_settings_issuer" {
  description = "The issuer URL for authentication"
  type        = string
  default     = null
}

variable "auth_settings_runtime_version" {
  description = "The runtime version for authentication"
  type        = string
  default     = "~1"
}

variable "auth_settings_additional_login_parameters" {
  description = "Additional login parameters"
  type        = map(string)
  default     = {}
}

variable "auth_settings_allowed_external_redirect_urls" {
  description = "List of allowed external redirect URLs"
  type        = list(string)
  default     = []
}

variable "auth_settings_active_directory" {
  description = "Active Directory authentication settings"
  type = object({
    client_id         = string
    client_secret     = string
    allowed_audiences = optional(list(string), [])
  })
  default = null
}

variable "auth_settings_facebook" {
  description = "Facebook authentication settings"
  type = object({
    app_id       = string
    app_secret   = string
    oauth_scopes = optional(list(string), [])
  })
  default = null
}

variable "auth_settings_google" {
  description = "Google authentication settings"
  type = object({
    client_id     = string
    client_secret = string
    oauth_scopes  = optional(list(string), [])
  })
  default = null
}

variable "auth_settings_microsoft" {
  description = "Microsoft authentication settings"
  type = object({
    client_id     = string
    client_secret = string
    oauth_scopes  = optional(list(string), [])
  })
  default = null
}

variable "auth_settings_twitter" {
  description = "Twitter authentication settings"
  type = object({
    consumer_key    = string
    consumer_secret = string
  })
  default = null
}

#######################
# Backup Configuration
#######################

variable "enable_backup" {
  description = "Whether to enable backup for the Function App"
  type        = bool
  default     = false
}

variable "backup_name" {
  description = "The name of the backup"
  type        = string
  default     = "DefaultBackup"
}

variable "backup_storage_account_url" {
  description = "The storage account URL for backups"
  type        = string
  default     = null
}

variable "backup_schedule_frequency_interval" {
  description = "The frequency interval for backup schedule"
  type        = number
  default     = 1

  validation {
    condition     = var.backup_schedule_frequency_interval >= 1 && var.backup_schedule_frequency_interval <= 1000
    error_message = "Backup schedule frequency interval must be between 1 and 1000."
  }
}

variable "backup_schedule_frequency_unit" {
  description = "The frequency unit for backup schedule"
  type        = string
  default     = "Day"

  validation {
    condition     = contains(["Day", "Hour"], var.backup_schedule_frequency_unit)
    error_message = "Backup schedule frequency unit must be 'Day' or 'Hour'."
  }
}

variable "backup_schedule_keep_at_least_one_backup" {
  description = "Whether to keep at least one backup"
  type        = bool
  default     = true
}

variable "backup_schedule_retention_period_days" {
  description = "The retention period in days for backups"
  type        = number
  default     = 30

  validation {
    condition     = var.backup_schedule_retention_period_days >= 1 && var.backup_schedule_retention_period_days <= 9999999
    error_message = "Backup schedule retention period days must be between 1 and 9999999."
  }
}

variable "backup_schedule_start_time" {
  description = "The start time for backup schedule (ISO 8601 format)"
  type        = string
  default     = null
}

#######################
# Diagnostic Settings
#######################

variable "enable_diagnostic_settings" {
  description = "Whether to enable diagnostic settings"
  type        = bool
  default     = false
}

variable "diagnostic_storage_account_id" {
  description = "The storage account ID for diagnostic settings"
  type        = string
  default     = null
}

variable "eventhub_authorization_rule_id" {
  description = "The Event Hub authorization rule ID for diagnostic settings"
  type        = string
  default     = null
}

variable "eventhub_name" {
  description = "The Event Hub name for diagnostic settings"
  type        = string
  default     = null
}

variable "diagnostic_metrics" {
  description = "List of metrics to enable for diagnostic settings"
  type        = list(string)
  default     = ["AllMetrics"]

  validation {
    condition = alltrue([
      for metric in var.diagnostic_metrics :
      contains(["AllMetrics"], metric)
    ])
    error_message = "Diagnostic metrics must contain valid metric categories."
  }
}

#######################
# Tags
#######################

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
