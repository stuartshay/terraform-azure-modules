# Complete Private Endpoint Example - Variables
# This file defines input variables for the complete example

variable "resource_group_name" {
  description = "Name of the existing resource group"
  type        = string
  default     = "rg-example-prod-eastus-001"
}

variable "virtual_network_name" {
  description = "Name of the existing virtual network"
  type        = string
  default     = "vnet-example-prod-eastus-001"
}

variable "private_endpoint_subnet_name" {
  description = "Name of the existing subnet for private endpoints"
  type        = string
  default     = "snet-private-endpoints-example-prod-eastus-001"
}

variable "servicebus_namespace_name" {
  description = "Name of the Service Bus namespace to create (must be globally unique)"
  type        = string
  default     = "sb-example-pe-complete-001"

  validation {
    condition     = length(var.servicebus_namespace_name) >= 6 && length(var.servicebus_namespace_name) <= 50
    error_message = "Service Bus namespace name must be between 6 and 50 characters."
  }

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]*[a-zA-Z0-9]$", var.servicebus_namespace_name))
    error_message = "Service Bus namespace name must start with a letter, end with a letter or number, and contain only letters, numbers, and hyphens."
  }
}

variable "storage_account_name" {
  description = "Name of the storage account to create (must be globally unique)"
  type        = string
  default     = "stexamplepecomplete001"

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
    Environment = "prod"
    Project     = "private-endpoint-example"
    Example     = "complete"
    ManagedBy   = "terraform"
    CostCenter  = "engineering"
    Owner       = "platform-team"
  }
}
