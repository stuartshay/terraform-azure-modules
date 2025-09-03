# Complete Monitoring Example

This example demonstrates a full-featured monitoring setup with all available options enabled, including Function App monitoring, private endpoints, budget alerts, and comprehensive alerting.

## What This Example Creates

### Infrastructure Resources
- Resource Group for all resources
- Virtual Network with subnet for private endpoints
- App Service Plan (Consumption tier)
- Storage Account for Function Apps
- Two Linux Function Apps (basic and advanced)

### Monitoring Resources
- Log Analytics Workspace with 90-day retention and cost optimization
- Application Insights with workspace-based configuration and 75% sampling
- Action Group with email, SMS, and webhook notifications
- Private endpoint for Log Analytics Workspace
- Storage account for monitoring data
- Monitoring workbook for dashboards
- Budget alerts with $200 monthly limit

### Alert Rules
- **Metric Alerts**: CPU, memory, HTTP errors, response time for both Function Apps
- **Log Query Alerts**: Exception monitoring, availability checks, performance degradation
- **Activity Log Alerts**: Resource health and service health monitoring
- **Smart Detection**: AI-powered anomaly detection for failures and performance
- **Budget Alerts**: Cost monitoring with 80% and 100% thresholds

## Features Enabled

- ✅ Log Analytics Workspace (90-day retention, 5GB daily quota, 100GB reservation)
- ✅ Application Insights (75% sampling, workspace-based)
- ✅ Function App monitoring (2 Function Apps with comprehensive alerts)
- ✅ Action Group (email, SMS, webhook notifications)
- ✅ Private endpoints (secure network access)
- ✅ Storage monitoring (dedicated storage account)
- ✅ VM Insights data collection
- ✅ Workspace diagnostics
- ✅ Security Center solution
- ✅ Update Management solution
- ✅ Monitoring workbook
- ✅ Log query alerts
- ✅ Activity log alerts
- ✅ Budget alerts ($200/month)
- ✅ Smart detection
- ✅ Availability test alerts

## Usage

1. **Clone the repository:**
   ```bash
   git clone https://github.com/stuartshay/terraform-azure-modules.git
   cd terraform-azure-modules/modules/monitoring/examples/complete
   ```

2. **Customize the configuration:**
   Edit `main.tf` to update:
   - Email addresses in `notification_emails`
   - Phone number in `notification_sms`
   - Webhook URL in `notification_webhooks`
   - Budget amount and notification emails

3. **Initialize Terraform:**
   ```bash
   terraform init
   ```

4. **Review the plan:**
   ```bash
   terraform plan
   ```

5. **Apply the configuration:**
   ```bash
   terraform apply
   ```

6. **Clean up when done:**
   ```bash
   terraform destroy
   ```

## Configuration Highlights

### Cost Optimization
- **Log Retention**: 90 days (balance between compliance and cost)
- **Daily Quota**: 5GB limit to control ingestion costs
- **Reservation Capacity**: 100GB for predictable workloads
- **Sampling**: 75% to reduce Application Insights volume
- **Budget Alerts**: $200 monthly limit with notifications

### Production-Ready Thresholds
- **CPU**: 70% (stricter than default 80%)
- **Memory**: 80% (stricter than default 85%)
- **HTTP Errors**: 5 errors (stricter than default 10)
- **Response Time**: 3 seconds (stricter than default 5)
- **Availability**: 99% (stricter than default 95%)
- **Performance**: 3000ms (stricter than default 5000ms)

### Security Features
- **Private Endpoints**: Secure access to Log Analytics
- **Network Isolation**: VNet integration for monitoring traffic
- **Diagnostic Settings**: Audit logs for monitoring infrastructure
- **RBAC Ready**: Compatible with Azure role-based access control

### Comprehensive Notifications
- **Email**: Multiple recipients (admin, oncall, platform teams)
- **SMS**: On-call phone number for critical alerts
- **Webhooks**: Slack integration for team notifications
- **Smart Detection**: Separate email list for AI-detected issues

## Function App Integration

The example creates two Function Apps that are automatically monitored:

1. **func-example-basic-prod-001**
   - Monitored for CPU, memory, errors, response time
   - Included in log query alerts for exceptions and availability

2. **func-example-advanced-prod-001**
   - Same monitoring as basic Function App
   - Demonstrates multi-app monitoring capabilities

### Application Insights Integration

Function Apps automatically send telemetry to Application Insights:
- **Request tracking**: HTTP requests and responses
- **Dependency tracking**: External service calls
- **Exception tracking**: Unhandled exceptions
- **Performance counters**: System metrics
- **Custom telemetry**: Application-specific metrics

## Alert Coverage

### Metric Alerts (Per Function App)
- **High CPU Usage**: Triggers at 70% average over 15 minutes
- **High Memory Usage**: Triggers at 80% average over 15 minutes
- **HTTP Errors**: Triggers on 5+ HTTP 5xx errors in 5 minutes
- **Slow Response Time**: Triggers when average response time > 3 seconds

### Log Query Alerts
- **Function Exceptions**: Triggers on 3+ exceptions in 15 minutes
- **Function Availability**: Triggers when availability < 99%
- **Function Performance**: Triggers when average duration > 3000ms

### Activity Log Alerts
- **Resource Health**: Monitors for resource degradation or unavailability
- **Service Health**: Monitors Azure service incidents and maintenance

### Smart Detection
- **Failure Anomalies**: AI detects unusual failure patterns
- **Performance Anomalies**: AI detects performance degradation
- **Trace Severity**: AI detects unusual logging patterns

## Cost Considerations

This complete setup will incur higher costs than the basic example:

### Estimated Monthly Costs (USD)
- **Log Analytics**: $50-150 (depends on ingestion volume)
- **Application Insights**: $20-80 (depends on telemetry volume)
- **Storage Account**: $5-15 (monitoring data storage)
- **Private Endpoint**: $7-10 (network isolation)
- **Function Apps**: $0 (Consumption plan, pay-per-execution)
- **Alert Rules**: $5-15 (per rule and notification)

**Total Estimated Cost**: $87-270 USD/month

### Cost Optimization Tips
1. **Adjust sampling**: Reduce `sampling_percentage` for high-volume apps
2. **Tune retention**: Lower `log_retention_days` if compliance allows
3. **Set quotas**: Use `daily_quota_gb` to cap ingestion costs
4. **Monitor budget**: Budget alerts help track spending

## Customization Examples

### Add More Function Apps
```hcl
monitored_function_apps = {
  basic    = { /* existing */ }
  advanced = { /* existing */ }
  api = {
    resource_id = azurerm_linux_function_app.api.id
    name        = azurerm_linux_function_app.api.name
  }
}
```

### Adjust Alert Thresholds
```hcl
# More aggressive thresholds
cpu_threshold           = 60
memory_threshold        = 70
error_threshold         = 3
response_time_threshold = 2
```

### Add More Notification Channels
```hcl
notification_emails = {
  admin     = "admin@company.com"
  oncall    = "oncall@company.com"
  platform  = "platform@company.com"
  security  = "security@company.com"
}

notification_webhooks = {
  slack_alerts   = "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"
  teams_critical = "https://outlook.office.com/webhook/YOUR/TEAMS/WEBHOOK"
}
```

## Outputs

This example provides comprehensive outputs for integration:

### Essential Outputs
- `application_insights_connection_string` - Configure Function Apps
- `log_analytics_workspace_id` - Set up diagnostic settings
- `action_group_id` - Create custom alert rules

### Infrastructure Outputs
- `function_app_ids` - Reference created Function Apps
- `virtual_network_id` - Network integration
- `monitoring_storage_account_id` - Additional storage needs

### Monitoring Outputs
- `metric_alert_ids` - All created metric alerts
- `log_alert_ids` - All log query alerts
- `monitoring_configuration` - Complete setup summary

## Next Steps

After deploying this complete example:

1. **Configure Function Apps** - Use the Application Insights connection string
2. **Test Alerts** - Trigger test conditions to verify alert delivery
3. **Customize Dashboards** - Modify the workbook for your specific needs
4. **Add Custom Metrics** - Implement application-specific monitoring
5. **Set up Runbooks** - Automate responses to common alerts

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12.2 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.42 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.42.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_monitoring"></a> [monitoring](#module\_monitoring) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_linux_function_app.example_advanced](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app) | resource |
| [azurerm_linux_function_app.example_basic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app) | resource |
| [azurerm_network_security_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_private_endpoint.storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_service_plan.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |
| [azurerm_storage_account.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_subnet.private_endpoints](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_virtual_network.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_action_group_id"></a> [action\_group\_id](#output\_action\_group\_id) | ID of the monitoring action group |
| <a name="output_action_group_name"></a> [action\_group\_name](#output\_action\_group\_name) | Name of the monitoring action group |
| <a name="output_activity_log_alert_ids"></a> [activity\_log\_alert\_ids](#output\_activity\_log\_alert\_ids) | List of activity log alert IDs |
| <a name="output_application_insights_connection_string"></a> [application\_insights\_connection\_string](#output\_application\_insights\_connection\_string) | Connection string for Application Insights |
| <a name="output_application_insights_id"></a> [application\_insights\_id](#output\_application\_insights\_id) | ID of the Application Insights instance |
| <a name="output_application_insights_instrumentation_key"></a> [application\_insights\_instrumentation\_key](#output\_application\_insights\_instrumentation\_key) | Instrumentation key for Application Insights |
| <a name="output_application_insights_name"></a> [application\_insights\_name](#output\_application\_insights\_name) | Name of the Application Insights instance |
| <a name="output_budget_alert_id"></a> [budget\_alert\_id](#output\_budget\_alert\_id) | ID of the budget alert |
| <a name="output_function_app_ids"></a> [function\_app\_ids](#output\_function\_app\_ids) | IDs of the created Function Apps |
| <a name="output_log_alert_ids"></a> [log\_alert\_ids](#output\_log\_alert\_ids) | List of log query alert IDs |
| <a name="output_log_analytics_private_endpoint_id"></a> [log\_analytics\_private\_endpoint\_id](#output\_log\_analytics\_private\_endpoint\_id) | ID of the Log Analytics private endpoint |
| <a name="output_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#output\_log\_analytics\_workspace\_id) | ID of the Log Analytics Workspace |
| <a name="output_log_analytics_workspace_name"></a> [log\_analytics\_workspace\_name](#output\_log\_analytics\_workspace\_name) | Name of the Log Analytics Workspace |
| <a name="output_metric_alert_ids"></a> [metric\_alert\_ids](#output\_metric\_alert\_ids) | Map of metric alert IDs by function app |
| <a name="output_monitoring_configuration"></a> [monitoring\_configuration](#output\_monitoring\_configuration) | Summary of monitoring configuration |
| <a name="output_monitoring_storage_account_id"></a> [monitoring\_storage\_account\_id](#output\_monitoring\_storage\_account\_id) | ID of the monitoring storage account |
| <a name="output_monitoring_workbook_id"></a> [monitoring\_workbook\_id](#output\_monitoring\_workbook\_id) | ID of the monitoring workbook |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Name of the created resource group |
| <a name="output_resource_names"></a> [resource\_names](#output\_resource\_names) | Names of created monitoring resources |
| <a name="output_smart_detection_rule_ids"></a> [smart\_detection\_rule\_ids](#output\_smart\_detection\_rule\_ids) | List of smart detection rule IDs |
| <a name="output_virtual_network_id"></a> [virtual\_network\_id](#output\_virtual\_network\_id) | ID of the created virtual network |
<!-- END_TF_DOCS -->
