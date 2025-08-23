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

variable "sku_name" {
  description = "The SKU name for the App Service Plan (Y1 for Consumption or EP1 for Elastic Premium)"
  type        = string
  default     = "EP1"

  validation {
    condition     = contains(["Y1", "EP1"], var.sku_name)
    error_message = "The sku_name must be either Y1 (Consumption) or EP1 (Elastic Premium)."
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
  description = "Number of always ready instances for EP1 SKU"
  type        = number
  default     = 1

  validation {
    condition     = var.always_ready_instances >= 0 && var.always_ready_instances <= 20
    error_message = "Always ready instances must be between 0 and 20."
  }
}

variable "maximum_elastic_worker_count" {
  description = "Maximum number of elastic workers for EP1 SKU"
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
