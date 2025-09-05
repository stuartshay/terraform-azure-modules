# Application Insights Module - Variables
# This file defines all input variables for the application insights module

# Required Variables
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

# Optional naming variables (for flexible naming)
variable "name" {
  description = "Custom name for the Application Insights instance. If not provided, will use standard naming convention."
  type        = string
  default     = null
}

variable "workload" {
  description = "Name of the workload or application (used in naming convention when name is not provided)"
  type        = string
  default     = "app"
}

variable "environment" {
  description = "Environment name (dev, staging, prod) (used in naming convention when name is not provided)"
  type        = string
  default     = "dev"
}

variable "location_short" {
  description = "Short name for the location (used in naming convention when name is not provided)"
  type        = string
  default     = "eus"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Application Insights Configuration
variable "application_type" {
  description = "Type of application being monitored"
  type        = string
  default     = "web"

  validation {
    condition = contains([
      "web", "java", "MobileCenter", "Node.JS", "other", "phone", "store", "ios"
    ], var.application_type)
    error_message = "Application type must be one of: web, java, MobileCenter, Node.JS, other, phone, store, ios."
  }
}

variable "workspace_id" {
  description = "ID of the Log Analytics Workspace to associate with Application Insights (for workspace-based mode). If null, creates classic Application Insights."
  type        = string
  default     = null
}

variable "sampling_percentage" {
  description = "Sampling percentage for Application Insights telemetry"
  type        = number
  default     = 100

  validation {
    condition     = var.sampling_percentage > 0 && var.sampling_percentage <= 100
    error_message = "Sampling percentage must be between 1 and 100."
  }
}

variable "disable_ip_masking" {
  description = "Disable IP masking for Application Insights (useful for development environments)"
  type        = bool
  default     = false
}

variable "daily_data_cap_gb" {
  description = "Daily data cap in GB for Application Insights (-1 for unlimited)"
  type        = number
  default     = null
}

variable "daily_data_cap_notifications_disabled" {
  description = "Disable daily data cap notifications"
  type        = bool
  default     = false
}

variable "retention_in_days" {
  description = "Number of days to retain data in Application Insights (only for classic mode, ignored for workspace-based)"
  type        = number
  default     = 90

  validation {
    condition     = var.retention_in_days >= 30 && var.retention_in_days <= 730
    error_message = "Retention must be between 30 and 730 days."
  }
}

variable "force_customer_storage_for_profiler" {
  description = "Force customer storage for profiler (only for classic mode)"
  type        = bool
  default     = false
}

variable "internet_ingestion_enabled" {
  description = "Enable internet ingestion for Application Insights"
  type        = bool
  default     = true
}

variable "internet_query_enabled" {
  description = "Enable internet query for Application Insights"
  type        = bool
  default     = true
}

variable "local_authentication_disabled" {
  description = "Disable local authentication for Application Insights"
  type        = bool
  default     = false
}

# Smart Detection Configuration
variable "enable_smart_detection" {
  description = "Enable smart detection rules for Application Insights"
  type        = bool
  default     = true
}

variable "smart_detection_emails" {
  description = "List of email addresses to receive smart detection notifications"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for email in var.smart_detection_emails : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))
    ])
    error_message = "All smart detection emails must be valid email addresses."
  }
}

variable "smart_detection_failure_anomalies_enabled" {
  description = "Enable failure anomalies smart detection rule"
  type        = bool
  default     = true
}

variable "smart_detection_performance_anomalies_enabled" {
  description = "Enable performance anomalies smart detection rule"
  type        = bool
  default     = true
}

variable "smart_detection_trace_severity_enabled" {
  description = "Enable trace severity smart detection rule"
  type        = bool
  default     = true
}

variable "smart_detection_exception_volume_enabled" {
  description = "Enable exception volume smart detection rule"
  type        = bool
  default     = true
}

variable "smart_detection_memory_leak_enabled" {
  description = "Enable memory leak smart detection rule"
  type        = bool
  default     = true
}

variable "smart_detection_security_detection_enabled" {
  description = "Enable security detection smart detection rule"
  type        = bool
  default     = true
}

# Workbook Configuration
variable "enable_workbook" {
  description = "Enable Application Insights workbook creation"
  type        = bool
  default     = false
}

variable "workbook_display_name" {
  description = "Display name for the Application Insights workbook"
  type        = string
  default     = null
}

variable "workbook_data_json" {
  description = "Custom JSON data for the workbook. If not provided, a default dashboard will be created."
  type        = string
  default     = null
}

# API Key Configuration
variable "create_api_key" {
  description = "Create an API key for programmatic access to Application Insights"
  type        = bool
  default     = false
}

variable "api_key_read_permissions" {
  description = "List of read permissions for the API key"
  type        = list(string)
  default     = ["aggregate", "api", "draft", "extendqueries", "search"]
}

variable "api_key_write_permissions" {
  description = "List of write permissions for the API key"
  type        = list(string)
  default     = []
}

# Web Test Configuration
variable "web_tests" {
  description = "Map of web tests to create for availability monitoring"
  type = map(object({
    url                              = string
    geo_locations                    = list(string)
    frequency                        = optional(number, 300)
    timeout                          = optional(number, 30)
    enabled                          = optional(bool, true)
    retry_enabled                    = optional(bool, true)
    http_verb                        = optional(string, "GET")
    parse_dependent_requests_enabled = optional(bool, false)
    follow_redirects_enabled         = optional(bool, true)
    headers                          = optional(map(string), {})
    body                             = optional(string, null)
    validation_rules = optional(object({
      expected_status_code        = optional(number, 200)
      ssl_check_enabled           = optional(bool, false)
      ssl_cert_remaining_lifetime = optional(number, null)
      content_validation = optional(object({
        content_match      = string
        ignore_case        = optional(bool, false)
        pass_if_text_found = optional(bool, true)
      }), null)
    }), null)
  }))
  default = {}
}
