# Complete Function App Example - Variables
# This file defines all input variables for the complete example

#######################
# Required Variables
#######################

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

variable "virtual_network_name" {
  description = "The name of the existing virtual network"
  type        = string
  default     = "vnet-example-dev-001"
}

variable "subnet_name" {
  description = "The name of the existing subnet for VNet integration"
  type        = string
  default     = "snet-functions-dev-001"
}

#######################
# App Service Plan Configuration
#######################

variable "app_service_plan_sku" {
  description = "The SKU for the App Service Plan"
  type        = string
  default     = "EP1"

  validation {
    condition     = contains(["EP1", "EP2", "EP3"], var.app_service_plan_sku)
    error_message = "App Service Plan SKU must be EP1, EP2, or EP3."
  }
}

variable "maximum_elastic_worker_count" {
  description = "Maximum number of elastic workers for the App Service Plan"
  type        = number
  default     = 10

  validation {
    condition     = var.maximum_elastic_worker_count >= 1 && var.maximum_elastic_worker_count <= 20
    error_message = "Maximum elastic worker count must be between 1 and 20."
  }
}

#######################
# Function App Configuration
#######################

variable "os_type" {
  description = "The operating system type for the Function App"
  type        = string
  default     = "Linux"

  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "OS type must be either 'Linux' or 'Windows'."
  }
}

variable "runtime_name" {
  description = "The runtime name for the Function App"
  type        = string
  default     = "python"

  validation {
    condition     = contains(["python", "node", "dotnet", "java", "powershell"], var.runtime_name)
    error_message = "Runtime name must be one of: python, node, dotnet, java, powershell."
  }
}

variable "runtime_version" {
  description = "The runtime version for the Function App"
  type        = string
  default     = "3.11"
}

variable "use_dotnet_isolated_runtime" {
  description = "Whether to use .NET isolated runtime"
  type        = bool
  default     = false
}

#######################
# Security Configuration
#######################

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled for the Function App"
  type        = bool
  default     = false
}

variable "client_certificate_enabled" {
  description = "Whether client certificates are enabled"
  type        = bool
  default     = true
}

variable "client_certificate_mode" {
  description = "The client certificate mode"
  type        = string
  default     = "Optional"

  validation {
    condition     = contains(["Required", "Optional"], var.client_certificate_mode)
    error_message = "Client certificate mode must be 'Required' or 'Optional'."
  }
}

#######################
# Performance Configuration
#######################

variable "pre_warmed_instance_count" {
  description = "The number of pre-warmed instances for Premium plans"
  type        = number
  default     = 2

  validation {
    condition     = var.pre_warmed_instance_count >= 0 && var.pre_warmed_instance_count <= 20
    error_message = "Pre-warmed instance count must be between 0 and 20."
  }
}

variable "elastic_instance_minimum" {
  description = "The minimum number of elastic instances for Premium plans"
  type        = number
  default     = 1

  validation {
    condition     = var.elastic_instance_minimum >= 0 && var.elastic_instance_minimum <= 20
    error_message = "Elastic instance minimum must be between 0 and 20."
  }
}

variable "function_app_scale_limit" {
  description = "The maximum number of instances for the Function App"
  type        = number
  default     = 100

  validation {
    condition     = var.function_app_scale_limit >= 1 && var.function_app_scale_limit <= 1000
    error_message = "Function app scale limit must be between 1 and 1000."
  }
}

variable "worker_count" {
  description = "The number of workers for the Function App"
  type        = number
  default     = 1

  validation {
    condition     = var.worker_count >= 1 && var.worker_count <= 10
    error_message = "Worker count must be between 1 and 10."
  }
}

variable "health_check_path" {
  description = "The health check path for the Function App"
  type        = string
  default     = "/api/health"
}

#######################
# Network Configuration
#######################

variable "enable_vnet_integration" {
  description = "Whether to enable VNet integration for the Function App"
  type        = bool
  default     = true
}

variable "websockets_enabled" {
  description = "Whether WebSockets are enabled"
  type        = bool
  default     = false
}

variable "enable_cors" {
  description = "Whether to enable CORS"
  type        = bool
  default     = true
}

variable "cors_allowed_origins" {
  description = "The allowed origins for CORS"
  type        = list(string)
  default = [
    "https://portal.azure.com",
    "https://ms.portal.azure.com"
  ]
}

variable "cors_support_credentials" {
  description = "Whether CORS should support credentials"
  type        = bool
  default     = false
}

variable "ip_restrictions" {
  description = "List of IP restrictions for the Function App"
  type = list(object({
    ip_address                = optional(string)
    service_tag               = optional(string)
    virtual_network_subnet_id = optional(string)
    name                      = string
    priority                  = number
    action                    = string
    headers = optional(object({
      x_azure_fdid      = optional(list(string))
      x_fd_health_probe = optional(list(string))
      x_forwarded_for   = optional(list(string))
      x_forwarded_host  = optional(list(string))
    }))
  }))
  default = [
    {
      name        = "AllowAzurePortal"
      service_tag = "AzurePortal"
      priority    = 100
      action      = "Allow"
    }
  ]
}

variable "scm_ip_restrictions" {
  description = "List of SCM IP restrictions for the Function App"
  type = list(object({
    ip_address                = optional(string)
    service_tag               = optional(string)
    virtual_network_subnet_id = optional(string)
    name                      = string
    priority                  = number
    action                    = string
    headers = optional(object({
      x_azure_fdid      = optional(list(string))
      x_fd_health_probe = optional(list(string))
      x_forwarded_for   = optional(list(string))
      x_forwarded_host  = optional(list(string))
    }))
  }))
  default = [
    {
      name        = "AllowAzurePortal"
      service_tag = "AzurePortal"
      priority    = 100
      action      = "Allow"
    }
  ]
}

#######################
# Storage Configuration
#######################

variable "storage_public_network_access_enabled" {
  description = "Whether public network access is enabled for the storage account"
  type        = bool
  default     = false
}

variable "enable_storage_network_rules" {
  description = "Whether to enable network rules for the storage account"
  type        = bool
  default     = true
}

#######################
# App Settings and Configuration
#######################

variable "app_settings" {
  description = "Additional app settings for the Function App"
  type        = map(string)
  default = {
    "CUSTOM_SETTING" = "example_value"
    "FEATURE_FLAGS"  = "enabled"
    "API_VERSION"    = "v1"
  }
}

variable "connection_strings" {
  description = "Connection strings for the Function App"
  type = list(object({
    name  = string
    type  = string
    value = string
  }))
  default = []
}

variable "database_connection_string" {
  description = "Database connection string to store in Key Vault"
  type        = string
  default     = "Server=tcp:example.database.windows.net,1433;Database=example;User ID=admin;Password=SecurePassword123!;Encrypt=true;TrustServerCertificate=false;Connection Timeout=30;"
  sensitive   = true
}

#######################
# Deployment Slots Configuration
#######################

variable "deployment_slots" {
  description = "Map of deployment slots to create"
  type = map(object({
    public_network_access_enabled = optional(bool, true)
    app_settings                  = optional(map(string), {})
  }))
  default = {
    staging = {
      public_network_access_enabled = false
      app_settings = {
        "SLOT_NAME"   = "staging"
        "ENVIRONMENT" = "staging"
        "DEBUG_MODE"  = "true"
        "LOG_LEVEL"   = "DEBUG"
      }
    }
    testing = {
      public_network_access_enabled = false
      app_settings = {
        "SLOT_NAME"     = "testing"
        "ENVIRONMENT"   = "testing"
        "DEBUG_MODE"    = "true"
        "LOG_LEVEL"     = "DEBUG"
        "FEATURE_FLAGS" = "experimental"
      }
    }
  }
}

#######################
# Authentication Configuration
#######################

variable "enable_auth_settings" {
  description = "Whether to enable authentication settings"
  type        = bool
  default     = false
}

variable "auth_settings_default_provider" {
  description = "The default authentication provider"
  type        = string
  default     = "AzureActiveDirectory"

  validation {
    condition     = contains(["AzureActiveDirectory", "Facebook", "Google", "MicrosoftAccount", "Twitter"], var.auth_settings_default_provider)
    error_message = "Auth settings default provider must be one of the supported providers."
  }
}

variable "auth_settings_unauthenticated_client_action" {
  description = "The action to take for unauthenticated clients"
  type        = string
  default     = "RedirectToLoginPage"

  validation {
    condition     = contains(["RedirectToLoginPage", "AllowAnonymous"], var.auth_settings_unauthenticated_client_action)
    error_message = "Auth settings unauthenticated client action must be 'RedirectToLoginPage' or 'AllowAnonymous'."
  }
}

variable "auth_settings_token_store_enabled" {
  description = "Whether token store is enabled"
  type        = bool
  default     = false
}

variable "auth_settings_active_directory" {
  description = "Active Directory authentication settings"
  type = object({
    client_id         = string
    client_secret     = string
    allowed_audiences = optional(list(string), [])
  })
  default = null
}

#######################
# Backup Configuration
#######################

variable "enable_backup" {
  description = "Whether to enable backup for the Function App"
  type        = bool
  default     = false
}

variable "backup_storage_account_url" {
  description = "The storage account URL for backups"
  type        = string
  default     = null
}

#######################
# Tags and Metadata
#######################

variable "cost_center" {
  description = "Cost center for resource billing"
  type        = string
  default     = "engineering"
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "platform-team"
}
