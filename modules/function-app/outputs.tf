# Azure Function App Module - Outputs
# This file defines all outputs from the Azure Function App module

#######################
# Function App Outputs
#######################


output "function_app_id" {
  description = "The ID of the Function App"
  value       = var.os_type == "Linux" ? azurerm_linux_function_app.main[0].id : null
}

output "function_app_name" {
  description = "The name of the Function App"
  value       = var.os_type == "Linux" ? azurerm_linux_function_app.main[0].name : null
}

output "function_app_default_hostname" {
  description = "The default hostname of the Function App"
  value       = var.os_type == "Linux" ? azurerm_linux_function_app.main[0].default_hostname : null
}

output "function_app_kind" {
  description = "The kind of the Function App"
  value       = var.os_type == "Linux" ? azurerm_linux_function_app.main[0].kind : null
}

output "function_app_outbound_ip_addresses" {
  description = "The outbound IP addresses of the Function App"
  value       = var.os_type == "Linux" ? azurerm_linux_function_app.main[0].outbound_ip_addresses : null
}

output "function_app_possible_outbound_ip_addresses" {
  description = "The possible outbound IP addresses of the Function App"
  value       = var.os_type == "Linux" ? azurerm_linux_function_app.main[0].possible_outbound_ip_addresses : null
}

output "function_app_site_credential" {
  description = "The site credentials for the Function App"
  value       = var.os_type == "Linux" ? azurerm_linux_function_app.main[0].site_credential : null
  sensitive   = true
}

output "function_app_custom_domain_verification_id" {
  description = "The custom domain verification ID for the Function App"
  value       = var.os_type == "Linux" ? azurerm_linux_function_app.main[0].custom_domain_verification_id : null
  sensitive   = true
}

output "function_app_hosting_environment_id" {
  description = "The hosting environment ID of the Function App"
  value       = var.os_type == "Linux" ? azurerm_linux_function_app.main[0].hosting_environment_id : null
}


#######################
# Storage Account Outputs
#######################

output "storage_account_primary_table_endpoint" {
  description = "The primary table endpoint for the storage account"
  value       = azurerm_storage_account.functions.primary_table_endpoint
}

output "storage_account_primary_file_endpoint" {
  description = "The primary file endpoint for the storage account"
  value       = azurerm_storage_account.functions.primary_file_endpoint
}

#######################
# Application Insights Outputs
#######################

output "application_insights_id" {
  description = "The ID of Application Insights"
  value       = var.enable_application_insights ? azurerm_application_insights.functions[0].id : null
}

output "application_insights_name" {
  description = "The name of Application Insights"
  value       = var.enable_application_insights ? azurerm_application_insights.functions[0].name : null
}

output "application_insights_instrumentation_key" {
  description = "The instrumentation key of Application Insights"
  value       = var.enable_application_insights ? azurerm_application_insights.functions[0].instrumentation_key : null
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "The connection string of Application Insights"
  value       = var.enable_application_insights ? azurerm_application_insights.functions[0].connection_string : null
  sensitive   = true
}

output "application_insights_app_id" {
  description = "The app ID of Application Insights"
  value       = var.enable_application_insights ? azurerm_application_insights.functions[0].app_id : null
}

#######################
# VNet Integration Outputs
#######################

output "vnet_integration_enabled" {
  description = "Whether VNet integration is enabled"
  value       = var.enable_vnet_integration
}

output "vnet_integration_subnet_id" {
  description = "The subnet ID used for VNet integration"
  value       = var.enable_vnet_integration ? var.vnet_integration_subnet_id : null
}


#######################
# Deployment Slots Outputs
#######################


output "deployment_slot_names" {
  description = "List of deployment slot names"
  value       = keys(var.deployment_slots)
}

output "deployment_slot_count" {
  description = "Number of deployment slots created"
  value       = length(var.deployment_slots)
}

#######################
# Configuration Outputs
#######################

output "runtime_configuration" {
  description = "Runtime configuration of the Function App"
  value = {
    os_type                     = var.os_type
    runtime_name                = var.runtime_name
    runtime_version             = var.runtime_version
    functions_extension_version = var.functions_extension_version
    use_dotnet_isolated_runtime = var.use_dotnet_isolated_runtime
  }
}

output "security_configuration" {
  description = "Security configuration of the Function App"
  value = {
    https_only                    = var.https_only
    public_network_access_enabled = var.public_network_access_enabled
    client_certificate_enabled    = var.client_certificate_enabled
    client_certificate_mode       = var.client_certificate_mode
    minimum_tls_version           = "1.2"
    scm_minimum_tls_version       = var.scm_minimum_tls_version
    ftps_state                    = "Disabled"
  }
}

output "performance_configuration" {
  description = "Performance configuration of the Function App"
  value = {
    always_on                 = var.always_on
    pre_warmed_instance_count = var.pre_warmed_instance_count
    elastic_instance_minimum  = var.elastic_instance_minimum
    function_app_scale_limit  = var.function_app_scale_limit
    worker_count              = var.worker_count
    use_32_bit_worker         = var.use_32_bit_worker
  }
}

output "network_configuration" {
  description = "Network configuration of the Function App"
  value = {
    enable_vnet_integration    = var.enable_vnet_integration
    vnet_integration_subnet_id = var.vnet_integration_subnet_id
    websockets_enabled         = var.websockets_enabled
    remote_debugging_enabled   = var.remote_debugging_enabled
    remote_debugging_version   = var.remote_debugging_version
    enable_cors                = var.enable_cors
    cors_allowed_origins       = var.cors_allowed_origins
    cors_support_credentials   = var.cors_support_credentials
  }
}

#######################
# Service Plan Information
#######################

output "service_plan_id" {
  description = "The ID of the App Service Plan used by the Function App"
  value       = var.service_plan_id
}

#######################
# Resource Information
#######################

output "resource_group_name" {
  description = "The name of the resource group"
  value       = var.resource_group_name
}

output "location" {
  description = "The Azure region where resources are deployed"
  value       = var.location
}

output "workload" {
  description = "The workload name"
  value       = var.workload
}

output "environment" {
  description = "The environment name"
  value       = var.environment
}

#######################
# Diagnostic Settings Outputs
#######################

output "diagnostic_settings_enabled" {
  description = "Whether diagnostic settings are enabled"
  value       = var.enable_diagnostic_settings
}


#######################
# Tags
#######################

output "tags" {
  description = "The tags applied to the resources"
  value       = var.tags
}

#######################
# Summary Output
#######################
