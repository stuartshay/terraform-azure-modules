output "app_service_id" {
  description = "The ID of the App Service"
  value       = module.app_service.app_service_id
}

output "app_service_name" {
  description = "The name of the App Service"
  value       = module.app_service.app_service_name
}

output "app_service_default_hostname" {
  description = "The default hostname of the App Service"
  value       = module.app_service.app_service_default_hostname
}

output "app_service_plan_id" {
  description = "The ID of the App Service Plan"
  value       = module.app_service.app_service_plan_id
}

output "app_service_url" {
  description = "The HTTPS URL of the App Service"
  value       = "https://${module.app_service.app_service_default_hostname}"
}
