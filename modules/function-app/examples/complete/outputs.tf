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

output "function_app_outbound_ip_addresses" {
  description = "The outbound IP addresses of the Function App"
  value       = module.function_app.function_app_outbound_ip_addresses
}

output "function_app_possible_outbound_ip_addresses" {
  description = "The possible outbound IP addresses of the Function App"
  value       = module.function_app.function_app_possible_outbound_ip_addresses
}

output "application_insights_id" {
  description = "The ID of Application Insights"
  value       = module.function_app.application_insights_id
}

output "application_insights_name" {
  description = "The name of Application Insights"
  value       = module.function_app.application_insights_name
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

output "application_insights_app_id" {
  description = "The app ID of Application Insights"
  value       = module.function_app.application_insights_app_id
}

output "vnet_integration_enabled" {
  description = "Whether VNet integration is enabled"
  value       = module.function_app.vnet_integration_enabled
}

output "vnet_integration_subnet_id" {
  description = "The subnet ID used for VNet integration"
  value       = module.function_app.vnet_integration_subnet_id
}

output "deployment_slot_names" {
  description = "List of deployment slot names"
  value       = module.function_app.deployment_slot_names
}

output "deployment_slot_count" {
  description = "Number of deployment slots created"
  value       = module.function_app.deployment_slot_count
}

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

output "diagnostic_settings_enabled" {
  description = "Whether diagnostic settings are enabled"
  value       = module.function_app.diagnostic_settings_enabled
}

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

output "function_app_summary" {
  description = "Summary of the Function App deployment"
  value       = module.function_app.function_app_summary
}

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
