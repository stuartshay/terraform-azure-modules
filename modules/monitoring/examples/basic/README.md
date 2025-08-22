# Basic Monitoring Example

This example demonstrates the minimal configuration required to deploy the Azure monitoring module.

## What This Example Creates

- Resource Group for the monitoring resources
- Log Analytics Workspace with default settings (30-day retention)
- Application Insights with workspace-based configuration
- Action Group for email notifications
- Smart detection rules enabled
- Monitoring workbook enabled

## Features Enabled

- ✅ Log Analytics Workspace
- ✅ Application Insights
- ✅ Action Group with email notifications
- ✅ Smart Detection
- ✅ Monitoring Workbook
- ❌ Function App monitoring (no Function Apps configured)
- ❌ Private endpoints
- ❌ Budget alerts
- ❌ Storage monitoring

## Usage

1. **Clone the repository:**
   ```bash
   git clone https://github.com/stuartshay/terraform-azure-modules.git
   cd terraform-azure-modules/modules/monitoring/examples/basic
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

5. **Clean up when done:**
   ```bash
   terraform destroy
   ```

## Configuration

The example uses these default values:

- **Location**: East US
- **Environment**: dev
- **Workload**: example
- **Log Retention**: 30 days
- **Sampling**: 100%
- **Notification Email**: admin@example.com (change this!)

## Customization

To customize this example:

1. **Change the notification email:**
   ```hcl
   notification_emails = {
     admin = "your-email@company.com"
   }
   ```

2. **Modify the location:**
   ```hcl
   resource "azurerm_resource_group" "example" {
     name     = "rg-monitoring-basic-example"
     location = "West US 2"  # Change this
   }

   locals {
     location_short = "westus2"  # Update this too
   }
   ```

3. **Add more notification methods:**
   ```hcl
   notification_emails = {
     admin = "admin@company.com"
     team  = "team@company.com"
   }

   notification_sms = {
     oncall = {
       country_code = "1"
       phone_number = "5551234567"
     }
   }
   ```

## Outputs

After deployment, you'll get these important outputs:

- `log_analytics_workspace_id` - Use this for diagnostic settings
- `application_insights_connection_string` - Use this in your applications
- `action_group_id` - Use this for custom alert rules

## Next Steps

After running this basic example:

1. **Integrate with applications** - Use the Application Insights connection string in your apps
2. **Add Function App monitoring** - See the [complete example](../complete/) for Function App integration
3. **Create custom alerts** - Use the action group ID to create additional alert rules
4. **Enable additional features** - Consider private endpoints, budget alerts, etc.

## Cost Considerations

This basic setup will incur minimal costs:

- **Log Analytics**: Pay-per-GB ingested (first 5GB/month free)
- **Application Insights**: Pay-per-GB ingested (first 1GB/month free)
- **Alerts**: Small cost per alert rule and notification

Estimated monthly cost for low-volume development: $5-20 USD

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5 |
| azurerm | ~> 4.40 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 4.40 |
