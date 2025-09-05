# Core variables required by main.tf and outputs.tf for the Container Instances module

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

# Container Configuration
variable "os_type" {
  description = "The operating system type for the container group (Linux or Windows)"
  type        = string
  default     = "Linux"
  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "os_type must be either 'Linux' or 'Windows'."
  }
}

variable "restart_policy" {
  description = "The restart policy for the container group (Always, OnFailure, Never)"
  type        = string
  default     = "Always"
  validation {
    condition     = contains(["Always", "OnFailure", "Never"], var.restart_policy)
    error_message = "restart_policy must be one of 'Always', 'OnFailure', or 'Never'."
  }
}

variable "containers" {
  description = "List of containers to deploy in the container group"
  type = list(object({
    name   = string
    image  = string
    cpu    = number
    memory = number
    ports = optional(list(object({
      port     = number
      protocol = optional(string, "TCP")
    })), [])
    environment_variables        = optional(map(string), {})
    secure_environment_variables = optional(map(string), {})
    commands                     = optional(list(string), [])
    volume_mounts = optional(list(object({
      name       = string
      mount_path = string
      read_only  = optional(bool, false)
    })), [])
    liveness_probe = optional(object({
      exec = optional(list(string))
      http_get = optional(object({
        path   = optional(string)
        port   = number
        scheme = optional(string, "HTTP")
      }))
      initial_delay_seconds = optional(number, 0)
      period_seconds        = optional(number, 10)
      failure_threshold     = optional(number, 3)
      success_threshold     = optional(number, 1)
      timeout_seconds       = optional(number, 1)
    }))
    readiness_probe = optional(object({
      exec = optional(list(string))
      http_get = optional(object({
        path   = optional(string)
        port   = number
        scheme = optional(string, "HTTP")
      }))
      initial_delay_seconds = optional(number, 0)
      period_seconds        = optional(number, 10)
      failure_threshold     = optional(number, 3)
      success_threshold     = optional(number, 1)
      timeout_seconds       = optional(number, 1)
    }))
  }))
  validation {
    condition     = length(var.containers) > 0
    error_message = "You must specify at least one container in the containers variable."
  }
}

# Networking Configuration
variable "enable_public_ip" {
  description = "Enable public IP address for the container group"
  type        = bool
  default     = true
}

variable "ip_address_type" {
  description = "The IP address type for the container group (Public, Private, None)"
  type        = string
  default     = "Public"
  validation {
    condition     = contains(["Public", "Private", "None"], var.ip_address_type)
    error_message = "ip_address_type must be one of 'Public', 'Private', or 'None'."
  }
}

variable "dns_name_label" {
  description = "The DNS name label for the container group"
  type        = string
  default     = null
}

variable "dns_name_label_reuse_policy" {
  description = "The DNS name label reuse policy (Unsecure, TenantReuse, SubscriptionReuse, ResourceGroupReuse, Noreuse)"
  type        = string
  default     = "Unsecure"
  validation {
    condition     = contains(["Unsecure", "TenantReuse", "SubscriptionReuse", "ResourceGroupReuse", "Noreuse"], var.dns_name_label_reuse_policy)
    error_message = "dns_name_label_reuse_policy must be one of 'Unsecure', 'TenantReuse', 'SubscriptionReuse', 'ResourceGroupReuse', or 'Noreuse'."
  }
}

variable "exposed_ports" {
  description = "List of ports to expose on the container group"
  type = list(object({
    port     = number
    protocol = optional(string, "TCP")
  }))
  default = []
}

# VNet Integration
variable "enable_vnet_integration" {
  description = "Enable VNet integration for the container group"
  type        = bool
  default     = false
}

variable "subnet_ids" {
  description = "List of subnet IDs for VNet integration"
  type        = list(string)
  default     = []
}

# Storage Volumes

# Container Registry
variable "image_registry_credentials" {
  description = "List of image registry credentials"
  type = list(object({
    server   = string
    username = string
    password = string
  }))
  default   = []
  sensitive = true
}

# Identity
variable "identity_type" {
  description = "The type of managed identity for the container group (SystemAssigned, UserAssigned, SystemAssigned,UserAssigned)"
  type        = string
  default     = null
  validation {
    condition = var.identity_type == null || contains([
      "SystemAssigned",
      "UserAssigned",
      "SystemAssigned, UserAssigned"
    ], var.identity_type)
    error_message = "identity_type must be one of 'SystemAssigned', 'UserAssigned', or 'SystemAssigned, UserAssigned'."
  }
}

variable "identity_ids" {
  description = "List of user assigned identity IDs"
  type        = list(string)
  default     = []
}

# Diagnostics
variable "enable_diagnostic_settings" {
  description = "Enable diagnostic settings for the container group"
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostic settings"
  type        = string
  default     = null
}

variable "diagnostic_logs" {
  description = "List of log categories to enable for diagnostic settings"
  type        = list(string)
  default     = ["ContainerInstanceLog"]
}

variable "diagnostic_metrics" {
  description = "List of metric categories to enable for diagnostic settings"
  type        = list(string)
  default     = ["AllMetrics"]
}

# Priority and Zone
variable "priority" {
  description = "The priority of the container group (Regular, Spot)"
  type        = string
  default     = "Regular"
  validation {
    condition     = contains(["Regular", "Spot"], var.priority)
    error_message = "priority must be either 'Regular' or 'Spot'."
  }
}

variable "zones" {
  description = "List of availability zones for the container group"
  type        = list(string)
  default     = []
}

# Tags
variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
