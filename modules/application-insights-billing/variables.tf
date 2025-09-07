# Application Insights Billing Module - Variables
# This file defines all input variables for the application insights billing module

# Required Variables
variable "resource_group_name" {
  description = "Name of the resource group to monitor billing for"
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
  description = "Name of the Log Analytics Workspace (optional, for advanced cost queries)"
  type        = string
  default     = null
}

# Budget Configuration
variable "enable_budget_monitoring" {
  description = "Enable budget monitoring and alerts"
  type        = bool
  default     = true
}

variable "monthly_budget_amount" {
  description = "Monthly budget amount in USD"
  type        = number
  default     = 1000

  validation {
    condition     = var.monthly_budget_amount >= 0
    error_message = "Monthly budget amount must be greater than or equal to 0."
  }
}

variable "quarterly_budget_amount" {
  description = "Quarterly budget amount in USD"
  type        = number
  default     = 3000

  validation {
    condition     = var.quarterly_budget_amount >= 0
    error_message = "Quarterly budget amount must be greater than or equal to 0."
  }
}

variable "annual_budget_amount" {
  description = "Annual budget amount in USD"
  type        = number
  default     = 12000

  validation {
    condition     = var.annual_budget_amount >= 0
    error_message = "Annual budget amount must be greater than or equal to 0."
  }
}

variable "budget_end_date" {
  description = "End date for budgets in RFC3339 format (optional, defaults to 1 year from now)"
  type        = string
  default     = null
}

variable "budget_alert_thresholds" {
  description = "List of budget alert thresholds as percentages (e.g., [80, 90, 100])"
  type        = list(number)
  default     = [80, 90, 100]

  validation {
    condition = alltrue([
      for threshold in var.budget_alert_thresholds : threshold > 0 && threshold <= 200
    ])
    error_message = "Budget alert thresholds must be between 1 and 200."
  }
}

variable "budget_forecast_thresholds" {
  description = "List of budget forecast alert thresholds as percentages (e.g., [100, 110])"
  type        = list(number)
  default     = [100, 110]

  validation {
    condition = alltrue([
      for threshold in var.budget_forecast_thresholds : threshold > 0 && threshold <= 200
    ])
    error_message = "Budget forecast thresholds must be between 1 and 200."
  }
}

variable "enable_forecast_alerts" {
  description = "Enable forecast-based budget alerts"
  type        = bool
  default     = true
}

variable "budget_notification_emails" {
  description = "List of email addresses to notify when budget thresholds are exceeded"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for email in var.budget_notification_emails : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))
    ])
    error_message = "All budget notification emails must be valid email addresses."
  }
}

# Cost Alert Configuration
variable "enable_cost_alerts" {
  description = "Enable cost-based alerts (requires Log Analytics workspace)"
  type        = bool
  default     = true
}

variable "daily_spend_threshold" {
  description = "Daily spending threshold in USD for cost alerts"
  type        = number
  default     = 50

  validation {
    condition     = var.daily_spend_threshold >= 0
    error_message = "Daily spend threshold must be greater than or equal to 0."
  }
}

variable "daily_cost_alert_severity" {
  description = "Severity level for daily cost alert (0-4, where 0 is critical)"
  type        = number
  default     = 2

  validation {
    condition     = var.daily_cost_alert_severity >= 0 && var.daily_cost_alert_severity <= 4
    error_message = "Alert severity must be between 0 and 4."
  }
}

# Anomaly Detection Configuration
variable "enable_anomaly_detection" {
  description = "Enable cost anomaly detection alerts"
  type        = bool
  default     = true
}

variable "cost_anomaly_sensitivity" {
  description = "Sensitivity for cost anomaly detection (standard deviations from mean)"
  type        = number
  default     = 2

  validation {
    condition     = var.cost_anomaly_sensitivity > 0 && var.cost_anomaly_sensitivity <= 5
    error_message = "Cost anomaly sensitivity must be between 0 and 5."
  }
}

variable "anomaly_alert_severity" {
  description = "Severity level for anomaly detection alert (0-4, where 0 is critical)"
  type        = number
  default     = 1

  validation {
    condition     = var.anomaly_alert_severity >= 0 && var.anomaly_alert_severity <= 4
    error_message = "Alert severity must be between 0 and 4."
  }
}

# Cost Filtering Configuration
variable "cost_filter_resource_types" {
  description = "List of resource types to include in cost monitoring (empty list means all types)"
  type        = list(string)
  default     = []
}

variable "cost_filter_tags" {
  description = "Map of tag filters for cost monitoring (tag_name = [tag_values])"
  type        = map(list(string))
  default     = {}
}

# Dashboard Configuration
variable "enable_billing_dashboard" {
  description = "Enable billing dashboard creation"
  type        = bool
  default     = true
}

variable "dashboard_display_name" {
  description = "Display name for the billing dashboard"
  type        = string
  default     = null
}
