# Azure Container Instances Module - Outputs
# This file defines all outputs from the Azure Container Instances module

#######################
# Container Group Outputs
#######################

output "container_group_id" {
  description = "The ID of the Container Group"
  value       = azurerm_container_group.main.id
}

output "container_group_name" {
  description = "The name of the Container Group"
  value       = azurerm_container_group.main.name
}

output "container_group_location" {
  description = "The location of the Container Group"
  value       = azurerm_container_group.main.location
}

output "container_group_resource_group_name" {
  description = "The resource group name of the Container Group"
  value       = azurerm_container_group.main.resource_group_name
}

output "container_group_os_type" {
  description = "The OS type of the Container Group"
  value       = azurerm_container_group.main.os_type
}

output "container_group_restart_policy" {
  description = "The restart policy of the Container Group"
  value       = azurerm_container_group.main.restart_policy
}

#######################
# Network Outputs
#######################

output "ip_address" {
  description = "The IP address of the Container Group"
  value       = azurerm_container_group.main.ip_address
}

output "ip_address_type" {
  description = "The IP address type of the Container Group"
  value       = azurerm_container_group.main.ip_address_type
}

output "fqdn" {
  description = "The FQDN of the Container Group"
  value       = azurerm_container_group.main.fqdn
}

output "dns_name_label" {
  description = "The DNS name label of the Container Group"
  value       = azurerm_container_group.main.dns_name_label
}

output "exposed_ports" {
  description = "The exposed ports of the Container Group"
  value       = azurerm_container_group.main.exposed_port
}

#######################
# Container Outputs
#######################

output "containers" {
  description = "Information about the containers in the Container Group"
  value = [
    for container in azurerm_container_group.main.container : {
      name   = container.name
      image  = container.image
      cpu    = container.cpu
      memory = container.memory
      ports  = container.ports
    }
  ]
  sensitive = true
}

output "container_names" {
  description = "List of container names in the Container Group"
  value       = [for container in azurerm_container_group.main.container : container.name]
}

output "container_count" {
  description = "Number of containers in the Container Group"
  value       = length(azurerm_container_group.main.container)
}

#######################
# Identity Outputs
#######################

output "identity" {
  description = "The managed identity of the Container Group"
  value       = var.identity_type != null ? azurerm_container_group.main.identity : null
  sensitive   = true
}

output "principal_id" {
  description = "The principal ID of the Container Group's managed identity"
  value       = var.identity_type != null ? azurerm_container_group.main.identity[0].principal_id : null
  sensitive   = true
}

output "tenant_id" {
  description = "The tenant ID of the Container Group's managed identity"
  value       = var.identity_type != null ? azurerm_container_group.main.identity[0].tenant_id : null
  sensitive   = true
}

#######################
# Volume Outputs
#######################


#######################
# Registry Outputs
#######################

output "image_registry_credentials_count" {
  sensitive   = true
  description = "Number of image registry credentials configured"
  value       = length(var.image_registry_credentials)
}

output "registry_servers" {
  description = "List of registry servers configured"
  value       = [for cred in var.image_registry_credentials : cred.server]
  sensitive   = true
}

#######################
# Network Integration Outputs
#######################

output "vnet_integration_enabled" {
  description = "Whether VNet integration is enabled"
  value       = var.enable_vnet_integration
}

output "subnet_ids" {
  description = "The subnet IDs used for VNet integration"
  value       = var.enable_vnet_integration ? var.subnet_ids : null
}

#######################
# Configuration Outputs
#######################

output "runtime_configuration" {
  description = "Runtime configuration of the Container Group"
  value = {
    os_type        = azurerm_container_group.main.os_type
    restart_policy = azurerm_container_group.main.restart_policy
    priority       = var.priority
    zones          = var.zones
  }
}

output "network_configuration" {
  description = "Network configuration of the Container Group"
  value = {
    ip_address_type             = azurerm_container_group.main.ip_address_type
    ip_address                  = azurerm_container_group.main.ip_address
    fqdn                        = azurerm_container_group.main.fqdn
    dns_name_label              = azurerm_container_group.main.dns_name_label
    dns_name_label_reuse_policy = var.dns_name_label_reuse_policy
    enable_vnet_integration     = var.enable_vnet_integration
    subnet_ids                  = var.subnet_ids
  }
}

output "security_configuration" {
  description = "Security configuration of the Container Group"
  value = {
    identity_type                    = var.identity_type
    identity_ids                     = var.identity_ids
    image_registry_credentials_count = length(var.image_registry_credentials)
    secure_environment_variables_configured = anytrue([
      for container in var.containers : length(container.secure_environment_variables) > 0
    ])
  }
  sensitive = true
}

output "monitoring_configuration" {
  description = "Monitoring configuration of the Container Group"
  value = {
    diagnostic_settings_enabled = var.enable_diagnostic_settings
    log_analytics_workspace_id  = var.log_analytics_workspace_id
    diagnostic_logs             = var.diagnostic_logs
    diagnostic_metrics          = var.diagnostic_metrics
  }
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

output "diagnostic_settings_id" {
  description = "The ID of the diagnostic settings"
  value       = var.enable_diagnostic_settings && var.log_analytics_workspace_id != null ? azurerm_monitor_diagnostic_setting.container_group[0].id : null
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

output "container_group_summary" {
  description = "Summary of the Container Group deployment"
  value = {
    name                = azurerm_container_group.main.name
    id                  = azurerm_container_group.main.id
    location            = azurerm_container_group.main.location
    resource_group_name = azurerm_container_group.main.resource_group_name
    os_type             = azurerm_container_group.main.os_type
    restart_policy      = azurerm_container_group.main.restart_policy
    ip_address_type     = azurerm_container_group.main.ip_address_type
    ip_address          = azurerm_container_group.main.ip_address
    fqdn                = azurerm_container_group.main.fqdn
    container_count     = length(azurerm_container_group.main.container)
    identity_enabled    = var.identity_type != null
    vnet_integration    = var.enable_vnet_integration
    diagnostics_enabled = var.enable_diagnostic_settings
    workload            = var.workload
    environment         = var.environment
  }
}
