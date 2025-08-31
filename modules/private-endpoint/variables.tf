# Private Endpoint Module - Variables
# This file defines all input variables for the private endpoint module

# Required Variables
variable "name" {
  description = "Name of the private endpoint"
  type        = string

  validation {
    condition     = length(var.name) > 0
    error_message = "Private endpoint name must not be empty."
  }
}

variable "location" {
  description = "Azure region for the private endpoint"
  type        = string

  validation {
    condition     = length(var.location) > 0
    error_message = "Location must not be empty."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group where the private endpoint will be created"
  type        = string

  validation {
    condition     = length(var.resource_group_name) > 0
    error_message = "Resource group name must not be empty."
  }
}

variable "subnet_id" {
  description = "ID of the subnet where the private endpoint will be created"
  type        = string

  validation {
    condition     = length(var.subnet_id) > 0
    error_message = "Subnet ID must not be empty."
  }
}

variable "private_connection_resource_id" {
  description = "Resource ID of the Azure service to connect to via private endpoint"
  type        = string

  validation {
    condition     = length(var.private_connection_resource_id) > 0
    error_message = "Private connection resource ID must not be empty."
  }
}

variable "subresource_names" {
  description = "List of subresource names which the private endpoint is able to connect to"
  type        = list(string)

  validation {
    condition     = length(var.subresource_names) > 0
    error_message = "At least one subresource name must be specified."
  }
}

# Optional Variables
variable "private_service_connection_name" {
  description = "Name of the private service connection. If not provided, will be generated based on private endpoint name"
  type        = string
  default     = null
}

variable "is_manual_connection" {
  description = "Whether the private endpoint connection requires manual approval"
  type        = bool
  default     = false
}

variable "request_message" {
  description = "Request message for manual private endpoint connection approval"
  type        = string
  default     = null
}

variable "private_dns_zone_ids" {
  description = "List of private DNS zone IDs to associate with the private endpoint"
  type        = list(string)
  default     = null
}

variable "private_dns_zone_group_name" {
  description = "Name of the private DNS zone group. If not provided, will be generated based on private endpoint name"
  type        = string
  default     = null
}

variable "ip_configurations" {
  description = "List of IP configurations for the private endpoint"
  type = list(object({
    name               = string
    private_ip_address = string
    subresource_name   = string
    member_name        = optional(string, null)
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to the private endpoint"
  type        = map(string)
  default     = {}
}
