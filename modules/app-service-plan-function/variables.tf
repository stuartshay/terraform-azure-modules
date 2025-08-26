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

variable "os_type" {
  description = "The operating system type for the App Service Plan (Linux or Windows)"
  type        = string
  default     = "Linux"

  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "OS type must be either 'Linux' or 'Windows'."
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

variable "subnet_id" {
  description = "The subnet ID for VNET integration (required for App Service Plan)"
  type        = string
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
