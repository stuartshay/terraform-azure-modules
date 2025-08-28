# Complete Function App Example - Outputs
# This file defines all outputs from the complete example

#######################
# Function App Outputs
#######################

output "function_app_id" {
  description = "The ID of the Function App"
  value       = module.function_app.function_app_id
}

output "function_app_name" {
  description = "The name of the Function App"
  value       = module.function_app.function_app_name
}

output "function_app_default_hostname" {
  description = "The default hostname of the Function App"
  value       = module.function_app.function_app_default_hostname
}

output "function_app_url" {
  description = "The URL of the Function App"
  value       = "https://${module.function_app.function_app_default_hostname}"
}

output "function_app_outbound_ip_addresses" {
  description = "The outbound IP addresses of the Function App"
  value       = module.function_app.function_app_outbound_ip_addresses
}

output "function_app_possible_outbound_ip_addresses" {
  description = "The possible outbound IP addresses of the Function App"
  value       = module.function_app.function_app_possible_outbound_ip_addresses
}

#######################
# Function App Identity Outputs
#######################

output "function_app_principal_id" {
  description = "The principal ID of the Function App's system-assigned managed identity"
  value       = module.function_app.function_app_principal_id
}

output "function_app_tenant_id" {
  description = "The tenant ID of the Function App's managed identity"
  value       = module.function_app.function_app_tenant_id
}

output "function_app_identity" {
  description = "The complete managed identity information of the Function App"
  value       = module.function_app.function_app_identity
}

output "user_assigned_identity_id" {
  description = "The ID of the user-assigned managed identity"
  value       = azurerm_user_assigned_identity.example.id
}

output "user_assigned_identity_principal_id" {
  description = "The principal ID of the user-assigned managed identity"
  value       = azurerm_user_assigned_identity.example.principal_id
}

#######################
# Storage Account Outputs
#######################

output "storage_account_id" {
  description = "The ID of the storage account"
  value       = module.function_app.storage_account_id
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = module.function_app.storage_account_name
}

output "storage_account_primary_blob_endpoint" {
  description = "The primary blob endpoint for the storage account"
  value       = module.function_app.storage_account_primary_blob_endpoint
}

output "storage_account_primary_queue_endpoint" {
  description = "The primary queue endpoint for the storage account"
  value       = module.function_app.storage_account_primary_queue_endpoint
}

output "storage_account_primary_table_endpoint" {
  description = "The primary table endpoint for the storage account"
  value       = module.function_app.storage_account_primary_table_endpoint
}

#######################
# App Service Plan Outputs
#######################

output "app_service_plan_id" {
  description = "The ID of the App Service Plan"
  value       = module.app_service_plan.app_service_plan_id
}

output "app_service_plan_name" {
  description = "The name of the App Service Plan"
  value       = module.app_service_plan.app_service_plan_name
}

output "app_service_plan_sku" {
  description = "The SKU of the App Service Plan"
  value       = module.app_service_plan.app_service_plan_sku
}

#######################
# Application Insights Outputs
#######################

output "application_insights_id" {
  description = "The ID of Application Insights"
  value       = module.function_app.application_insights_id
}

output "application_insights_name" {
  description = "The name of Application Insights"
  value       = module.function_app.application_insights_name
}

output "application_insights_app_id" {
  description = "The app ID of Application Insights"
  value       = module.function_app.application_insights_app_id
}

output "application_insights_instrumentation_key" {
  description = "The instrumentation key of Application Insights"
  value       = module.function_app.application_insights_instrumentation_key
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "The connection string of Application Insights"
  value       = module.function_app.application_insights_connection_string
  sensitive   = true
}

#######################
# Log Analytics Workspace Outputs
#######################

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.example.id
}

output "log_analytics_workspace_name" {
  description = "The name of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.example.name
}

output "log_analytics_workspace_workspace_id" {
  description = "The workspace ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.example.workspace_id
}

#######################
# Key Vault Outputs
#######################

output "key_vault_id" {
  description = "The ID of the Key Vault"
  value       = azurerm_key_vault.example.id
}

output "key_vault_name" {
  description = "The name of the Key Vault"
  value       = azurerm_key_vault.example.name
}

output "key_vault_uri" {
  description = "The URI of the Key Vault"
  value       = azurerm_key_vault.example.vault_uri
}

#######################
# VNet Integration Outputs
#######################

output "vnet_integration_enabled" {
  description = "Whether VNet integration is enabled"
  value       = module.function_app.vnet_integration_enabled
}

output "vnet_integration_subnet_id" {
  description = "The subnet ID used for VNet integration"
  value       = module.function_app.vnet_integration_subnet_id
}

output "vnet_integration_id" {
  description = "The ID of the VNet integration"
  value       = module.function_app.vnet_integration_id
}

#######################
# Deployment Slots Outputs
#######################

output "deployment_slots" {
  description = "Information about deployment slots"
  value       = module.function_app.deployment_slots
}

output "deployment_slot_names" {
  description = "List of deployment slot names"
  value       = module.function_app.deployment_slot_names
}

output "deployment_slot_count" {
  description = "Number of deployment slots created"
  value       = module.function_app.deployment_slot_count
}

#######################
# Configuration Outputs
#######################

output "runtime_configuration" {
  description = "Runtime configuration of the Function App"
  value       = module.function_app.runtime_configuration
}

output "security_configuration" {
  description = "Security configuration of the Function App"
  value       = module.function_app.security_configuration
}

output "performance_configuration" {
  description = "Performance configuration of the Function App"
  value       = module.function_app.performance_configuration
}

output "network_configuration" {
  description = "Network configuration of the Function App"
  value       = module.function_app.network_configuration
}

#######################
# Diagnostic Settings Outputs
#######################

output "diagnostic_settings_enabled" {
  description = "Whether diagnostic settings are enabled"
  value       = module.function_app.diagnostic_settings_enabled
}

output "diagnostic_settings_function_app_id" {
  description = "The ID of the Function App diagnostic settings"
  value       = module.function_app.diagnostic_settings_function_app_id
}

output "diagnostic_settings_storage_account_id" {
  description = "The ID of the storage account diagnostic settings"
  value       = module.function_app.diagnostic_settings_storage_account_id
}

#######################
# Resource Information
#######################

output "resource_group_name" {
  description = "The name of the resource group"
  value       = module.function_app.resource_group_name
}

output "location" {
  description = "The Azure region where resources are deployed"
  value       = module.function_app.location
}

output "workload" {
  description = "The workload name"
  value       = module.function_app.workload
}

output "environment" {
  description = "The environment name"
  value       = module.function_app.environment
}

#######################
# Summary Output
#######################

output "function_app_summary" {
  description = "Summary of the Function App deployment"
  value       = module.function_app.function_app_summary
}

output "deployment_summary" {
  description = "Complete deployment summary"
  value = {
    function_app = {
      name    = module.function_app.function_app_name
      url     = "https://${module.function_app.function_app_default_hostname}"
      runtime = "${module.function_app.runtime_configuration.runtime_name} ${module.function_app.runtime_configuration.runtime_version}"
      os_type = module.function_app.runtime_configuration.os_type
    }
    app_service_plan = {
      name = module.app_service_plan.app_service_plan_name
      sku  = module.app_service_plan.app_service_plan_sku
    }
    storage_account = {
      name = module.function_app.storage_account_name
    }
    application_insights = {
      name    = module.function_app.application_insights_name
      enabled = module.function_app.application_insights_id != null
    }
    log_analytics_workspace = {
      name = azurerm_log_analytics_workspace.example.name
    }
    key_vault = {
      name = azurerm_key_vault.example.name
      uri  = azurerm_key_vault.example.vault_uri
    }
    vnet_integration = {
      enabled   = module.function_app.vnet_integration_enabled
      subnet_id = module.function_app.vnet_integration_subnet_id
    }
    deployment_slots = {
      count = module.function_app.deployment_slot_count
      names = module.function_app.deployment_slot_names
    }
    security = {
      https_only                    = module.function_app.security_configuration.https_only
      public_network_access_enabled = module.function_app.security_configuration.public_network_access_enabled
      client_certificate_enabled    = module.function_app.security_configuration.client_certificate_enabled
      minimum_tls_version           = module.function_app.security_configuration.minimum_tls_version
    }
    monitoring = {
      diagnostic_settings_enabled  = module.function_app.diagnostic_settings_enabled
      application_insights_enabled = module.function_app.application_insights_id != null
    }
  }
}

#######################
# Access Information
#######################

output "access_information" {
  description = "Information for accessing and managing the Function App"
  value = {
    function_app_url = "https://${module.function_app.function_app_default_hostname}"
    scm_url          = "https://${module.function_app.function_app_default_hostname}/scm"
    azure_portal_url = "https://portal.azure.com/#@/resource${module.function_app.function_app_id}"

    deployment_slots = {
      for slot_name in module.function_app.deployment_slot_names :
      slot_name => {
        url              = "https://${module.function_app.function_app_default_hostname}-${slot_name}.azurewebsites.net"
        scm_url          = "https://${module.function_app.function_app_default_hostname}-${slot_name}.scm.azurewebsites.net"
        azure_portal_url = "https://portal.azure.com/#@/resource${module.function_app.function_app_id}/slots/${slot_name}"
      }
    }

    monitoring = {
      application_insights_url = module.function_app.application_insights_id != null ? "https://portal.azure.com/#@/resource${module.function_app.application_insights_id}" : null
      log_analytics_url        = "https://portal.azure.com/#@/resource${azurerm_log_analytics_workspace.example.id}"
    }

    key_vault_url = "https://portal.azure.com/#@/resource${azurerm_key_vault.example.id}"
  }
}
