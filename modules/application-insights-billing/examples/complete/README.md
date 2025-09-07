# Complete Application Insights Billing Example

This example demonstrates the advanced usage of the Application Insights Billing module with all features enabled, suitable for production environments with comprehensive cost monitoring and alerting.

## What This Example Creates

- **Resource Group**: Production resource group
- **Log Analytics Workspace**: For advanced cost queries and analytics
- **Application Insights**: Production Application Insights instance with workspace integration
- **Additional Resources**: Storage account and service plan to generate realistic costs
- **Comprehensive Budget Monitoring**: Monthly, quarterly, and annual budgets with multiple alert thresholds
- **Advanced Cost Alerts**: Daily spend alerts and anomaly detection
- **Billing Dashboard**: Interactive dashboard with 90 days of cost data
- **Action Group**: Example notification system with email and webhook integration

## Features Enabled

- ✅ Budget monitoring (monthly, quarterly, annual) with multiple thresholds
- ✅ Email notifications to multiple recipients
- ✅ Advanced cost alerts with Log Analytics integration
- ✅ Cost anomaly detection with configurable sensitivity
- ✅ Forecast alerts for predictive cost management
- ✅ Cost filtering by resource types and tags
- ✅ Comprehensive billing dashboard with extended time range
- ✅ Action group for advanced notification scenarios

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     Resource Group                              │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │ Log Analytics   │  │ Application     │  │ Storage Account │ │
│  │ Workspace       │  │ Insights        │  │                 │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │ Service Plan    │  │ Action Group    │  │ Billing Module  │ │
│  │                 │  │                 │  │                 │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Billing Monitoring                          │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │ Monthly Budget  │  │ Daily Cost      │  │ Cost Anomaly    │ │
│  │ $2,000          │  │ Alert $100      │  │ Detection       │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │ Quarterly Budget│  │ Forecast Alerts │  │ Interactive     │ │
│  │ $6,000          │  │ 100%, 110%, 125%│  │ Dashboard       │ │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## Usage

### Prerequisites

1. **Azure CLI** installed and authenticated
2. **Terraform >= 1.13.1** installed
3. **Appropriate Azure permissions**:
   - Contributor role on subscription (recommended)
   - Cost Management Contributor role (minimum)
   - Application Insights Component Contributor
   - Log Analytics Contributor

### Quick Start

1. **Clone and navigate to the example:**
   ```bash
   cd modules/application-insights-billing/examples/complete
   ```

2. **Initialize Terraform:**
   ```bash
   terraform init
   ```

3. **Review and customize variables:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your specific values
   ```

4. **Review the plan:**
   ```bash
   terraform plan
   ```

5. **Apply the configuration:**
   ```bash
   terraform apply
   ```

6. **View outputs:**
   ```bash
   terraform output
   ```

### Customization Options

#### Budget Configuration

```bash
# Custom budget amounts for enterprise environments
terraform apply \
  -var="monthly_budget_amount=5000" \
  -var="quarterly_budget_amount=15000" \
  -var="annual_budget_amount=60000"
```

#### Alert Configuration

```bash
# Custom alert thresholds and sensitivity
terraform apply \
  -var="budget_alert_thresholds=[70,80,90,100,120]" \
  -var="daily_spend_threshold=200" \
  -var="cost_anomaly_sensitivity=1.5"
```

#### Notification Configuration

```bash
# Custom notification emails
terraform apply \
  -var='budget_notification_emails=["cfo@company.com","devops@company.com"]'
```

### Using terraform.tfvars

Create a `terraform.tfvars` file for comprehensive customization:

```hcl
# terraform.tfvars

# Basic Configuration
location                = "West US 2"
resource_group_name     = "rg-mycompany-prod-wus2-001"
workload               = "mycompany"
environment            = "prod"

# Budget Configuration
monthly_budget_amount     = 5000
quarterly_budget_amount   = 15000
annual_budget_amount      = 60000
budget_alert_thresholds   = [70, 80, 90, 100, 110, 120]
budget_forecast_thresholds = [100, 110, 125, 150]

# Notification Configuration
budget_notification_emails = [
  "finance@mycompany.com",
  "engineering-leads@mycompany.com",
  "platform-team@mycompany.com",
  "ceo@mycompany.com"
]

# Cost Alert Configuration
daily_spend_threshold     = 200
cost_anomaly_sensitivity  = 1.8
daily_cost_alert_severity = 0  # Critical
anomaly_alert_severity    = 1  # Error

# Cost Filtering
cost_filter_resource_types = [
  "Microsoft.Web/sites",
  "Microsoft.Web/serverfarms",
  "Microsoft.Insights/components",
  "Microsoft.Storage/storageAccounts",
  "Microsoft.OperationalInsights/workspaces",
  "Microsoft.Sql/servers",
  "Microsoft.Sql/servers/databases"
]

cost_filter_tags = {
  Environment = ["Production"]
  CostCenter  = ["Engineering", "Operations"]
  Criticality = ["High", "Critical"]
}

# Dashboard Configuration
dashboard_display_name = "MyCompany Production Cost Management"
dashboard_time_range   = 180  # 6 months of data

# Advanced Configuration
log_analytics_retention_days = 90
slack_webhook_url           = "https://hooks.slack.com/services/YOUR/ACTUAL/WEBHOOK"

# Tags
tags = {
  Environment = "Production"
  Project     = "MyCompany"
  CostCenter  = "Engineering"
  Owner       = "Platform Team"
  Criticality = "High"
  Monitoring  = "Enabled"
  Compliance  = "Required"
}
```

## Configuration Details

### Budget Configuration

- **Monthly Budget**: $2,000 (production-level)
- **Quarterly Budget**: $6,000
- **Annual Budget**: $24,000
- **Alert Thresholds**: 75%, 85%, 95%, 100%, 110%
- **Forecast Thresholds**: 100%, 110%, 125%
- **Multiple Recipients**: Finance, engineering leads, platform team, cost management

### Advanced Cost Alerts

- **Daily Spend Alert**: $100 threshold with Error severity
- **Anomaly Detection**: 2.0 standard deviations with Warning severity
- **Log Analytics Integration**: Advanced KQL queries for cost analysis

### Cost Filtering

- **Resource Types**: Web apps, service plans, Application Insights, storage, Log Analytics
- **Tag Filtering**: Production environment, specific projects and cost centers

### Dashboard Features

- **Extended Time Range**: 90 days of cost data
- **Advanced Visualizations**: Trend analysis, anomaly detection, budget tracking
- **Interactive Elements**: Drill-down capabilities, filtering options

## Expected Outputs

After applying, you'll see comprehensive outputs including:

```
budget_names = {
  "annual" = "budget-billing-complete-prod-annual"
  "monthly" = "budget-billing-complete-prod-monthly"
  "quarterly" = "budget-billing-complete-prod-quarterly"
}

alert_rule_names = {
  "cost_anomaly" = "alert-billing-complete-prod-cost-anomaly"
  "daily_cost" = "alert-billing-complete-prod-daily-cost"
}

billing_dashboard_display_name = "Production Cost Management Dashboard"

azure_portal_links = {
  "budgets" = "https://portal.azure.com/#view/Microsoft_Azure_CostManagement/Menu/~/budgets"
  "cost_analysis" = "https://portal.azure.com/#view/Microsoft_Azure_CostManagement/Menu/~/costanalysis"
  "cost_management" = "https://portal.azure.com/#view/Microsoft_Azure_CostManagement/Menu/~/overview"
  "resource_group" = "https://portal.azure.com/#@/resource/subscriptions/.../resourceGroups/rg-billing-complete-prod-eus-001/overview"
}
```

## Accessing Resources

### Billing Dashboard

1. Navigate to Azure Portal
2. Go to Application Insights > Workbooks
3. Find "Production Cost Management Dashboard"
4. Open for interactive cost analysis

### Cost Management

1. Use the `azure_portal_links` output for direct navigation
2. Access Azure Cost Management for detailed analysis
3. Review budgets and alerts in the Azure portal

### Log Analytics

1. Navigate to Log Analytics Workspace
2. Use Logs blade for custom cost queries
3. Explore cost data with KQL

## Cost Considerations

This complete example creates more substantial billable resources:

- **Log Analytics Workspace**: ~$2-5/GB ingested
- **Application Insights**: Pay-per-use with workspace integration
- **Storage Account**: Minimal cost for basic tier
- **Service Plan**: ~$13/month for B1 tier
- **Budgets and Alerts**: No additional cost

**Estimated monthly cost**: **$15-25** (primarily service plan and Log Analytics)

## Monitoring and Alerting

### Budget Alerts

- **75% threshold**: Early warning to finance team
- **85% threshold**: Alert to engineering leads
- **95% threshold**: Critical alert to all stakeholders
- **100% threshold**: Budget exceeded notification
- **110% threshold**: Overspend alert

### Cost Alerts

- **Daily Spend**: Immediate alert if daily costs exceed $100
- **Anomaly Detection**: Alert on unusual spending patterns
- **Forecast Alerts**: Predictive alerts for budget overruns

### Notification Channels

- **Email**: Multiple recipients with role-based distribution
- **Slack**: Webhook integration for team notifications
- **Action Groups**: Extensible notification system

## Advanced Features

### Cost Filtering

```hcl
# Monitor only critical production resources
cost_filter_resource_types = [
  "Microsoft.Web/sites",
  "Microsoft.Sql/servers/databases",
  "Microsoft.Storage/storageAccounts"
]

# Filter by business-critical tags
cost_filter_tags = {
  Environment = ["Production"]
  Criticality = ["High", "Critical"]
  CostCenter  = ["Engineering"]
}
```

### Anomaly Detection

- **Sensitivity**: Configurable standard deviation thresholds
- **Historical Analysis**: 7-day rolling window for baseline
- **Smart Alerting**: Reduces false positives with statistical analysis

### Forecast Alerts

- **Predictive**: Based on current spending trends
- **Multiple Thresholds**: Early warning system
- **Budget Protection**: Prevents unexpected overruns

## Troubleshooting

### Common Issues

1. **Permission Errors**
   ```bash
   # Verify Azure permissions
   az role assignment list --assignee $(az account show --query user.name -o tsv)
   ```

2. **Log Analytics Costs**
   ```bash
   # Monitor Log Analytics usage
   az monitor log-analytics workspace show --resource-group <rg> --workspace-name <workspace>
   ```

3. **Budget Notifications**
   ```bash
   # Verify email addresses are valid
   # Check spam folders for initial notifications
   ```

### Validation Steps

1. **Verify Budgets**: Check Azure Cost Management > Budgets
2. **Test Alerts**: Verify alert rules in Azure Monitor
3. **Dashboard Access**: Confirm workbook is accessible
4. **Notifications**: Test action group notifications

## Production Considerations

### Security

- **RBAC**: Implement proper role-based access control
- **Secrets**: Store sensitive values in Key Vault
- **Compliance**: Ensure cost data handling meets requirements

### Scalability

- **Multiple Environments**: Deploy per environment with different thresholds
- **Resource Groups**: Consider per-project or per-team resource groups
- **Automation**: Integrate with CI/CD pipelines

### Maintenance

- **Budget Reviews**: Quarterly budget threshold reviews
- **Alert Tuning**: Adjust sensitivity based on historical data
- **Dashboard Updates**: Regular dashboard content reviews

## Cleanup

To remove all resources:

```bash
terraform destroy
```

**Warning**: This will delete all created resources including historical cost data.

## Next Steps

1. **Integration**: Connect with existing monitoring systems
2. **Automation**: Implement Infrastructure as Code pipelines
3. **Governance**: Establish cost management policies
4. **Optimization**: Use insights for resource optimization

## Support

For production deployment support:

1. Review Azure Cost Management documentation
2. Consult with Azure architects for enterprise scenarios
3. Implement proper monitoring and alerting strategies
4. Consider Azure Cost Management APIs for custom integrations

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
| <a name="module_app_insights_billing"></a> [app\_insights\_billing](#module\_app\_insights\_billing) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_application_insights.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights) | resource |
| [azurerm_log_analytics_workspace.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_monitor_action_group.billing_alerts](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_action_group) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_service_plan.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |
| [azurerm_storage_account.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_action_group_id"></a> [action\_group\_id](#output\_action\_group\_id) | ID of the example action group |
| <a name="output_alert_rule_names"></a> [alert\_rule\_names](#output\_alert\_rule\_names) | Names of the created alert rules |
| <a name="output_alert_summary"></a> [alert\_summary](#output\_alert\_summary) | Summary of alert configuration |
| <a name="output_annual_budget_id"></a> [annual\_budget\_id](#output\_annual\_budget\_id) | ID of the annual budget |
| <a name="output_application_insights_id"></a> [application\_insights\_id](#output\_application\_insights\_id) | ID of the monitored Application Insights instance |
| <a name="output_application_insights_name"></a> [application\_insights\_name](#output\_application\_insights\_name) | Name of the monitored Application Insights instance |
| <a name="output_azure_portal_links"></a> [azure\_portal\_links](#output\_azure\_portal\_links) | Useful Azure Portal links for cost management |
| <a name="output_billing_configuration"></a> [billing\_configuration](#output\_billing\_configuration) | Complete billing configuration summary |
| <a name="output_billing_dashboard_display_name"></a> [billing\_dashboard\_display\_name](#output\_billing\_dashboard\_display\_name) | Display name of the billing dashboard |
| <a name="output_billing_dashboard_id"></a> [billing\_dashboard\_id](#output\_billing\_dashboard\_id) | ID of the billing dashboard |
| <a name="output_billing_dashboard_name"></a> [billing\_dashboard\_name](#output\_billing\_dashboard\_name) | Name of the billing dashboard |
| <a name="output_budget_names"></a> [budget\_names](#output\_budget\_names) | Names of the created budgets |
| <a name="output_budget_summary"></a> [budget\_summary](#output\_budget\_summary) | Summary of budget configuration |
| <a name="output_cost_anomaly_alert_id"></a> [cost\_anomaly\_alert\_id](#output\_cost\_anomaly\_alert\_id) | ID of the cost anomaly alert rule |
| <a name="output_daily_cost_alert_id"></a> [daily\_cost\_alert\_id](#output\_daily\_cost\_alert\_id) | ID of the daily cost alert rule |
| <a name="output_example_service_plan_name"></a> [example\_service\_plan\_name](#output\_example\_service\_plan\_name) | Name of the example service plan |
| <a name="output_example_storage_account_name"></a> [example\_storage\_account\_name](#output\_example\_storage\_account\_name) | Name of the example storage account |
| <a name="output_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#output\_log\_analytics\_workspace\_id) | ID of the Log Analytics Workspace |
| <a name="output_log_analytics_workspace_name"></a> [log\_analytics\_workspace\_name](#output\_log\_analytics\_workspace\_name) | Name of the Log Analytics Workspace |
| <a name="output_monthly_budget_id"></a> [monthly\_budget\_id](#output\_monthly\_budget\_id) | ID of the monthly budget |
| <a name="output_quarterly_budget_id"></a> [quarterly\_budget\_id](#output\_quarterly\_budget\_id) | ID of the quarterly budget |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | ID of the monitored resource group |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Name of the monitored resource group |
<!-- END_TF_DOCS -->
