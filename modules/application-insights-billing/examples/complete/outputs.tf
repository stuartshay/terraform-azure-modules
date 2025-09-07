# Complete Application Insights Billing Example - Outputs

# Budget Information
output "budget_names" {
  description = "Names of the created budgets"
  value       = module.app_insights_billing.budget_names
}

output "budget_summary" {
  description = "Summary of budget configuration"
  value       = module.app_insights_billing.budget_summary
}

output "monthly_budget_id" {
  description = "ID of the monthly budget"
  value       = module.app_insights_billing.monthly_budget_id
}

output "quarterly_budget_id" {
  description = "ID of the quarterly budget"
  value       = module.app_insights_billing.quarterly_budget_id
}

output "annual_budget_id" {
  description = "ID of the annual budget"
  value       = module.app_insights_billing.annual_budget_id
}

# Alert Information
output "alert_rule_names" {
  description = "Names of the created alert rules"
  value       = module.app_insights_billing.alert_rule_names
}

output "alert_summary" {
  description = "Summary of alert configuration"
  value       = module.app_insights_billing.alert_summary
}

output "daily_cost_alert_id" {
  description = "ID of the daily cost alert rule"
  value       = module.app_insights_billing.daily_cost_alert_id
}

output "cost_anomaly_alert_id" {
  description = "ID of the cost anomaly alert rule"
  value       = module.app_insights_billing.cost_anomaly_alert_id
}

# Dashboard Information
output "billing_dashboard_id" {
  description = "ID of the billing dashboard"
  value       = module.app_insights_billing.billing_dashboard_id
}

output "billing_dashboard_name" {
  description = "Name of the billing dashboard"
  value       = module.app_insights_billing.billing_dashboard_name
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

output "resource_group_id" {
  description = "ID of the monitored resource group"
  value       = module.app_insights_billing.resource_group_id
}

output "application_insights_name" {
  description = "Name of the monitored Application Insights instance"
  value       = module.app_insights_billing.application_insights_name
}

output "application_insights_id" {
  description = "ID of the monitored Application Insights instance"
  value       = module.app_insights_billing.application_insights_id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace"
  value       = module.app_insights_billing.log_analytics_workspace_name
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics Workspace"
  value       = module.app_insights_billing.log_analytics_workspace_id
}

# Additional Resources Created in Example
output "example_storage_account_name" {
  description = "Name of the example storage account"
  value       = azurerm_storage_account.example.name
}

output "example_service_plan_name" {
  description = "Name of the example service plan"
  value       = azurerm_service_plan.example.name
}

output "action_group_id" {
  description = "ID of the example action group"
  value       = azurerm_monitor_action_group.billing_alerts.id
}

# URLs and Access Information
output "azure_portal_links" {
  description = "Useful Azure Portal links for cost management"
  value = {
    cost_management = "https://portal.azure.com/#view/Microsoft_Azure_CostManagement/Menu/~/overview"
    budgets         = "https://portal.azure.com/#view/Microsoft_Azure_CostManagement/Menu/~/budgets"
    cost_analysis   = "https://portal.azure.com/#view/Microsoft_Azure_CostManagement/Menu/~/costanalysis"
    resource_group  = "https://portal.azure.com/#@/resource/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${azurerm_resource_group.example.name}/overview"
  }
}

# Current Azure context
data "azurerm_client_config" "current" {}
