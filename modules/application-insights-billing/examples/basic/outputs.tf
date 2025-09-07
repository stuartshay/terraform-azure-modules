# Basic Application Insights Billing Example - Outputs

# Budget Information
output "budget_names" {
  description = "Names of the created budgets"
  value       = module.app_insights_billing.budget_names
}

output "budget_summary" {
  description = "Summary of budget configuration"
  value       = module.app_insights_billing.budget_summary
}

# Dashboard Information
output "billing_dashboard_id" {
  description = "ID of the billing dashboard"
  value       = module.app_insights_billing.billing_dashboard_id
}

output "billing_dashboard_display_name" {
  description = "Display name of the billing dashboard"
  value       = module.app_insights_billing.billing_dashboard_display_name
}

# Configuration Summary
output "billing_configuration" {
  description = "Complete billing configuration summary"
  value       = module.app_insights_billing.billing_configuration
}

# Resource Information
output "resource_group_name" {
  description = "Name of the monitored resource group"
  value       = module.app_insights_billing.resource_group_name
}

output "application_insights_name" {
  description = "Name of the monitored Application Insights instance"
  value       = module.app_insights_billing.application_insights_name
}
