output "app_service_plan_id" {
  description = "The ID of the App Service Plan"
  value       = azurerm_service_plan.functions.id
}

output "app_service_plan_name" {
  description = "The name of the App Service Plan"
  value       = azurerm_service_plan.functions.name
}

output "app_service_plan_kind" {
  description = "The kind of App Service Plan"
  value       = azurerm_service_plan.functions.kind
}

output "app_service_plan_sku" {
  description = "The SKU of the App Service Plan"
  value       = azurerm_service_plan.functions.sku_name
}

output "app_service_plan_os_type" {
  description = "The operating system type of the App Service Plan"
  value       = azurerm_service_plan.functions.os_type
}
