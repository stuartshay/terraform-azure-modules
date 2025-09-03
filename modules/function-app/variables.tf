variable "app_settings" {
  description = "Additional app settings for the Function App."
  type        = map(string)
  default     = {}
}


# All variables required by main.tf and outputs.tf for the Function App module

variable "workload" {
  description = "The workload name"
  type        = string
}

variable "environment" {
  description = "The environment name"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region"
  type        = string
}

variable "service_plan_id" {
  description = "The ID of the App Service Plan to use for the Function App"
  type        = string
}

variable "os_type" {
  description = "The operating system type for the Function App (Linux or Windows)"
  type        = string
  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "os_type must be either 'Linux' or 'Windows'."
  }
}

variable "runtime_name" {
  description = "The runtime name (e.g., python, node, dotnet)"
  type        = string
}

variable "runtime_version" {
  description = "The runtime version (e.g., 3.9, 16, 6.0)"
  type        = string
}

variable "functions_extension_version" {
  description = "The Azure Functions extension version"
  type        = string
}


variable "enable_vnet_integration" {
  description = "Enable VNet integration (true/false)"
  type        = bool
}

variable "storage_account_tier" {
  description = "The storage account tier (Standard/Premium)"
  type        = string
  validation {
    condition     = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "storage_account_tier must be either 'Standard' or 'Premium'."
  }
}

variable "storage_account_replication_type" {
  description = "The storage account replication type (LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS)"
  type        = string
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.storage_account_replication_type)
    error_message = "storage_account_replication_type must be one of 'LRS', 'GRS', 'RAGRS', 'ZRS', 'GZRS', or 'RAGZRS'."
  }
}

variable "storage_min_tls_version" {
  description = "The minimum TLS version for the storage account. Allowed values: TLS1_0, TLS1_1, TLS1_2, TLS1_3. See https://learn.microsoft.com/en-us/azure/storage/common/storage-require-secure-transfer?tabs=azure-portal#minimum-tls-version"
  type        = string
  validation {
    condition     = contains(["TLS1_0", "TLS1_1", "TLS1_2", "TLS1_3"], var.storage_min_tls_version)
    error_message = "storage_min_tls_version must be one of 'TLS1_0', 'TLS1_1', 'TLS1_2', or 'TLS1_3'."
  }
}

variable "storage_blob_delete_retention_days" {
  description = "Days to retain deleted blobs"
  type        = number
  validation {
    condition     = var.storage_blob_delete_retention_days >= 1 && var.storage_blob_delete_retention_days <= 365
    error_message = "storage_blob_delete_retention_days must be between 1 and 365 days."
  }
}

variable "storage_container_delete_retention_days" {
  description = "Days to retain deleted containers"
  type        = number
}

variable "storage_sas_expiration_period" {
  description = "SAS expiration period for storage account"
  type        = string
}

variable "storage_sas_expiration_action" {
  description = "SAS expiration action for storage account. Allowed values: 'Log', 'Block' (case-sensitive). See https://learn.microsoft.com/en-us/rest/api/storagerp/storage-accounts/create?view=rest-storagerp-2024-01-01#expirationaction"
  type        = string
  validation {
    condition     = contains(["Log", "Block"], var.storage_sas_expiration_action)
    error_message = "storage_sas_expiration_action must be either 'Log' or 'Block'."
  }
}

variable "enable_storage_network_rules" {
  description = "Enable storage network rules (true/false)"
  type        = bool
}

variable "storage_network_rules_default_action" {
  description = "Default action for storage network rules"
  type        = string
}

variable "storage_network_rules_bypass" {
  description = "Bypass rules for storage network rules"
  type        = list(string)
}

variable "storage_network_rules_ip_rules" {
  description = "IP rules for storage network rules"
  type        = list(string)
}

variable "storage_network_rules_subnet_ids" {
  description = "Subnet IDs for storage network rules"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

variable "enable_application_insights" {
  description = "Enable Application Insights (true/false)"
  type        = bool
}

variable "application_insights_type" {
  description = "Application Insights type"
  type        = string
}

variable "application_insights_retention_days" {
  description = "Retention days for Application Insights"
  type        = number
}

variable "application_insights_sampling_percentage" {
  description = "Sampling percentage for Application Insights"
  type        = number
  validation {
    condition     = var.application_insights_sampling_percentage >= 0 && var.application_insights_sampling_percentage <= 100
    error_message = "application_insights_sampling_percentage must be between 0 and 100."
  }
}

variable "application_insights_disable_ip_masking" {
  description = "Disable IP masking for Application Insights (true/false)"
  type        = bool
}

variable "application_insights_local_auth_disabled" {
  description = "Disable local auth for Application Insights (true/false)"
  type        = bool
}

variable "application_insights_internet_ingestion_enabled" {
  description = "Enable internet ingestion for Application Insights (true/false)"
  type        = bool
}

variable "application_insights_internet_query_enabled" {
  description = "Enable internet query for Application Insights (true/false)"
  type        = bool
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for Application Insights"
  type        = string
}

variable "https_only" {
  description = "Enforce HTTPS only (true/false)"
  type        = bool
}

variable "client_certificate_enabled" {
  description = "Enable client certificate (true/false)"
  type        = bool
}

variable "client_certificate_mode" {
  description = "Client certificate mode"
  type        = string
}



variable "public_network_access_enabled" {
  description = "Enable public network access (true/false)"
  type        = bool
}

variable "scm_minimum_tls_version" {
  description = "Minimum TLS version for SCM endpoint"
  type        = string
}

variable "always_on" {
  description = "Enable Always On (true/false)"
  type        = bool
}

variable "pre_warmed_instance_count" {
  description = "Number of pre-warmed instances"
  type        = number
}

variable "elastic_instance_minimum" {
  description = "Minimum number of elastic instances"
  type        = number
}

variable "function_app_scale_limit" {
  description = "Function App scale limit"
  type        = number
}

variable "worker_count" {
  description = "Number of workers"
  type        = number
}

variable "use_32_bit_worker" {
  description = "Use 32-bit worker (true/false)"
  type        = bool
}

variable "deployment_slots" {
  description = "Deployment slots configuration"
  type        = map(any)
}

variable "vnet_integration_subnet_id" {
  description = "Subnet ID for VNet integration"
  type        = string
}

variable "websockets_enabled" {
  description = "Enable WebSockets (true/false)"
  type        = bool
}

variable "remote_debugging_enabled" {
  description = "Enable remote debugging (true/false)"
  type        = bool
}

variable "remote_debugging_version" {
  description = "Remote debugging version"
  type        = string
}

variable "enable_cors" {
  description = "Enable CORS (true/false)"
  type        = bool
}

variable "cors_allowed_origins" {
  description = "CORS allowed origins"
  type        = list(string)
}

variable "cors_support_credentials" {
  description = "CORS support credentials (true/false)"
  type        = bool
}

variable "use_dotnet_isolated_runtime" {
  description = "Use .NET isolated runtime (true/false)"
  type        = bool
}

variable "enable_diagnostic_settings" {
  description = "Enable diagnostic settings (true/false)"
  type        = bool
}
