# Basic Private Endpoint Example - Variables
# This file defines input variables for the basic example

variable "resource_group_name" {
  description = "Name of the existing resource group"
  type        = string
  default     = "rg-example-dev-eastus-001"
}

variable "virtual_network_name" {
  description = "Name of the existing virtual network"
  type        = string
  default     = "vnet-example-dev-eastus-001"
}

variable "subnet_name" {
  description = "Name of the existing subnet for private endpoints"
  type        = string
  default     = "snet-private-endpoints-example-dev-eastus-001"
}

variable "storage_account_name" {
  description = "Name of the storage account to create (must be globally unique)"
  type        = string
  default     = "stexamplepebasic001"

  validation {
    condition     = length(var.storage_account_name) >= 3 && length(var.storage_account_name) <= 24
    error_message = "Storage account name must be between 3 and 24 characters."
  }

  validation {
    condition     = can(regex("^[a-z0-9]+$", var.storage_account_name))
    error_message = "Storage account name must contain only lowercase letters and numbers."
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "private-endpoint-example"
    Example     = "basic"
    ManagedBy   = "terraform"
  }
}
