# basic

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.13.1 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.42.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.42.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_app_insights_function"></a> [app\_insights\_function](#module\_app\_insights\_function) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_application_insights.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights) | resource |
| [azurerm_linux_function_app.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_service_plan.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |
| [azurerm_storage_account.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alert_rule_names"></a> [alert\_rule\_names](#output\_alert\_rule\_names) | Names of the created alert rules |
| <a name="output_alert_summary"></a> [alert\_summary](#output\_alert\_summary) | Summary of configured alerts |
| <a name="output_app_service_alert_names"></a> [app\_service\_alert\_names](#output\_app\_service\_alert\_names) | Names of the App Service Plan alert rules |
| <a name="output_app_service_cpu_alert_ids"></a> [app\_service\_cpu\_alert\_ids](#output\_app\_service\_cpu\_alert\_ids) | IDs of the App Service Plan CPU alert rules |
| <a name="output_app_service_memory_alert_ids"></a> [app\_service\_memory\_alert\_ids](#output\_app\_service\_memory\_alert\_ids) | IDs of the App Service Plan memory alert rules |
| <a name="output_application_insights_name"></a> [application\_insights\_name](#output\_application\_insights\_name) | Name of the monitored Application Insights instance |
| <a name="output_dashboard_summary"></a> [dashboard\_summary](#output\_dashboard\_summary) | Summary of dashboard configuration |
| <a name="output_example_app_service_plan_name"></a> [example\_app\_service\_plan\_name](#output\_example\_app\_service\_plan\_name) | Name of the example App Service Plan |
| <a name="output_example_application_insights_name"></a> [example\_application\_insights\_name](#output\_example\_application\_insights\_name) | Name of the example Application Insights instance |
| <a name="output_example_function_app_name"></a> [example\_function\_app\_name](#output\_example\_function\_app\_name) | Name of the example Function App |
| <a name="output_feature_flags"></a> [feature\_flags](#output\_feature\_flags) | Summary of enabled features |
| <a name="output_function_dashboard_display_name"></a> [function\_dashboard\_display\_name](#output\_function\_dashboard\_display\_name) | Display name of the Function monitoring dashboard |
| <a name="output_function_dashboard_id"></a> [function\_dashboard\_id](#output\_function\_dashboard\_id) | ID of the Function monitoring dashboard |
| <a name="output_function_duration_alert_id"></a> [function\_duration\_alert\_id](#output\_function\_duration\_alert\_id) | ID of the function duration alert rule |
| <a name="output_function_failure_alert_id"></a> [function\_failure\_alert\_id](#output\_function\_failure\_alert\_id) | ID of the function failure alert rule |
| <a name="output_function_monitoring_configuration"></a> [function\_monitoring\_configuration](#output\_function\_monitoring\_configuration) | Complete Function monitoring configuration summary |
| <a name="output_monitored_app_service_plans"></a> [monitored\_app\_service\_plans](#output\_monitored\_app\_service\_plans) | Information about monitored App Service Plans |
| <a name="output_monitored_function_apps"></a> [monitored\_function\_apps](#output\_monitored\_function\_apps) | Information about monitored Function Apps |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Name of the monitored resource group |
<!-- END_TF_DOCS -->
