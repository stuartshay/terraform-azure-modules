# Basic Application Insights Billing Example

This example demonstrates the basic usage of the Application Insights Billing module with minimal configuration suitable for development environments.

## What This Example Creates

- **Resource Group**: Example resource group for testing
- **Application Insights**: Basic Application Insights instance
- **Budget Monitoring**: Monthly, quarterly, and annual budgets with email notifications
- **Billing Dashboard**: Interactive dashboard for cost visualization

## Features Enabled

- ✅ Budget monitoring (monthly, quarterly, annual)
- ✅ Email notifications for budget alerts
- ✅ Billing dashboard
- ❌ Advanced cost alerts (disabled for simplicity)
- ❌ Anomaly detection (disabled for development)
- ❌ Forecast alerts (disabled for development)

## Usage

### Prerequisites

1. Azure CLI installed and authenticated
2. Terraform >= 1.13.1 installed
3. Appropriate Azure permissions (Contributor role recommended)

### Quick Start

1. **Clone and navigate to the example:**
   ```bash
   cd modules/application-insights-billing/examples/basic
   ```

2. **Initialize Terraform:**
   ```bash
   terraform init
   ```

3. **Review the plan:**
   ```bash
   terraform plan
   ```

4. **Apply the configuration:**
   ```bash
   terraform apply
   ```

5. **View outputs:**
   ```bash
   terraform output
   ```

### Customization

You can customize the example by modifying the variables in `variables.tf` or by passing variables during apply:

```bash
# Custom budget amounts
terraform apply -var="monthly_budget_amount=200" -var="notification_email=your-email@company.com"

# Custom location
terraform apply -var="location=West US 2"

# Custom resource names
terraform apply -var="resource_group_name=rg-my-test-001" -var="workload=my-app"
```

### Using terraform.tfvars

Create a `terraform.tfvars` file to customize variables:

```hcl
# terraform.tfvars
location                = "West US 2"
monthly_budget_amount   = 200
quarterly_budget_amount = 600
annual_budget_amount    = 2400
notification_email      = "your-email@company.com"
workload               = "my-application"
environment            = "dev"

tags = {
  Environment = "Development"
  Project     = "MyProject"
  Owner       = "DevTeam"
}
```

## Configuration Details

### Budget Configuration

- **Monthly Budget**: $100 (configurable)
- **Quarterly Budget**: $300 (configurable)
- **Annual Budget**: $1,200 (configurable)
- **Alert Thresholds**: 90%, 100%
- **Notifications**: Email alerts to specified address

### Simplified Features

This basic example disables advanced features to keep it simple:

- **Cost Alerts**: Disabled (no Log Analytics workspace required)
- **Anomaly Detection**: Disabled
- **Forecast Alerts**: Disabled

### Dashboard Features

The billing dashboard includes:

- Daily cost trends (last 30 days)
- Cost breakdown by resource type
- Top 10 most expensive resources
- 24-hour cost summary
- Budget utilization status
- 7-day moving average

## Expected Outputs

After applying, you'll see outputs including:

```
budget_names = {
  "annual" = "budget-billing-example-dev-annual"
  "monthly" = "budget-billing-example-dev-monthly"
  "quarterly" = "budget-billing-example-dev-quarterly"
}

billing_dashboard_display_name = "billing-example dev Billing Dashboard"

resource_group_name = "rg-billing-example-dev-eus-001"
```

## Accessing the Dashboard

1. Navigate to the Azure Portal
2. Go to Application Insights > Workbooks
3. Find the workbook with the display name from the output
4. Open the workbook to view cost analytics

## Cost Considerations

This example creates minimal billable resources:

- **Resource Group**: No cost
- **Application Insights**: Pay-per-use (minimal for testing)
- **Budgets**: No additional cost
- **Workbook**: No additional cost

Estimated monthly cost for this example: **< $5** (primarily Application Insights data ingestion)

## Cleanup

To remove all resources created by this example:

```bash
terraform destroy
```

## Next Steps

Once you're comfortable with the basic example, consider:

1. **Advanced Example**: Try the complete example with Log Analytics integration
2. **Production Setup**: Increase budget amounts and enable advanced features
3. **Integration**: Integrate with existing Application Insights instances
4. **Customization**: Add custom cost filters and alert thresholds

## Troubleshooting

### Common Issues

1. **Permission Errors**: Ensure you have Contributor role on the subscription
2. **Email Validation**: Verify the notification email address is valid
3. **Resource Naming**: Ensure resource names are unique within your subscription

### Validation

After deployment, verify:

- Budgets are created in Azure Cost Management
- Email notifications are configured
- Dashboard is accessible in Application Insights Workbooks

## Support

For issues with this example:

1. Check the main module documentation
2. Verify Azure permissions and quotas
3. Review Terraform logs for detailed error messages

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
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_insights_name"></a> [application\_insights\_name](#output\_application\_insights\_name) | Name of the monitored Application Insights instance |
| <a name="output_billing_configuration"></a> [billing\_configuration](#output\_billing\_configuration) | Complete billing configuration summary |
| <a name="output_billing_dashboard_display_name"></a> [billing\_dashboard\_display\_name](#output\_billing\_dashboard\_display\_name) | Display name of the billing dashboard |
| <a name="output_billing_dashboard_id"></a> [billing\_dashboard\_id](#output\_billing\_dashboard\_id) | ID of the billing dashboard |
| <a name="output_budget_names"></a> [budget\_names](#output\_budget\_names) | Names of the created budgets |
| <a name="output_budget_summary"></a> [budget\_summary](#output\_budget\_summary) | Summary of budget configuration |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Name of the monitored resource group |
<!-- END_TF_DOCS -->
