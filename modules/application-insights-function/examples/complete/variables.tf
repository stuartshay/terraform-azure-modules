# Variables for the complete Application Insights Function monitoring example

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "East US"
}

variable "workload" {
  description = "The name of the workload"
  type        = string
  default     = "example"
}

variable "environment" {
  description = "The environment (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "function_app_names" {
  description = "List of Function App names to create and monitor"
  type        = list(string)
  default     = ["func-api", "func-processor", "func-scheduler"]
}

# Alert threshold variables
variable "function_duration_threshold_ms" {
  description = "Function execution duration threshold in milliseconds"
  type        = number
  default     = 30000
}

variable "function_failure_rate_threshold" {
  description = "Function failure rate threshold percentage"
  type        = number
  default     = 5
}

variable "cpu_threshold_percent" {
  description = "App Service Plan CPU usage threshold percentage"
  type        = number
  default     = 80
}

variable "memory_threshold_percent" {
  description = "App Service Plan memory usage threshold percentage"
  type        = number
  default     = 85
}

variable "cold_start_threshold" {
  description = "Cold start count threshold for alerting"
  type        = number
  default     = 5
}

variable "exception_rate_threshold" {
  description = "Exception rate threshold for alerting"
  type        = number
  default     = 10
}

# Alert severity variables
variable "function_duration_alert_severity" {
  description = "Severity level for function duration alerts (0-4)"
  type        = number
  default     = 2
}

variable "function_failure_alert_severity" {
  description = "Severity level for function failure alerts (0-4)"
  type        = number
  default     = 1
}

variable "app_service_cpu_alert_severity" {
  description = "Severity level for App Service Plan CPU alerts (0-4)"
  type        = number
  default     = 2
}

variable "app_service_memory_alert_severity" {
  description = "Severity level for App Service Plan memory alerts (0-4)"
  type        = number
  default     = 2
}

variable "cold_start_alert_severity" {
  description = "Severity level for cold start alerts (0-4)"
  type        = number
  default     = 3
}

variable "exception_alert_severity" {
  description = "Severity level for exception alerts (0-4)"
  type        = number
  default     = 1
}

# Dashboard configuration
variable "dashboard_display_name" {
  description = "Display name for the monitoring dashboard"
  type        = string
  default     = null
}

variable "dashboard_time_range" {
  description = "Time range for dashboard queries in days"
  type        = number
  default     = 7
}

# Low activity monitoring
variable "function_min_invocations_threshold" {
  description = "Minimum function invocations threshold for low activity alerts"
  type        = number
  default     = 10
}

variable "function_activity_alert_severity" {
  description = "Severity level for function low activity alerts (0-4)"
  type        = number
  default     = 3
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "function-monitoring"
    ManagedBy   = "terraform"
  }
}
