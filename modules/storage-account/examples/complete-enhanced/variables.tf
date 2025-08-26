# Variables for the Complete Enhanced Storage Account Example

variable "resource_group_name" {
  description = "Name of the resource group (leave empty to create a new one)"
  type        = string
  default     = ""
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "diagnostics_retention_days" {
  description = "Number of days to retain diagnostic logs"
  type        = number
  default     = 30

  validation {
    condition     = var.diagnostics_retention_days >= 1 && var.diagnostics_retention_days <= 365
    error_message = "Diagnostics retention days must be between 1 and 365."
  }
}

variable "container_immutability_days" {
  description = "Number of days for container immutability policy"
  type        = number
  default     = 30

  validation {
    condition     = var.container_immutability_days >= 1 && var.container_immutability_days <= 146000
    error_message = "Container immutability days must be between 1 and 146000."
  }
}

variable "sas_ttl_hours" {
  description = "SAS token time-to-live in hours"
  type        = number
  default     = 24

  validation {
    condition     = var.sas_ttl_hours >= 1 && var.sas_ttl_hours <= 8760
    error_message = "SAS TTL hours must be between 1 and 8760 (1 year)."
  }
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}