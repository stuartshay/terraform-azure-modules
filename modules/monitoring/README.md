# Azure Monitoring Module

This Terraform module creates a comprehensive monitoring solution for Azure resources using Log Analytics Workspace, Application Insights, and Azure Monitor.

## Features

- **Log Analytics Workspace** - Centralized logging and metrics collection
- **Application Insights** - Workspace-based application performance monitoring
- **Azure Monitor Alerts** - Metric alerts, log query alerts, and activity log alerts
- **Action Groups** - Email, SMS, and webhook notifications
- **Smart Detection** - AI-powered anomaly detection
- **Cost Management** - Budget alerts and cost optimization
- **Security** - Private endpoints and diagnostic settings

## Usage

### Basic Example

```hcl
module "monitoring" {
  source = "github.com/stuartshay/terraform-azure-modules//modules/monitoring?ref=v0.1.0"

  # Required variables
  resource_group_name = "rg-myapp-dev-eastus"
  location           = "East US"
  workload           = "myapp"
  environment        = "dev"
  location_short     = "eastus"
  subscription_id    = "12345678-1234-1234-1234-123456789012"

  # Notification configuration
  notification_emails = {
    admin = "admin@company.com"
  }

  tags = {
    Environment = "dev"
    Project     = "myapp"
    Owner       = "platform-team"
  }
}
```

### Advanced Example with Function App Monitoring

```hcl
module "monitoring" {
  source = "github.com/stuartshay/terraform-azure-modules//modules/monitoring?ref=v0.1.0"

  # Required variables
  resource_group_name = "rg-myapp-prod-eastus"
  location           = "East US"
  workload           = "myapp"
  environment        = "prod"
  location_short     = "eastus"
  subscription_id    = var.subscription_id

  # Function Apps to monitor
  monitored_function_apps = {
    basic = {
      resource_id = "/subscriptions/.../resourceGroups/.../providers/Microsoft.Web/sites/func-myapp-basic-prod-001"
      name        = "func-myapp-basic-prod-001"
    }
    advanced = {
      resource_id = "/subscriptions/.../resourceGroups/.../providers/Microsoft.Web/sites/func-myapp-advanced-prod-001"
      name        = "func-myapp-advanced-prod-001"
    }
  }

  # Cost optimization
  log_retention_days      = 90
  daily_quota_gb         = 10
  reservation_capacity_gb = 100
  sampling_percentage    = 50

  # Enhanced notifications
  notification_emails = {
    admin    = "admin@company.com"
    oncall   = "oncall@company.com"
    platform = "platform@company.com"
  }

  notification_sms = {
    oncall = {
      country_code = "1"
      phone_number = "5551234567"
    }
  }

  # Stricter thresholds for production
  cpu_threshold          = 70
  memory_threshold       = 80
  error_threshold        = 5
  response_time_threshold = 3

  # Full feature set
  enable_budget_alerts       = true
  enable_private_endpoints   = true
  enable_availability_tests  = true
  enable_workspace_diagnostics = true

  budget_amount = 500
  budget_notification_emails = ["finance@company.com"]

  tags = {
    Environment = "prod"
    Project     = "myapp"
    Owner       = "platform-team"
    CostCenter  = "engineering"
  }
}
```

## Resources Created

### Core Monitoring Resources
- `azurerm_log_analytics_workspace` - Central logging workspace
- `azurerm_application_insights` - Application performance monitoring
- `azurerm_monitor_action_group` - Notification action group

### Alert Rules
- `azurerm_monitor_metric_alert` - CPU, memory, errors, response time alerts
- `azurerm_monitor_scheduled_query_rules_alert_v2` - Log query alerts
- `azurerm_monitor_activity_log_alert` - Resource and service health alerts

### Optional Resources
- `azurerm_storage_account` - Monitoring data storage (if enabled)
- `azurerm_private_endpoint` - Private endpoint for Log Analytics (if enabled)
- `azurerm_application_insights_workbook` - Monitoring dashboard (if enabled)
- `azurerm_consumption_budget_resource_group` - Budget alerts (if enabled)

## Alert Types

### Metric Alerts
- **CPU Usage** - Triggers when CPU usage exceeds threshold
- **Memory Usage** - Triggers when memory usage exceeds threshold
- **HTTP Errors** - Triggers on high number of 5xx errors
- **Response Time** - Triggers when response time exceeds threshold

### Log Query Alerts
- **Function Exceptions** - High number of exceptions in Function Apps
- **Function Availability** - Function App availability issues
- **Function Performance** - Performance degradation detection

### Activity Log Alerts
- **Resource Health** - Resource health degradation
- **Service Health** - Azure service health issues

### Smart Detection
- **Failure Anomalies** - AI-detected failure patterns
- **Performance Anomalies** - AI-detected performance issues
- **Trace Severity** - Unusual trace patterns

## Configuration Options

### Log Analytics
- **SKU**: PerGB2018 (default), Free, PerNode, Standalone, Standard, Premium
- **Retention**: 30-730 days (default: 30)
- **Daily Quota**: Unlimited (default) or specific GB limit
- **Reservation Capacity**: Cost optimization for high-volume workloads

### Application Insights
- **Sampling**: 1-100% (default: 100%)
- **Workspace-based**: Always enabled for better integration
- **IP Masking**: Disabled for dev, enabled for production

### Notifications
- **Email**: Multiple email addresses supported
- **SMS**: Country code and phone number
- **Webhooks**: HTTPS URLs for integration

### Alert Thresholds
All thresholds are configurable with sensible defaults:
- CPU: 80%
- Memory: 85%
- HTTP Errors: 10 errors
- Response Time: 5 seconds
- Exceptions: 5 exceptions
- Availability: 95%
- Performance: 5000ms

## Private Endpoints

When `enable_private_endpoints = true`, the module creates:
- Private endpoint for Log Analytics Workspace
- Private DNS zone integration
- Network security for monitoring traffic

## Cost Optimization

### Log Analytics
- **Commitment Tiers**: Use `reservation_capacity_gb` for predictable workloads
- **Daily Quota**: Set `daily_quota_gb` to control costs
- **Retention**: Adjust `log_retention_days` based on compliance needs

### Application Insights
- **Sampling**: Reduce `sampling_percentage` for high-volume applications
- **Data Retention**: Workspace-based retention follows Log Analytics settings

### Budget Alerts
Enable `enable_budget_alerts` to monitor spending:
- 80% threshold warning
- 100% threshold critical alert

## Integration with Function Apps

The module is designed to integrate with Azure Function Apps:

1. **Automatic Monitoring**: Function Apps automatically send telemetry
2. **Custom Metrics**: Support for custom application metrics
3. **Distributed Tracing**: End-to-end request tracking
4. **Performance Insights**: Detailed performance analysis

## Security Features

- **Private Endpoints**: Secure network access to monitoring resources
- **Diagnostic Settings**: Audit logs for monitoring infrastructure
- **RBAC Integration**: Works with Azure role-based access control
- **Data Encryption**: All data encrypted at rest and in transit

## Outputs

The module provides comprehensive outputs for integration:

### Essential Outputs
- `application_insights_connection_string` - For Function App configuration
- `application_insights_instrumentation_key` - Legacy instrumentation key
- `log_analytics_workspace_id` - For diagnostic settings

### Advanced Outputs
- `action_group_id` - For custom alert rules
- `monitoring_configuration` - Complete configuration summary
- `resource_names` - All created resource names

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5 |
| azurerm | ~> 4.40 |
| random | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 4.40 |
| random | >= 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| resource_group_name | Name of the resource group | `string` | n/a | yes |
| location | Azure region for resources | `string` | n/a | yes |
| workload | Name of the workload or application | `string` | n/a | yes |
| environment | Environment name (dev, staging, prod) | `string` | n/a | yes |
| location_short | Short name for the location | `string` | n/a | yes |
| subscription_id | Azure subscription ID | `string` | n/a | yes |
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |
| log_analytics_sku | SKU for Log Analytics Workspace | `string` | `"PerGB2018"` | no |
| log_retention_days | Number of days to retain logs in Log Analytics | `number` | `30` | no |
| daily_quota_gb | Daily ingestion quota in GB for Log Analytics (-1 for unlimited) | `number` | `-1` | no |
| reservation_capacity_gb | Reservation capacity in GB per day for cost optimization | `number` | `null` | no |
| sampling_percentage | Sampling percentage for Application Insights | `number` | `100` | no |
| notification_emails | Map of email addresses for notifications | `map(string)` | `{}` | no |
| notification_sms | Map of SMS numbers for notifications | `map(object({country_code = string, phone_number = string}))` | `{}` | no |
| notification_webhooks | Map of webhook URLs for notifications | `map(string)` | `{}` | no |
| cpu_threshold | CPU usage threshold for alerts (percentage) | `number` | `80` | no |
| memory_threshold | Memory usage threshold for alerts (percentage) | `number` | `85` | no |
| error_threshold | Number of HTTP errors to trigger alert | `number` | `10` | no |
| response_time_threshold | Response time threshold in seconds | `number` | `5` | no |
| exception_threshold | Number of exceptions to trigger alert | `number` | `5` | no |
| availability_threshold | Availability percentage threshold | `number` | `95` | no |
| performance_threshold | Performance threshold in milliseconds | `number` | `5000` | no |
| monitored_function_apps | Map of Function Apps to monitor | `map(object({resource_id = string, name = string}))` | `{}` | no |
| enable_storage_monitoring | Enable storage account for monitoring data | `bool` | `false` | no |
| enable_vm_insights | Enable VM Insights data collection | `bool` | `false` | no |
| enable_workspace_diagnostics | Enable diagnostic settings for Log Analytics workspace | `bool` | `true` | no |
| enable_private_endpoints | Enable private endpoints for monitoring resources | `bool` | `false` | no |
| enable_security_center | Enable Security Center solution | `bool` | `true` | no |
| enable_update_management | Enable Update Management solution | `bool` | `false` | no |
| enable_workbook | Enable monitoring workbook | `bool` | `true` | no |
| enable_log_alerts | Enable log query alerts | `bool` | `true` | no |
| enable_activity_log_alerts | Enable activity log alerts | `bool` | `true` | no |
| enable_budget_alerts | Enable budget alerts | `bool` | `false` | no |
| enable_smart_detection | Enable Application Insights smart detection | `bool` | `true` | no |
| enable_availability_tests | Enable availability test alerts | `bool` | `false` | no |
| private_endpoint_subnet_id | Subnet ID for private endpoints | `string` | `null` | no |
| private_dns_zone_ids | List of private DNS zone IDs | `list(string)` | `[]` | no |
| budget_amount | Budget amount for monitoring resources | `number` | `100` | no |
| budget_notification_emails | List of email addresses for budget notifications | `list(string)` | `[]` | no |
| smart_detection_emails | List of email addresses for smart detection notifications | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| log_analytics_workspace_id | ID of the Log Analytics Workspace |
| log_analytics_workspace_name | Name of the Log Analytics Workspace |
| application_insights_id | ID of the Application Insights instance |
| application_insights_name | Name of the Application Insights instance |
| application_insights_connection_string | Connection string for Application Insights |
| application_insights_instrumentation_key | Instrumentation key for Application Insights |
| application_insights_app_id | App ID for Application Insights |
| action_group_id | ID of the monitoring action group |
| action_group_name | Name of the monitoring action group |
| monitoring_configuration | Summary of monitoring configuration |
| resource_names | Names of created monitoring resources |

## Examples

See the [examples](./examples/) directory for complete usage examples:

- [Basic](./examples/basic/) - Minimal monitoring setup
- [Complete](./examples/complete/) - Full-featured monitoring with all options

## License

This module is licensed under the Apache License 2.0 - see the [LICENSE](../../LICENSE) file for details.
