# Basic Application Insights Example - Outputs

output "application_insights_id" {
  description = "ID of the Application Insights instance"
  value       = module.application_insights.id
}

output "application_insights_name" {
  description = "Name of the Application Insights instance"
  value       = module.application_insights.name
}

output "instrumentation_key" {
  description = "Application Insights instrumentation key"
  value       = module.application_insights.instrumentation_key
  sensitive   = true
}

output "connection_string" {
  description = "Application Insights connection string"
  value       = module.application_insights.connection_string
  sensitive   = true
}

output "app_id" {
  description = "Application Insights App ID"
  value       = module.application_insights.app_id
}

output "smart_detection_rule_ids" {
  description = "Smart detection rule IDs"
  value       = module.application_insights.smart_detection_rule_ids
}

output "configuration" {
  description = "Application Insights configuration summary"
  value       = module.application_insights.configuration
}
