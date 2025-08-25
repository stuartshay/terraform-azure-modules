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

variable "location_short" {
  description = "Short name for the Azure region (used for storage account naming)"
  type        = string
  default     = "eus"

  validation {
    condition     = length(var.location_short) > 0 && length(var.location_short) <= 6
    error_message = "Location short name must not be empty and must be 6 characters or less for storage account naming."
  }
}

variable "sku_name" {
  description = "The SKU name for the App Service Plan (EP1, EP2, or EP3 for Elastic Premium)"
  type        = string
  default     = "EP1"

  validation {
    condition     = contains(["EP1", "EP2", "EP3"], var.sku_name)
    error_message = "The sku_name must be EP1, EP2, or EP3 (Elastic Premium tiers only)."
  }
}

variable "python_version" {
  description = "The Python version"
  type        = string
  default     = "3.13"

  validation {
    condition     = contains(["3.8", "3.9", "3.10", "3.11", "3.12", "3.13"], var.python_version)
    error_message = "Python version must be 3.8, 3.9, 3.10, 3.11, 3.12, or 3.13."
  }
}

variable "function_app_settings" {
  description = "Additional app settings for the Function App"
  type        = map(string)
  default     = {}
}

variable "subnet_id" {
  description = "The subnet ID for VNET integration"
  type        = string
}

variable "enable_application_insights" {
  description = "Enable Application Insights for the Function App"
  type        = bool
  default     = true
}

variable "always_ready_instances" {
  description = "Number of always ready instances for Elastic Premium SKUs"
  type        = number
  default     = 1

  validation {
    condition     = var.always_ready_instances >= 0 && var.always_ready_instances <= 20
    error_message = "Always ready instances must be between 0 and 20."
  }
}

variable "maximum_elastic_worker_count" {
  description = "Maximum number of elastic workers for Elastic Premium SKUs"
  type        = number
  default     = 3

  validation {
    condition     = var.maximum_elastic_worker_count >= 1 && var.maximum_elastic_worker_count <= 20
    error_message = "Maximum elastic worker count must be between 1 and 20."
  }
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

# Storage Account Configuration
variable "storage_account_tier" {
  description = "The storage account tier for the Function App storage"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "Storage account tier must be Standard or Premium."
  }
}

variable "storage_account_replication_type" {
  description = "The storage account replication type for the Function App storage"
  type        = string
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.storage_account_replication_type)
    error_message = "Storage account replication type must be LRS, GRS, RAGRS, ZRS, GZRS, or RAGZRS."
  }
}

variable "enable_storage_versioning" {
  description = "Enable blob versioning for the Function App storage account"
  type        = bool
  default     = false
}

variable "enable_storage_change_feed" {
  description = "Enable change feed for the Function App storage account"
  type        = bool
  default     = false
}

variable "storage_delete_retention_days" {
  description = "Number of days to retain deleted blobs"
  type        = number
  default     = 7

  validation {
    condition     = var.storage_delete_retention_days >= 1 && var.storage_delete_retention_days <= 365
    error_message = "Storage delete retention days must be between 1 and 365."
  }
}
