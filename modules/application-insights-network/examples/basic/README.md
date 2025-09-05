# Basic Example - Application Insights Network Module

This example demonstrates the basic usage of the Application Insights Network module. It creates:

1. A resource group
2. A Log Analytics Workspace
3. An Application Insights instance (workspace-based)
4. Alert rules for monitoring the Application Insights instance
5. A basic dashboard for visualizing metrics

## Usage

1. Clone this repository
2. Navigate to this example directory
3. Initialize Terraform:
   ```bash
   terraform init
   ```
4. Plan the deployment:
   ```bash
   terraform plan
   ```
5. Apply the configuration:
   ```bash
   terraform apply
   ```

## What Gets Created

### Infrastructure Resources
- **Resource Group**: `rg-appinsights-network-example`
- **Log Analytics Workspace**: `log-example-dev-eus-001`
- **Application Insights**: `appi-example-dev-eus-001` (workspace-based)

### Monitoring Resources
- **Alert Rules**:
  - Response time alert (threshold: 5000ms)
  - Failed request rate alert (threshold: 5%)
  - Exception rate alert (threshold: 10 per 5 minutes)
  - Availability alert (threshold: 99%)
  - Server error alert (threshold: 10 per 5 minutes)

- **Dashboard**: "Example Application Monitoring" with charts for:
  - Request rate over time
  - Average response time trends
  - Failed request tracking
  - Exception monitoring
  - Availability percentage
  - 24-hour summary statistics

## Customization

You can customize the alert thresholds by modifying the module configuration:

```hcl
module "app_insights_network" {
  source = "../../"

  # ... other configuration ...

  # Custom thresholds
  response_time_threshold_ms     = 3000  # 3 seconds instead of 5
  failed_request_rate_threshold  = 2     # 2% instead of 5%
  exception_rate_threshold       = 5     # 5 exceptions instead of 10
  availability_threshold_percent = 99.5  # 99.5% instead of 99%
  server_error_threshold        = 5      # 5 errors instead of 10

  # Custom severities
  response_time_alert_severity = 1  # Error instead of Warning
  availability_alert_severity  = 0  # Critical (default)
}
```

## Outputs

After applying, you can view the outputs:

```bash
terraform output
```

Key outputs include:
- Application Insights connection string (sensitive)
- Alert rule names and IDs
- Dashboard ID and display name
- Monitoring configuration summary

## Clean Up

To destroy the resources:

```bash
terraform destroy
```

## Integration Example

In a real-world scenario, you would typically use this module alongside the `application-insights` module:

```hcl
# Create Application Insights with the main module
module "app_insights" {
  source = "../../../application-insights"

  resource_group_name = "rg-myapp-prod"
  location           = "East US"
  workload           = "myapp"
  environment        = "prod"

  create_workspace = true
  key_vault_id     = "/subscriptions/.../vaults/kv-myapp-prod"
}

# Add monitoring with the network module
module "app_insights_monitoring" {
  source = "../../"

  resource_group_name       = module.app_insights.resource_group_name
  location                 = module.app_insights.location
  application_insights_name = module.app_insights.name

  workload    = "myapp"
  environment = "prod"

  log_analytics_workspace_name = module.app_insights.log_analytics_workspace_name

  depends_on = [module.app_insights]
}
```

## Requirements

- Azure subscription with appropriate permissions
- Terraform >= 1.0
- Azure CLI (for authentication)

## Notes

- This example creates resources in the East US region
- All resources are tagged for easy identification
- The example uses default alert thresholds suitable for development/testing
- For production use, consider adjusting thresholds based on your application's characteristics

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
| <a name="module_app_insights_network"></a> [app\_insights\_network](#module\_app\_insights\_network) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_application_insights.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights) | resource |
| [azurerm_log_analytics_workspace.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alert_rule_names"></a> [alert\_rule\_names](#output\_alert\_rule\_names) | Names of the created alert rules |
| <a name="output_application_insights_connection_string"></a> [application\_insights\_connection\_string](#output\_application\_insights\_connection\_string) | Connection string for the Application Insights instance |
| <a name="output_application_insights_id"></a> [application\_insights\_id](#output\_application\_insights\_id) | ID of the Application Insights instance |
| <a name="output_application_insights_name"></a> [application\_insights\_name](#output\_application\_insights\_name) | Name of the Application Insights instance |
| <a name="output_dashboard_display_name"></a> [dashboard\_display\_name](#output\_dashboard\_display\_name) | Display name of the created dashboard |
| <a name="output_dashboard_id"></a> [dashboard\_id](#output\_dashboard\_id) | ID of the created dashboard |
| <a name="output_location"></a> [location](#output\_location) | Azure region where resources are deployed |
| <a name="output_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#output\_log\_analytics\_workspace\_id) | ID of the Log Analytics Workspace |
| <a name="output_log_analytics_workspace_name"></a> [log\_analytics\_workspace\_name](#output\_log\_analytics\_workspace\_name) | Name of the Log Analytics Workspace |
| <a name="output_monitoring_configuration"></a> [monitoring\_configuration](#output\_monitoring\_configuration) | Summary of the monitoring configuration |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Name of the resource group |
<!-- END_TF_DOCS -->
