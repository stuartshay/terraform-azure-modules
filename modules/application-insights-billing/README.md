# Application Insights Billing Module

This Terraform module creates comprehensive billing monitoring, budgets, and cost alerts for Azure resources within a Resource Group. It provides budget tracking, cost anomaly detection, and detailed billing dashboards to help manage and optimize Azure spending.

## Features

- **Budget Management**:
  - Monthly, quarterly, and annual budgets
  - Configurable alert thresholds (actual and forecasted)
  - Email notifications for budget overruns
  - Flexible budget filtering by resource types and tags

- **Cost Alerts**:
  - Daily spending threshold alerts
  - Cost anomaly detection with configurable sensitivity
  - Integration with Log Analytics for advanced cost queries

- **Billing Dashboard**: 
  - Interactive cost visualization and analysis
  - Daily cost trends and moving averages
  - Cost breakdown by resource type and individual resources
  - Budget utilization tracking
  - 24-hour cost summaries

- **Flexible Configuration**: 
  - All thresholds and settings are configurable
  - Optional features can be enabled/disabled
  - Support for cost filtering by resource types and tags

## Usage

### Basic Usage

```hcl
module "app_insights_billing" {
  source = "./modules/application-insights-billing"

  # Required variables
  resource_group_name       = "rg-myapp-prod-eus-001"
  location                 = "East US"
  application_insights_name = "appi-myapp-prod-eus-001"

  # Basic budget configuration
  monthly_budget_amount   = 500
  quarterly_budget_amount = 1500
  annual_budget_amount    = 6000

  # Notification emails for budget alerts
  budget_notification_emails = [
    "admin@company.com",
    "finance@company.com"
  ]

  # Optional naming
  workload    = "myapp"
  environment = "prod"

  tags = {
    Environment = "Production"
    Project     = "MyApp"
    CostCenter  = "Engineering"
  }
}
```

### Advanced Usage with Custom Configuration

```hcl
module "app_insights_billing" {
  source = "./modules/application-insights-billing"

  # Required variables
  resource_group_name       = "rg-myapp-prod-eus-001"
  location                 = "East US"
  application_insights_name = "appi-myapp-prod-eus-001"

  # Budget configuration
  monthly_budget_amount     = 1000
  quarterly_budget_amount   = 3000
  annual_budget_amount      = 12000
  budget_alert_thresholds   = [75, 90, 100, 110]  # Alert at 75%, 90%, 100%, 110%
  budget_forecast_thresholds = [100, 120]         # Forecast alerts at 100%, 120%
  
  # Notification configuration
  budget_notification_emails = [
    "admin@company.com",
    "finance@company.com",
    "devops@company.com"
  ]

  # Cost alert configuration (requires Log Analytics)
  log_analytics_workspace_name = "log-myapp-prod-eus-001"
  daily_spend_threshold       = 50    # Alert if daily spend > $50
  cost_anomaly_sensitivity    = 2.5   # 2.5 standard deviations
  
  # Cost filtering - only monitor specific resource types
  cost_filter_resource_types = [
    "Microsoft.Web/sites",
    "Microsoft.Insights/components",
    "Microsoft.Storage/storageAccounts"
  ]

  # Cost filtering by tags
  cost_filter_tags = {
    Environment = ["Production"]
    Project     = ["MyApp"]
  }

  # Dashboard configuration
  dashboard_display_name = "MyApp Production Cost Analysis"
  dashboard_time_range   = 60  # 60 days of data

  # Alert severities (0=Critical, 1=Error, 2=Warning, 3=Info, 4=Verbose)
  daily_cost_alert_severity = 1
  anomaly_alert_severity    = 2

  workload    = "myapp"
  environment = "prod"

  tags = {
    Environment = "Production"
    Project     = "MyApp"
    CostCenter  = "Engineering"
  }
}
```

### Development Environment Configuration

```hcl
module "app_insights_billing_dev" {
  source = "./modules/application-insights-billing"

  # Required variables
  resource_group_name       = "rg-myapp-dev-eus-001"
  location                 = "East US"
  application_insights_name = "appi-myapp-dev-eus-001"

  # Lower budgets for development
  monthly_budget_amount   = 100
  quarterly_budget_amount = 300
  annual_budget_amount    = 1200

  # Simplified alerting for dev
  budget_alert_thresholds = [90, 100]
  enable_forecast_alerts  = false
  enable_anomaly_detection = false

  # Basic notifications
  budget_notification_emails = ["dev-team@company.com"]

  # Disable advanced cost alerts for dev
  enable_cost_alerts = false

  workload    = "myapp"
  environment = "dev"

  tags = {
    Environment = "Development"
    Project     = "MyApp"
  }
}
```

### Integration with Application Insights Module

```hcl
# Create Application Insights with workspace
module "app_insights" {
  source = "./modules/application-insights"

  resource_group_name = "rg-myapp-prod-eus-001"
  location           = "East US"
  workload           = "myapp"
  environment        = "prod"

  create_workspace = true
  key_vault_id     = "/subscriptions/.../resourceGroups/.../providers/Microsoft.KeyVault/vaults/kv-myapp-prod"

  tags = {
    Environment = "Production"
    Project     = "MyApp"
  }
}

# Add billing monitoring
module "app_insights_billing" {
  source = "./modules/application-insights-billing"

  resource_group_name       = module.app_insights.resource_group_name
  location                 = module.app_insights.location
  application_insights_name = module.app_insights.name

  # Reference the created workspace for advanced cost queries
  log_analytics_workspace_name = module.app_insights.log_analytics_workspace_name

  # Budget configuration
  monthly_budget_amount = 500
  budget_notification_emails = ["admin@company.com"]

  workload    = "myapp"
  environment = "prod"

  tags = {
    Environment = "Production"
    Project     = "MyApp"
  }

  depends_on = [module.app_insights]
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.13.1 |
| azurerm | >= 4.42.0 |
| random | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 4.42.0 |
| random | >= 3.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_consumption_budget_resource_group.monthly](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/consumption_budget_resource_group) | resource |
| [azurerm_consumption_budget_resource_group.quarterly](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/consumption_budget_resource_group) | resource |
| [azurerm_consumption_budget_resource_group.annual](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/consumption_budget_resource_group) | resource |
| [azurerm_monitor_scheduled_query_rules_alert_v2.daily_cost](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_scheduled_query_rules_alert_v2) | resource |
| [azurerm_monitor_scheduled_query_rules_alert_v2.cost_anomaly](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_scheduled_query_rules_alert_v2) | resource |
| [azurerm_application_insights_workbook.billing_dashboard](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights_workbook) | resource |
| [random_uuid.billing_dashboard](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |
| [azurerm_application_insights.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/application_insights) | data source |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_log_analytics_workspace.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/log_analytics_workspace) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| resource_group_name | Name of the resource group to monitor billing for | `string` | n/a | yes |
| location | Azure region for resources | `string` | n/a | yes |
| application_insights_name | Name of the existing Application Insights instance | `string` | n/a | yes |
| workload | Name of the workload or application (used in naming convention) | `string` | `"app"` | no |
| environment | Environment name (dev, staging, prod) (used in naming convention) | `string` | `"dev"` | no |
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |
| log_analytics_workspace_name | Name of the Log Analytics Workspace (optional, for advanced cost queries) | `string` | `null` | no |
| enable_budget_monitoring | Enable budget monitoring and alerts | `bool` | `true` | no |
| monthly_budget_amount | Monthly budget amount in USD | `number` | `1000` | no |
| quarterly_budget_amount | Quarterly budget amount in USD | `number` | `3000` | no |
| annual_budget_amount | Annual budget amount in USD | `number` | `12000` | no |
| budget_end_date | End date for budgets in RFC3339 format (optional, defaults to 1 year from now) | `string` | `null` | no |
| budget_alert_thresholds | List of budget alert thresholds as percentages (e.g., [80, 90, 100]) | `list(number)` | `[80, 90, 100]` | no |
| budget_forecast_thresholds | List of budget forecast alert thresholds as percentages (e.g., [100, 110]) | `list(number)` | `[100, 110]` | no |
| enable_forecast_alerts | Enable forecast-based budget alerts | `bool` | `true` | no |
| budget_notification_emails | List of email addresses to notify when budget thresholds are exceeded | `list(string)` | `[]` | no |
| enable_cost_alerts | Enable cost-based alerts (requires Log Analytics workspace) | `bool` | `true` | no |
| daily_spend_threshold | Daily spending threshold in USD for cost alerts | `number` | `50` | no |
| daily_cost_alert_severity | Severity level for daily cost alert (0-4, where 0 is critical) | `number` | `2` | no |
| enable_anomaly_detection | Enable cost anomaly detection alerts | `bool` | `true` | no |
| cost_anomaly_sensitivity | Sensitivity for cost anomaly detection (standard deviations from mean) | `number` | `2` | no |
| anomaly_alert_severity | Severity level for anomaly detection alert (0-4, where 0 is critical) | `number` | `1` | no |
| cost_filter_resource_types | List of resource types to include in cost monitoring (empty list means all types) | `list(string)` | `[]` | no |
| cost_filter_tags | Map of tag filters for cost monitoring (tag_name = [tag_values]) | `map(list(string))` | `{}` | no |
| enable_billing_dashboard | Enable billing dashboard creation | `bool` | `true` | no |
| dashboard_display_name | Display name for the billing dashboard | `string` | `null` | no |
| dashboard_time_range | Default time range for dashboard queries (in days) | `number` | `30` | no |

## Outputs

| Name | Description |
|------|-------------|
| monthly_budget_id | ID of the monthly budget |
| quarterly_budget_id | ID of the quarterly budget |
| annual_budget_id | ID of the annual budget |
| budget_names | Map of budget names |
| daily_cost_alert_id | ID of the daily cost alert rule |
| cost_anomaly_alert_id | ID of the cost anomaly alert rule |
| alert_rule_names | Map of alert rule names |
| billing_dashboard_id | ID of the billing dashboard |
| billing_dashboard_name | Name of the billing dashboard |
| billing_dashboard_display_name | Display name of the billing dashboard |
| application_insights_id | ID of the monitored Application Insights instance |
| application_insights_name | Name of the monitored Application Insights instance |
| application_insights_app_id | App ID of the monitored Application Insights instance |
| resource_group_id | ID of the monitored resource group |
| resource_group_name | Name of the monitored resource group |
| log_analytics_workspace_id | ID of the Log Analytics Workspace (if provided) |
| log_analytics_workspace_name | Name of the Log Analytics Workspace (if provided) |
| billing_configuration | Summary of billing monitoring configuration |
| budget_summary | Summary of configured budgets |
| alert_summary | Summary of configured alerts |
| location | Azure region where billing resources are deployed |
| tags | Tags applied to the billing resources |

## Alert Severity Levels

- **0**: Critical
- **1**: Error
- **2**: Warning
- **3**: Informational
- **4**: Verbose

## Default Budget Thresholds

- **Monthly Budget**: $1,000
- **Quarterly Budget**: $3,000
- **Annual Budget**: $12,000
- **Alert Thresholds**: 80%, 90%, 100%
- **Forecast Thresholds**: 100%, 110%

## Default Cost Alert Thresholds

- **Daily Spend**: $50
- **Anomaly Sensitivity**: 2 standard deviations
- **Daily Alert Severity**: Warning (2)
- **Anomaly Alert Severity**: Error (1)

## Dashboard Features

The billing dashboard provides:

- **Daily Cost Trends**: 30-day cost visualization with trend analysis
- **Cost by Resource Type**: Pie chart showing cost distribution
- **Top Expensive Resources**: Table of highest-cost resources
- **24-Hour Summary**: Recent cost metrics and statistics
- **Budget Status**: Current budget utilization with visual indicators
- **Moving Averages**: 7-day moving average for trend smoothing

## Cost Filtering

The module supports filtering costs by:

- **Resource Types**: Monitor only specific Azure resource types
- **Tags**: Filter by resource tags (e.g., Environment, Project)
- **Combination**: Use both resource type and tag filters together

## Prerequisites

1. **Azure Subscription**: Active Azure subscription with appropriate permissions
2. **Resource Group**: Existing resource group to monitor
3. **Application Insights**: Existing Application Insights instance
4. **Log Analytics Workspace** (optional): Required for advanced cost alerts and anomaly detection
5. **Email Configuration**: Valid email addresses for budget notifications

## Permissions Required

The service principal or user running Terraform needs:

- `Contributor` or `Cost Management Contributor` role on the resource group
- `Application Insights Component Contributor` for dashboard creation
- `Log Analytics Contributor` (if using Log Analytics workspace)

## Cost Considerations

This module creates the following billable resources:

- **Azure Budgets**: No additional cost
- **Monitor Alert Rules**: Minimal cost for query execution
- **Application Insights Workbooks**: No additional cost
- **Log Analytics Queries**: Charged based on data ingestion and retention

## Limitations

- **Cost Data Latency**: Azure cost data typically has 8-24 hour latency
- **Budget Notifications**: Limited to email notifications (no SMS or webhooks)
- **Log Analytics Dependency**: Advanced cost alerts require Log Analytics workspace
- **Regional Availability**: Some features may not be available in all Azure regions

## License

This module is licensed under the MIT License.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.13.1 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.42.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.43.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_application_insights_workbook.billing_dashboard](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights_workbook) | resource |
| [azurerm_consumption_budget_resource_group.annual](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/consumption_budget_resource_group) | resource |
| [azurerm_consumption_budget_resource_group.monthly](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/consumption_budget_resource_group) | resource |
| [azurerm_consumption_budget_resource_group.quarterly](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/consumption_budget_resource_group) | resource |
| [azurerm_monitor_scheduled_query_rules_alert_v2.cost_anomaly](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_scheduled_query_rules_alert_v2) | resource |
| [azurerm_monitor_scheduled_query_rules_alert_v2.daily_cost](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_scheduled_query_rules_alert_v2) | resource |
| [random_uuid.billing_dashboard](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |
| [azurerm_application_insights.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/application_insights) | data source |
| [azurerm_log_analytics_workspace.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/log_analytics_workspace) | data source |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_annual_budget_amount"></a> [annual\_budget\_amount](#input\_annual\_budget\_amount) | Annual budget amount in USD | `number` | `12000` | no |
| <a name="input_anomaly_alert_severity"></a> [anomaly\_alert\_severity](#input\_anomaly\_alert\_severity) | Severity level for anomaly detection alert (0-4, where 0 is critical) | `number` | `1` | no |
| <a name="input_application_insights_name"></a> [application\_insights\_name](#input\_application\_insights\_name) | Name of the existing Application Insights instance | `string` | n/a | yes |
| <a name="input_budget_alert_thresholds"></a> [budget\_alert\_thresholds](#input\_budget\_alert\_thresholds) | List of budget alert thresholds as percentages (e.g., [80, 90, 100]) | `list(number)` | <pre>[<br/>  80,<br/>  90,<br/>  100<br/>]</pre> | no |
| <a name="input_budget_end_date"></a> [budget\_end\_date](#input\_budget\_end\_date) | End date for budgets in RFC3339 format (optional, defaults to 1 year from now) | `string` | `null` | no |
| <a name="input_budget_forecast_thresholds"></a> [budget\_forecast\_thresholds](#input\_budget\_forecast\_thresholds) | List of budget forecast alert thresholds as percentages (e.g., [100, 110]) | `list(number)` | <pre>[<br/>  100,<br/>  110<br/>]</pre> | no |
| <a name="input_budget_notification_emails"></a> [budget\_notification\_emails](#input\_budget\_notification\_emails) | List of email addresses to notify when budget thresholds are exceeded | `list(string)` | `[]` | no |
| <a name="input_cost_anomaly_sensitivity"></a> [cost\_anomaly\_sensitivity](#input\_cost\_anomaly\_sensitivity) | Sensitivity for cost anomaly detection (standard deviations from mean) | `number` | `2` | no |
| <a name="input_cost_filter_resource_types"></a> [cost\_filter\_resource\_types](#input\_cost\_filter\_resource\_types) | List of resource types to include in cost monitoring (empty list means all types) | `list(string)` | `[]` | no |
| <a name="input_cost_filter_tags"></a> [cost\_filter\_tags](#input\_cost\_filter\_tags) | Map of tag filters for cost monitoring (tag\_name = [tag\_values]) | `map(list(string))` | `{}` | no |
| <a name="input_daily_cost_alert_severity"></a> [daily\_cost\_alert\_severity](#input\_daily\_cost\_alert\_severity) | Severity level for daily cost alert (0-4, where 0 is critical) | `number` | `2` | no |
| <a name="input_daily_spend_threshold"></a> [daily\_spend\_threshold](#input\_daily\_spend\_threshold) | Daily spending threshold in USD for cost alerts | `number` | `50` | no |
| <a name="input_dashboard_display_name"></a> [dashboard\_display\_name](#input\_dashboard\_display\_name) | Display name for the billing dashboard | `string` | `null` | no |
| <a name="input_enable_anomaly_detection"></a> [enable\_anomaly\_detection](#input\_enable\_anomaly\_detection) | Enable cost anomaly detection alerts | `bool` | `true` | no |
| <a name="input_enable_billing_dashboard"></a> [enable\_billing\_dashboard](#input\_enable\_billing\_dashboard) | Enable billing dashboard creation | `bool` | `true` | no |
| <a name="input_enable_budget_monitoring"></a> [enable\_budget\_monitoring](#input\_enable\_budget\_monitoring) | Enable budget monitoring and alerts | `bool` | `true` | no |
| <a name="input_enable_cost_alerts"></a> [enable\_cost\_alerts](#input\_enable\_cost\_alerts) | Enable cost-based alerts (requires Log Analytics workspace) | `bool` | `true` | no |
| <a name="input_enable_forecast_alerts"></a> [enable\_forecast\_alerts](#input\_enable\_forecast\_alerts) | Enable forecast-based budget alerts | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, staging, prod) (used in naming convention) | `string` | `"dev"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for resources | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_name"></a> [log\_analytics\_workspace\_name](#input\_log\_analytics\_workspace\_name) | Name of the Log Analytics Workspace (optional, for advanced cost queries) | `string` | `null` | no |
| <a name="input_monthly_budget_amount"></a> [monthly\_budget\_amount](#input\_monthly\_budget\_amount) | Monthly budget amount in USD | `number` | `1000` | no |
| <a name="input_quarterly_budget_amount"></a> [quarterly\_budget\_amount](#input\_quarterly\_budget\_amount) | Quarterly budget amount in USD | `number` | `3000` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group to monitor billing for | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Name of the workload or application (used in naming convention) | `string` | `"app"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alert_rule_names"></a> [alert\_rule\_names](#output\_alert\_rule\_names) | Map of alert rule names |
| <a name="output_alert_summary"></a> [alert\_summary](#output\_alert\_summary) | Summary of configured alerts |
| <a name="output_annual_budget_id"></a> [annual\_budget\_id](#output\_annual\_budget\_id) | ID of the annual budget |
| <a name="output_application_insights_app_id"></a> [application\_insights\_app\_id](#output\_application\_insights\_app\_id) | App ID of the monitored Application Insights instance |
| <a name="output_application_insights_id"></a> [application\_insights\_id](#output\_application\_insights\_id) | ID of the monitored Application Insights instance |
| <a name="output_application_insights_name"></a> [application\_insights\_name](#output\_application\_insights\_name) | Name of the monitored Application Insights instance |
| <a name="output_billing_configuration"></a> [billing\_configuration](#output\_billing\_configuration) | Summary of billing monitoring configuration |
| <a name="output_billing_dashboard_display_name"></a> [billing\_dashboard\_display\_name](#output\_billing\_dashboard\_display\_name) | Display name of the billing dashboard |
| <a name="output_billing_dashboard_id"></a> [billing\_dashboard\_id](#output\_billing\_dashboard\_id) | ID of the billing dashboard |
| <a name="output_billing_dashboard_name"></a> [billing\_dashboard\_name](#output\_billing\_dashboard\_name) | Name of the billing dashboard |
| <a name="output_budget_names"></a> [budget\_names](#output\_budget\_names) | Map of budget names |
| <a name="output_budget_summary"></a> [budget\_summary](#output\_budget\_summary) | Summary of configured budgets |
| <a name="output_cost_anomaly_alert_id"></a> [cost\_anomaly\_alert\_id](#output\_cost\_anomaly\_alert\_id) | ID of the cost anomaly alert rule |
| <a name="output_daily_cost_alert_id"></a> [daily\_cost\_alert\_id](#output\_daily\_cost\_alert\_id) | ID of the daily cost alert rule |
| <a name="output_location"></a> [location](#output\_location) | Azure region where billing resources are deployed |
| <a name="output_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#output\_log\_analytics\_workspace\_id) | ID of the Log Analytics Workspace (if provided) |
| <a name="output_log_analytics_workspace_name"></a> [log\_analytics\_workspace\_name](#output\_log\_analytics\_workspace\_name) | Name of the Log Analytics Workspace (if provided) |
| <a name="output_monthly_budget_id"></a> [monthly\_budget\_id](#output\_monthly\_budget\_id) | ID of the monthly budget |
| <a name="output_quarterly_budget_id"></a> [quarterly\_budget\_id](#output\_quarterly\_budget\_id) | ID of the quarterly budget |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | ID of the monitored resource group |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Name of the monitored resource group |
| <a name="output_tags"></a> [tags](#output\_tags) | Tags applied to the billing resources |
<!-- END_TF_DOCS -->
