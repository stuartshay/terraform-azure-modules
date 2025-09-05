# Application Insights Network Module - Variables
# This file defines all input variables for the application insights network module

# Required Variables
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "application_insights_name" {
  description = "Name of the existing Application Insights instance to monitor"
  type        = string
}

# Optional naming variables (for flexible naming)
variable "workload" {
  description = "Name of the workload or application (used in naming convention)"
  type        = string
  default     = "app"
}

variable "environment" {
  description = "Environment name (dev, staging, prod) (used in naming convention)"
  type        = string
  default     = "dev"
}

variable "location_short" {
  description = "Short name for the location (used in naming convention)"
  type        = string
  default     = "eus"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Log Analytics Workspace Configuration (optional)
variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace (optional, for advanced queries)"
  type        = string
  default     = null
}

# Alert Configuration
variable "enable_response_time_alert" {
  description = "Enable response time alert"
  type        = bool
  default     = true
}

variable "response_time_threshold_ms" {
  description = "Response time threshold in milliseconds"
  type        = number
  default     = 5000

  validation {
    condition     = var.response_time_threshold_ms > 0
    error_message = "Response time threshold must be greater than 0."
  }
}

variable "response_time_alert_severity" {
  description = "Severity level for response time alert (0-4, where 0 is critical)"
  type        = number
  default     = 2

  validation {
    condition     = var.response_time_alert_severity >= 0 && var.response_time_alert_severity <= 4
    error_message = "Alert severity must be between 0 and 4."
  }
}

variable "enable_failed_request_alert" {
  description = "Enable failed request rate alert"
  type        = bool
  default     = true
}

variable "failed_request_rate_threshold" {
  description = "Failed request rate threshold (percentage)"
  type        = number
  default     = 5

  validation {
    condition     = var.failed_request_rate_threshold >= 0 && var.failed_request_rate_threshold <= 100
    error_message = "Failed request rate threshold must be between 0 and 100."
  }
}

variable "failed_request_alert_severity" {
  description = "Severity level for failed request alert (0-4, where 0 is critical)"
  type        = number
  default     = 1

  validation {
    condition     = var.failed_request_alert_severity >= 0 && var.failed_request_alert_severity <= 4
    error_message = "Alert severity must be between 0 and 4."
  }
}

variable "enable_exception_alert" {
  description = "Enable exception rate alert"
  type        = bool
  default     = true
}

variable "exception_rate_threshold" {
  description = "Exception rate threshold (count per 5 minutes)"
  type        = number
  default     = 10

  validation {
    condition     = var.exception_rate_threshold >= 0
    error_message = "Exception rate threshold must be greater than or equal to 0."
  }
}

variable "exception_alert_severity" {
  description = "Severity level for exception alert (0-4, where 0 is critical)"
  type        = number
  default     = 1

  validation {
    condition     = var.exception_alert_severity >= 0 && var.exception_alert_severity <= 4
    error_message = "Alert severity must be between 0 and 4."
  }
}

variable "enable_availability_alert" {
  description = "Enable availability alert"
  type        = bool
  default     = true
}

variable "availability_threshold_percent" {
  description = "Availability threshold percentage"
  type        = number
  default     = 99

  validation {
    condition     = var.availability_threshold_percent >= 0 && var.availability_threshold_percent <= 100
    error_message = "Availability threshold must be between 0 and 100."
  }
}

variable "availability_alert_severity" {
  description = "Severity level for availability alert (0-4, where 0 is critical)"
  type        = number
  default     = 0

  validation {
    condition     = var.availability_alert_severity >= 0 && var.availability_alert_severity <= 4
    error_message = "Alert severity must be between 0 and 4."
  }
}

variable "enable_server_error_alert" {
  description = "Enable server error (5xx) alert"
  type        = bool
  default     = true
}

variable "server_error_threshold" {
  description = "Server error threshold (count per 5 minutes)"
  type        = number
  default     = 10

  validation {
    condition     = var.server_error_threshold >= 0
    error_message = "Server error threshold must be greater than or equal to 0."
  }
}

variable "server_error_alert_severity" {
  description = "Severity level for server error alert (0-4, where 0 is critical)"
  type        = number
  default     = 1

  validation {
    condition     = var.server_error_alert_severity >= 0 && var.server_error_alert_severity <= 4
    error_message = "Alert severity must be between 0 and 4."
  }
}

# Dashboard Configuration
variable "enable_dashboard" {
  description = "Enable Application Insights dashboard creation"
  type        = bool
  default     = true
}

variable "dashboard_display_name" {
  description = "Display name for the Application Insights dashboard"
  type        = string
  default     = null
}
