output "function_app_name" {
  description = "The name of the Function App"
  value       = module.function_app.function_app_name
}

output "function_app_id" {
  description = "The ID of the Function App"
  value       = module.function_app.function_app_id
}

output "function_app_default_hostname" {
  description = "The default hostname of the Function App"
  value       = module.function_app.function_app_default_hostname
}

output "storage_account_name" {
  description = "The name of the Functions storage account"
  value       = module.function_app.storage_account_name
}

output "storage_account_id" {
  description = "The ID of the Functions storage account"
  value       = module.function_app.storage_account_id
}

output "app_service_plan_id" {
  description = "The ID of the App Service Plan"
  value       = module.function_app.app_service_plan_id
}

output "application_insights_id" {
  description = "The ID of Application Insights"
  value       = module.function_app.application_insights_id
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.example.name
}

output "virtual_network_id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.example.id
}

output "subnet_id" {
  description = "The ID of the functions subnet"
  value       = azurerm_subnet.functions.id
}
