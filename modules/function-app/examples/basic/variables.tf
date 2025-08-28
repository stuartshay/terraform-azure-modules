variable "workload" {
  description = "The workload name"
  type        = string
  default     = "example"

  validation {
    condition     = can(regex("^[a-z0-9]{2,10}$", var.workload))
    error_message = "Workload must be 2-10 characters, lowercase letters and numbers only."
  }
}

variable "environment" {
  description = "The environment name"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, staging, prod."
  }
}

variable "resource_group_name" {
  description = "The name of the existing resource group"
  type        = string
  default     = "rg-example-dev-001"
}
