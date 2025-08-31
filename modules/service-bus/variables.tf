# Service Bus Module - Variables
# Input variables for the Azure Service Bus module

# Required Variables
variable "workload" {
  description = "The workload name for naming convention"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]{2,10}$", var.workload))
    error_message = "Workload must be 2-10 characters long and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "The environment name for naming convention"
  type        = string
  validation {
    condition     = contains(["dev", "test", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, staging, prod."
  }
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
}

variable "location_short" {
  description = "The short name for the Azure region (e.g., 'eastus', 'westus2')"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9]{4,15}$", var.location_short))
    error_message = "Location short must be 4-15 characters long and contain only lowercase letters and numbers."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group where the Service Bus will be created"
  type        = string
}

# Service Bus Configuration
variable "sku" {
  description = "The SKU of the Service Bus namespace"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "SKU must be one of: Basic, Standard, Premium."
  }
}

variable "premium_messaging_units" {
  description = "The number of messaging units for Premium SKU (1, 2, 4, 8, or 16)"
  type        = number
  default     = 1
  validation {
    condition     = contains([1, 2, 4, 8, 16], var.premium_messaging_units)
    error_message = "Premium messaging units must be one of: 1, 2, 4, 8, 16."
  }
}

variable "premium_messaging_partitions" {
  description = "The number of messaging partitions for Premium SKU (1, 2, or 4)"
  type        = number
  default     = 1
  validation {
    condition     = contains([1, 2, 4], var.premium_messaging_partitions)
    error_message = "Premium messaging partitions must be one of: 1, 2, 4."
  }
}

# Network and Security Settings
variable "public_network_access_enabled" {
  description = "Whether public network access is enabled for the Service Bus namespace"
  type        = bool
  default     = true
}

variable "minimum_tls_version" {
  description = "The minimum TLS version for the Service Bus namespace"
  type        = string
  default     = "1.2"
  validation {
    condition     = contains(["1.0", "1.1", "1.2"], var.minimum_tls_version)
    error_message = "Minimum TLS version must be one of: 1.0, 1.1, 1.2."
  }
}

variable "local_auth_enabled" {
  description = "Whether local authentication is enabled for the Service Bus namespace"
  type        = bool
  default     = true
}

# Identity Configuration
variable "identity_type" {
  description = "The type of managed identity for the Service Bus namespace"
  type        = string
  default     = null
  validation {
    condition = var.identity_type == null || contains([
      "SystemAssigned",
      "UserAssigned",
      "SystemAssigned, UserAssigned"
    ], var.identity_type)
    error_message = "Identity type must be one of: SystemAssigned, UserAssigned, SystemAssigned, UserAssigned."
  }
}

variable "identity_ids" {
  description = "List of user assigned identity IDs"
  type        = list(string)
  default     = null
}

# Customer Managed Key (Premium only)
variable "customer_managed_key" {
  description = "Customer managed key configuration for Premium SKU"
  type = object({
    key_vault_key_id                  = string
    identity_id                       = string
    infrastructure_encryption_enabled = optional(bool, false)
  })
  default = null
}

# Network Rule Set
variable "network_rule_set" {
  description = "Network rule set configuration"
  type = object({
    default_action                = string
    public_network_access_enabled = optional(bool, true)
    trusted_services_allowed      = optional(bool, false)
    network_rules = optional(list(object({
      subnet_id                            = string
      ignore_missing_vnet_service_endpoint = optional(bool, false)
    })), [])
    ip_rules = optional(list(object({
      ip_mask = string
      action  = optional(string, "Allow")
    })), [])
  })
  default = null
}

# Queues Configuration
variable "queues" {
  description = "Map of Service Bus queues to create"
  type = map(object({
    custom_name                             = optional(string)
    auto_delete_on_idle                     = optional(string, "P10675199DT2H48M5.4775807S")
    dead_lettering_on_message_expiration    = optional(bool, false)
    default_message_ttl                     = optional(string, "P14D")
    duplicate_detection_history_time_window = optional(string, "PT10M")
    enable_express                          = optional(bool, false)
    enable_partitioning                     = optional(bool, false)
    forward_dead_lettered_messages_to       = optional(string)
    forward_to                              = optional(string)
    lock_duration                           = optional(string, "PT1M")
    max_delivery_count                      = optional(number, 10)
    max_message_size_in_kilobytes           = optional(number)
    max_size_in_megabytes                   = optional(number, 1024)
    requires_duplicate_detection            = optional(bool, false)
    requires_session                        = optional(bool, false)
    status                                  = optional(string, "Active")
  }))
  default = {}
}

# Topics Configuration
variable "topics" {
  description = "Map of Service Bus topics to create"
  type = map(object({
    custom_name                             = optional(string)
    auto_delete_on_idle                     = optional(string, "P10675199DT2H48M5.4775807S")
    default_message_ttl                     = optional(string, "P14D")
    duplicate_detection_history_time_window = optional(string, "PT10M")
    enable_express                          = optional(bool, false)
    enable_partitioning                     = optional(bool, false)
    max_message_size_in_kilobytes           = optional(number)
    max_size_in_megabytes                   = optional(number, 1024)
    requires_duplicate_detection            = optional(bool, false)
    status                                  = optional(string, "Active")
    support_ordering                        = optional(bool, false)
  }))
  default = {}
}

# Topic Subscriptions Configuration
variable "topic_subscriptions" {
  description = "Map of Service Bus topic subscriptions to create"
  type = map(object({
    name                                      = string
    topic_name                                = string
    custom_name                               = optional(string)
    auto_delete_on_idle                       = optional(string, "P10675199DT2H48M5.4775807S")
    dead_lettering_on_filter_evaluation_error = optional(bool, true)
    dead_lettering_on_message_expiration      = optional(bool, false)
    default_message_ttl                       = optional(string, "P14D")
    enable_batched_operations                 = optional(bool, true)
    forward_dead_lettered_messages_to         = optional(string)
    forward_to                                = optional(string)
    lock_duration                             = optional(string, "PT1M")
    max_delivery_count                        = optional(number, 10)
    requires_session                          = optional(bool, false)
    status                                    = optional(string, "Active")
    client_scoped_subscription_enabled        = optional(bool, false)
    client_scoped_subscription = optional(object({
      client_id    = string
      is_shareable = optional(bool, false)
    }))
  }))
  default = {}
}

# Authorization Rules
variable "authorization_rules" {
  description = "Map of namespace-level authorization rules to create"
  type = map(object({
    custom_name = optional(string)
    listen      = optional(bool, false)
    send        = optional(bool, false)
    manage      = optional(bool, false)
  }))
  default = {}
}

variable "queue_authorization_rules" {
  description = "Map of queue-level authorization rules to create"
  type = map(object({
    name       = string
    queue_name = string
    listen     = optional(bool, false)
    send       = optional(bool, false)
    manage     = optional(bool, false)
  }))
  default = {}
}

variable "topic_authorization_rules" {
  description = "Map of topic-level authorization rules to create"
  type = map(object({
    name       = string
    topic_name = string
    listen     = optional(bool, false)
    send       = optional(bool, false)
    manage     = optional(bool, false)
  }))
  default = {}
}

# Private Endpoint Configuration
variable "enable_private_endpoint" {
  description = "Whether to create a private endpoint for the Service Bus namespace"
  type        = bool
  default     = false
}

variable "private_endpoint_subnet_id" {
  description = "The subnet ID where the private endpoint will be created"
  type        = string
  default     = null
}

variable "private_dns_zone_ids" {
  description = "List of private DNS zone IDs for the private endpoint"
  type        = list(string)
  default     = null
}

variable "private_service_connection_name" {
  description = "Custom name for the private service connection"
  type        = string
  default     = null
}

variable "private_dns_zone_group_name" {
  description = "Custom name for the private DNS zone group"
  type        = string
  default     = null
}

# Key Vault Integration
variable "enable_key_vault_integration" {
  description = "Whether to store connection strings in Key Vault"
  type        = bool
  default     = false
}

variable "key_vault_id" {
  description = "The ID of the Key Vault where connection strings will be stored"
  type        = string
  default     = null
}

variable "key_vault_secrets" {
  description = "Map of Key Vault secrets to create for connection strings"
  type = map(object({
    secret_name     = string
    auth_rule_name  = string
    auth_rule_type  = string # "namespace", "queue", or "topic"
    expiration_date = optional(string)
  }))
  default = {}
}

# Diagnostic Settings
variable "enable_diagnostic_settings" {
  description = "Whether to enable diagnostic settings for the Service Bus namespace"
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace for diagnostic settings"
  type        = string
  default     = null
}

variable "diagnostic_storage_account_id" {
  description = "The ID of the storage account for diagnostic settings"
  type        = string
  default     = null
}

variable "eventhub_authorization_rule_id" {
  description = "The ID of the Event Hub authorization rule for diagnostic settings"
  type        = string
  default     = null
}

variable "eventhub_name" {
  description = "The name of the Event Hub for diagnostic settings"
  type        = string
  default     = null
}

variable "diagnostic_log_categories" {
  description = "List of log categories to enable for diagnostic settings"
  type        = list(string)
  default = [
    "OperationalLogs",
    "VNetAndIPFilteringLogs",
    "RuntimeAuditLogs",
    "ApplicationMetricsLogs"
  ]
}

variable "diagnostic_metrics" {
  description = "List of metric categories to enable for diagnostic settings"
  type        = list(string)
  default = [
    "AllMetrics"
  ]
}

# Tags
variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
