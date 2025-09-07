# Application Insights Function Module - Variables
# This file defines all input variables for the application insights function module

# Required Variables
variable "resource_group_name" {
  description = "Name of the resource group containing the Function Apps and App Service Plans"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "application_insights_name" {
  description = "Name of the existing Application Insights instance"
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

# Function App Configuration
variable "function_app_names" {
  description = "List of Function App names to monitor (if null, will monitor all Function Apps in the resource group)"
  type        = list(string)
  default     = null
}

variable "app_service_plan_names" {
  description = "List of App Service Plan names to monitor (if null, will monitor all App Service Plans in the resource group)"
  type        = list(string)
  default     = null
}

# Function Alert Configuration
variable "enable_function_alerts" {
  description = "Enable function-specific alerts"
  type        = bool
  default     = true
}

variable "function_duration_threshold_ms" {
  description = "Function execution duration threshold in milliseconds"
  type        = number
  default     = 30000

  validation {
    condition     = var.function_duration_threshold_ms > 0
    error_message = "Function duration threshold must be greater than 0."
  }
}

variable "function_duration_alert_severity" {
  description = "Severity level for function duration alert (0-4, where 0 is critical)"
  type        = number
  default     = 2

  validation {
    condition     = var.function_duration_alert_severity >= 0 && var.function_duration_alert_severity <= 4
    error_message = "Alert severity must be between 0 and 4."
  }
}

variable "function_failure_rate_threshold" {
  description = "Function failure rate threshold (percentage)"
  type        = number
  default     = 5

  validation {
    condition     = var.function_failure_rate_threshold >= 0 && var.function_failure_rate_threshold <= 100
    error_message = "Function failure rate threshold must be between 0 and 100."
  }
}

variable "function_failure_alert_severity" {
  description = "Severity level for function failure alert (0-4, where 0 is critical)"
  type        = number
  default     = 1

  validation {
    condition     = var.function_failure_alert_severity >= 0 && var.function_failure_alert_severity <= 4
    error_message = "Alert severity must be between 0 and 4."
  }
}

variable "function_min_invocations_threshold" {
  description = "Minimum function invocations threshold (set to 0 to disable low activity alerts)"
  type        = number
  default     = 0

  validation {
    condition     = var.function_min_invocations_threshold >= 0
    error_message = "Function minimum invocations threshold must be greater than or equal to 0."
  }
}

variable "function_activity_alert_severity" {
  description = "Severity level for function low activity alert (0-4, where 0 is critical)"
  type        = number
  default     = 3

  validation {
    condition     = var.function_activity_alert_severity >= 0 && var.function_activity_alert_severity <= 4
    error_message = "Alert severity must be between 0 and 4."
  }
}

# App Service Plan Alert Configuration
variable "enable_app_service_alerts" {
  description = "Enable App Service Plan alerts"
  type        = bool
  default     = true
}

variable "cpu_threshold_percent" {
  description = "CPU usage threshold percentage for App Service Plans"
  type        = number
  default     = 80

  validation {
    condition     = var.cpu_threshold_percent >= 0 && var.cpu_threshold_percent <= 100
    error_message = "CPU threshold must be between 0 and 100."
  }
}

variable "app_service_cpu_alert_severity" {
  description = "Severity level for App Service Plan CPU alert (0-4, where 0 is critical)"
  type        = number
  default     = 2

  validation {
    condition     = var.app_service_cpu_alert_severity >= 0 && var.app_service_cpu_alert_severity <= 4
    error_message = "Alert severity must be between 0 and 4."
  }
}

variable "memory_threshold_percent" {
  description = "Memory usage threshold percentage for App Service Plans"
  type        = number
  default     = 80

  validation {
    condition     = var.memory_threshold_percent >= 0 && var.memory_threshold_percent <= 100
    error_message = "Memory threshold must be between 0 and 100."
  }
}

variable "app_service_memory_alert_severity" {
  description = "Severity level for App Service Plan memory alert (0-4, where 0 is critical)"
  type        = number
  default     = 2

  validation {
    condition     = var.app_service_memory_alert_severity >= 0 && var.app_service_memory_alert_severity <= 4
    error_message = "Alert severity must be between 0 and 4."
  }
}

# Advanced Alert Configuration
variable "enable_cold_start_detection" {
  description = "Enable cold start detection alerts (requires Log Analytics workspace)"
  type        = bool
  default     = true
}

variable "cold_start_threshold" {
  description = "Cold start count threshold (per 5-minute window)"
  type        = number
  default     = 5

  validation {
    condition     = var.cold_start_threshold >= 0
    error_message = "Cold start threshold must be greater than or equal to 0."
  }
}

variable "cold_start_alert_severity" {
  description = "Severity level for cold start alert (0-4, where 0 is critical)"
  type        = number
  default     = 3

  validation {
    condition     = var.cold_start_alert_severity >= 0 && var.cold_start_alert_severity <= 4
    error_message = "Alert severity must be between 0 and 4."
  }
}

variable "enable_exception_detection" {
  description = "Enable exception detection alerts (requires Log Analytics workspace)"
  type        = bool
  default     = true
}

variable "exception_rate_threshold" {
  description = "Exception rate threshold (count per 5-minute window)"
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

# Dashboard Configuration
variable "enable_function_dashboard" {
  description = "Enable Function App monitoring dashboard creation"
  type        = bool
  default     = true
}

variable "dashboard_display_name" {
  description = "Display name for the Function App monitoring dashboard"
  type        = string
  default     = null
}

variable "dashboard_time_range" {
  description = "Default time range for dashboard queries (in days)"
  type        = number
  default     = 7

  validation {
    condition     = var.dashboard_time_range > 0 && var.dashboard_time_range <= 90
    error_message = "Dashboard time range must be between 1 and 90 days."
  }
}

# Notification Configuration

# Feature Toggles
variable "enable_dependency_tracking" {
  description = "Enable dependency tracking in dashboard"
  type        = bool
  default     = true
}

variable "enable_performance_counters" {
  description = "Enable performance counter monitoring"
  type        = bool
  default     = true
}

variable "enable_custom_metrics" {
  description = "Enable custom metrics monitoring"
  type        = bool
  default     = false
}

# Advanced Configuration
