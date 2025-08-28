# Azure Function App Module - Outputs
# This file defines all outputs from the Azure Function App module

#######################
# Function App Outputs
#######################

output "function_app_id" {
  description = "The ID of the Function App"
  value       = var.os_type == "Linux" ? azurerm_linux_function_app.main[0].id : azurerm_windows_function_app.main[0].id
}

output "function_app_name" {
  description = "The name of the Function App"
  value       = var.os_type == "Linux" ? azurerm_linux_function_app.main[0].name : azurerm_windows_function_app.main[0].name
}

output "function_app_default_hostname" {
  description = "The default hostname of the Function App"
  value       = var.os_type == "Linux" ? azurerm_linux_function_app.main[0].default_hostname : azurerm_windows_function_app.main[0].default_hostname
}

output "function_app_kind" {
  description = "The kind of the Function App"
  value       = var.os_type == "Linux" ? azurerm_linux_function_app.main[0].kind : azurerm_windows_function_app.main[0].kind
}

output "function_app_outbound_ip_addresses" {
  description = "The outbound IP addresses of the Function App"
  value       = var.os_type == "Linux" ? azurerm_linux_function_app.main[0].outbound_ip_addresses : azurerm_windows_function_app.main[0].outbound_ip_addresses
}

output "function_app_possible_outbound_ip_addresses" {
  description = "The possible outbound IP addresses of the Function App"
  value       = var.os_type == "Linux" ? azurerm_linux_function_app.main[0].possible_outbound_ip_addresses : azurerm_windows_function_app.main[0].possible_outbound_ip_addresses
}

output "function_app_site_credential" {
  description = "The site credentials for the Function App"
  value       = var.os_type == "Linux" ? azurerm_linux_function_app.main[0].site_credential : azurerm_windows_function_app.main[0].site_credential
  sensitive   = true
}

output "function_app_custom_domain_verification_id" {
  description = "The custom domain verification ID for the Function App"
  value       = var.os_type == "Linux" ? azurerm_linux_function_app.main[0].custom_domain_verification_id : azurerm_windows_function_app.main[0].custom_domain_verification_id
}

output "function_app_hosting_environment_id" {
  description = "The hosting environment ID of the Function App"
  value       = var.os_type == "Linux" ? azurerm_linux_function_app.main[0].hosting_environment_id : azurerm_windows_function_app.main[0].hosting_environment_id
}

#######################
# Function App Identity Outputs
#######################

output "function_app_identity" {
  description = "The managed identity of the Function App"
  value = var.identity_type != null ? {
    type         = var.os_type == "Linux" ? azurerm_linux_function_app.main[0].identity[0].type : azurerm_windows_function_app.main[0].identity[0].type
    principal_id = var.os_type == "Linux" ? azurerm_linux_function_app.main[0].identity[0].principal_id : azurerm_windows_function_app.main[0].identity[0].principal_id
    tenant_id    = var.os_type == "Linux" ? azurerm_linux_function_app.main[0].identity[0].tenant_id : azurerm_windows_function_app.main[0].identity[0].tenant_id
    identity_ids = var.os_type == "Linux" ? azurerm_linux_function_app.main[0].identity[0].identity_ids : azurerm_windows_function_app.main[0].identity[0].identity_ids
  } : null
}

output "function_app_principal_id" {
  description = "The principal ID of the Function App's managed identity"
  value       = var.identity_type != null ? (var.os_type == "Linux" ? azurerm_linux_function_app.main[0].identity[0].principal_id : azurerm_windows_function_app.main[0].identity[0].principal_id) : null
}

output "function_app_tenant_id" {
  description = "The tenant ID of the Function App's managed identity"
  value       = var.identity_type != null ? (var.os_type == "Linux" ? azurerm_linux_function_app.main[0].identity[0].tenant_id : azurerm_windows_function_app.main[0].identity[0].tenant_id) : null
}

#######################
# Storage Account Outputs
#######################

output "storage_account_id" {
  description = "The ID of the storage account"
  value       = azurerm_storage_account.functions.id
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = azurerm_storage_account.functions.name
}

output "storage_account_primary_access_key" {
  description = "The primary access key for the storage account"
  value       = azurerm_storage_account.functions.primary_access_key
  sensitive   = true
}

output "storage_account_secondary_access_key" {
  description = "The secondary access key for the storage account"
  value       = azurerm_storage_account.functions.secondary_access_key
  sensitive   = true
}

output "storage_account_primary_connection_string" {
  description = "The primary connection string for the storage account"
  value       = azurerm_storage_account.functions.primary_connection_string
  sensitive   = true
}

output "storage_account_secondary_connection_string" {
  description = "The secondary connection string for the storage account"
  value       = azurerm_storage_account.functions.secondary_connection_string
  sensitive   = true
}

output "storage_account_primary_blob_endpoint" {
  description = "The primary blob endpoint for the storage account"
  value       = azurerm_storage_account.functions.primary_blob_endpoint
}

output "storage_account_primary_queue_endpoint" {
  description = "The primary queue endpoint for the storage account"
  value       = azurerm_storage_account.functions.primary_queue_endpoint
}

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

output "vnet_integration_id" {
  description = "The ID of the VNet integration"
  value       = var.enable_vnet_integration ? azurerm_app_service_virtual_network_swift_connection.main[0].id : null
}

#######################
# Deployment Slots Outputs
#######################

output "deployment_slots" {
  description = "Information about deployment slots"
  value = var.os_type == "Linux" ? {
    for slot_name, slot in azurerm_linux_function_app_slot.main :
    slot_name => {
      id                             = slot.id
      name                           = slot.name
      default_hostname               = slot.default_hostname
      kind                           = slot.kind
      outbound_ip_addresses          = slot.outbound_ip_addresses
      possible_outbound_ip_addresses = slot.possible_outbound_ip_addresses
    }
    } : {
    for slot_name, slot in azurerm_windows_function_app_slot.main :
    slot_name => {
      id                             = slot.id
      name                           = slot.name
      default_hostname               = slot.default_hostname
      kind                           = slot.kind
      outbound_ip_addresses          = slot.outbound_ip_addresses
      possible_outbound_ip_addresses = slot.possible_outbound_ip_addresses
    }
  }
}

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
    minimum_tls_version           = var.minimum_tls_version
    scm_minimum_tls_version       = var.scm_minimum_tls_version
    ftps_state                    = var.ftps_state
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

output "diagnostic_settings_function_app_id" {
  description = "The ID of the Function App diagnostic settings"
  value       = var.enable_diagnostic_settings ? azurerm_monitor_diagnostic_setting.function_app[0].id : null
}

output "diagnostic_settings_storage_account_id" {
  description = "The ID of the storage account diagnostic settings"
  value       = var.enable_diagnostic_settings ? azurerm_monitor_diagnostic_setting.storage_account[0].id : null
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

output "function_app_summary" {
  description = "Summary of the Function App deployment"
  value = {
    function_app_name            = var.os_type == "Linux" ? azurerm_linux_function_app.main[0].name : azurerm_windows_function_app.main[0].name
    function_app_id              = var.os_type == "Linux" ? azurerm_linux_function_app.main[0].id : azurerm_windows_function_app.main[0].id
    default_hostname             = var.os_type == "Linux" ? azurerm_linux_function_app.main[0].default_hostname : azurerm_windows_function_app.main[0].default_hostname
    storage_account_name         = azurerm_storage_account.functions.name
    application_insights_enabled = var.enable_application_insights
    vnet_integration_enabled     = var.enable_vnet_integration
    deployment_slots_count       = length(var.deployment_slots)
    runtime_stack = {
      os_type         = var.os_type
      runtime_name    = var.runtime_name
      runtime_version = var.runtime_version
    }
    security = {
      https_only                    = var.https_only
      public_network_access_enabled = var.public_network_access_enabled
      minimum_tls_version           = var.minimum_tls_version
    }
  }
}
