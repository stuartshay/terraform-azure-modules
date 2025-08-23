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
  description = "The SKU name for the App Service Plan (S1 or S2 only)"
  type        = string
  default     = "S1"

  validation {
    condition     = contains(["S1", "S2"], var.sku_name)
    error_message = "The sku_name must be either S1 or S2."
  }
}

variable "python_version" {
  description = "The Python version"
  type        = string
  default     = "3.13"
}

variable "app_settings" {
  description = "App settings for the web app"
  type        = map(string)
  default     = {}
}

variable "subnet_id" {
  description = "The subnet ID for VNET integration"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
