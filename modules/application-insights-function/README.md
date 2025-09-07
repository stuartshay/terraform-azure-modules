# Application Insights Function Module

This Terraform module creates comprehensive monitoring, alerting, and dashboards for Azure Function Apps and App Service Plans within a Resource Group. It provides performance monitoring, failure detection, and operational insights specifically tailored for serverless function workloads.

## Features

- **Function App Monitoring**:
  - Function execution duration tracking
  - Function failure rate monitoring
  - Function invocation count alerts
  - Cold start detection and alerting
  - Exception tracking and analysis

- **App Service Plan Monitoring**:
  - CPU and memory usage alerts
  - Resource utilization tracking
  - Scaling event monitoring
  - Performance threshold alerts

- **Advanced Analytics**:
  - Cold start pattern analysis
  - Dependency performance tracking
  - Exception rate monitoring
  - Performance percentile analysis (P50, P95, P99)

- **Interactive Dashboard**:
  - Function invocation trends
  - Execution duration visualization
  - Success rate tracking
  - Dependency analysis
  - Real-time performance metrics

- **Flexible Configuration**:
  - Configurable alert thresholds
  - Selective monitoring of specific Function Apps
  - Optional Log Analytics integration
  - Customizable dashboard time ranges

## Usage

### Basic Usage

```hcl
module "app_insights_function" {
  source = "./modules/application-insights-function"

  # Required variables
  resource_group_name       = "rg-myapp-prod-eus-001"
  location                 = "East US"
  application_insights_name = "appi-myapp-prod-eus-001"

  # Function Apps to monitor
  function_app_names = [
    "func-myapp-api-prod-eus-001",
    "func-myapp-worker-prod-eus-001"
  ]

  # App Service Plans to monitor
  app_service_plan_names = [
    "asp-myapp-functions-prod-001"
  ]

  # Optional naming
  workload    = "myapp"
  environment = "prod"

  tags = {
    Environment = "Production"
    Project     = "MyApp"
    Team        = "Platform"
  }
}
```

### Advanced Usage with Custom Thresholds

```hcl
module "app_insights_function" {
  source = "./modules/application-insights-function"

  # Required variables
  resource_group_name       = "rg-myapp-prod-eus-001"
  location                 = "East US"
  application_insights_name = "appi-myapp-prod-eus-001"

  # Function Apps to monitor
  function_app_names = [
    "func-myapp-api-prod-eus-001",
    "func-myapp-worker-prod-eus-001",
    "func-myapp-scheduler-prod-eus-001"
  ]

  # App Service Plans to monitor
  app_service_plan_names = [
    "asp-myapp-functions-prod-001",
    "asp-myapp-premium-prod-001"
  ]

  # Custom function alert thresholds
  function_duration_threshold_ms    = 15000  # 15 seconds
  function_failure_rate_threshold   = 2      # 2%
  function_min_invocations_threshold = 10    # Alert if < 10 invocations in 15 min

  # Custom App Service Plan thresholds
  cpu_threshold_percent    = 70  # 70%
  memory_threshold_percent = 75  # 75%

  # Advanced monitoring with Log Analytics
  log_analytics_workspace_name = "log-myapp-prod-eus-001"
  enable_cold_start_detection  = true
  enable_exception_detection   = true
  cold_start_threshold         = 3
  exception_rate_threshold     = 5

  # Custom alert severities
  function_duration_alert_severity = 1  # Error
  function_failure_alert_severity  = 0  # Critical
  app_service_cpu_alert_severity   = 2  # Warning

  # Dashboard configuration
  dashboard_display_name = "MyApp Production Function Monitoring"
  dashboard_time_range   = 14  # 14 days

  # Feature toggles
  enable_dependency_tracking  = true
  enable_performance_counters = true

  workload    = "myapp"
  environment = "prod"

  tags = {
    Environment = "Production"
    Project     = "MyApp"
    Team        = "Platform"
    Criticality = "High"
  }
}
```

### Development Environment Configuration

```hcl
module "app_insights_function_dev" {
  source = "./modules/application-insights-function"

  # Required variables
  resource_group_name       = "rg-myapp-dev-eus-001"
  location                 = "East US"
  application_insights_name = "appi-myapp-dev-eus-001"

  # Monitor all Function Apps in the resource group
  function_app_names = null  # Will discover all Function Apps
  app_service_plan_names = null  # Will discover all App Service Plans

  # Relaxed thresholds for development
  function_duration_threshold_ms  = 60000  # 60 seconds
  function_failure_rate_threshold = 10     # 10%
  cpu_threshold_percent           = 90     # 90%
  memory_threshold_percent        = 90     # 90%

  # Disable advanced monitoring for dev
  enable_cold_start_detection = false
  enable_exception_detection  = false

  # Shorter dashboard time range
  dashboard_time_range = 3  # 3 days

  workload    = "myapp"
  environment = "dev"

  tags = {
    Environment = "Development"
    Project     = "MyApp"
  }
}
```

### Integration with Existing Function App Module

```hcl
# Create Function App with App Service Plan
module "function_app" {
  source = "./modules/function-app"

  resource_group_name = "rg-myapp-prod-eus-001"
  location           = "East US"
  service_plan_id    = module.app_service_plan.id

  workload    = "myapp"
  environment = "prod"

  enable_application_insights = true
  log_analytics_workspace_id  = module.log_analytics.id

  tags = {
    Environment = "Production"
    Project     = "MyApp"
  }
}

module "app_service_plan" {
  source = "./modules/app-service-plan-function"

  resource_group_name = "rg-myapp-prod-eus-001"
  location           = "East US"
  sku_name           = "EP1"

  workload    = "myapp"
  environment = "prod"

  tags = {
    Environment = "Production"
    Project     = "MyApp"
  }
}

# Add comprehensive monitoring
module "function_monitoring" {
  source = "./modules/application-insights-function"

  resource_group_name       = module.function_app.resource_group_name
  location                 = module.function_app.location
  application_insights_name = module.function_app.application_insights_name

  function_app_names = [module.function_app.name]
  app_service_plan_names = [module.app_service_plan.name]

  log_analytics_workspace_name = module.log_analytics.name

  workload    = "myapp"
  environment = "prod"

  tags = {
    Environment = "Production"
    Project     = "MyApp"
  }

  depends_on = [module.function_app, module.app_service_plan]
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
| [azurerm_monitor_metric_alert.function_duration](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.function_failure_rate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.function_low_activity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.app_service_cpu](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.app_service_memory](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_scheduled_query_rules_alert_v2.cold_starts](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_scheduled_query_rules_alert_v2) | resource |
| [azurerm_monitor_scheduled_query_rules_alert_v2.function_exceptions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_scheduled_query_rules_alert_v2) | resource |
| [azurerm_application_insights_workbook.function_dashboard](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights_workbook) | resource |
| [random_uuid.function_dashboard](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |
| [azurerm_application_insights.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/application_insights) | data source |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_log_analytics_workspace.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/log_analytics_workspace) | data source |
| [azurerm_function_app.functions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/function_app) | data source |
| [azurerm_service_plan.plans](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/service_plan) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| resource_group_name | Name of the resource group containing the Function Apps and App Service Plans | `string` | n/a | yes |
| location | Azure region for resources | `string` | n/a | yes |
| application_insights_name | Name of the existing Application Insights instance | `string` | n/a | yes |
| workload | Name of the workload or application (used in naming convention) | `string` | `"app"` | no |
| environment | Environment name (dev, staging, prod) (used in naming convention) | `string` | `"dev"` | no |
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |
| log_analytics_workspace_name | Name of the Log Analytics Workspace (optional, for advanced queries) | `string` | `null` | no |
| function_app_names | List of Function App names to monitor (if null, will monitor all Function Apps in the resource group) | `list(string)` | `null` | no |
| app_service_plan_names | List of App Service Plan names to monitor (if null, will monitor all App Service Plans in the resource group) | `list(string)` | `null` | no |
| enable_function_alerts | Enable function-specific alerts | `bool` | `true` | no |
| function_duration_threshold_ms | Function execution duration threshold in milliseconds | `number` | `30000` | no |
| function_duration_alert_severity | Severity level for function duration alert (0-4, where 0 is critical) | `number` | `2` | no |
| function_failure_rate_threshold | Function failure rate threshold (percentage) | `number` | `5` | no |
| function_failure_alert_severity | Severity level for function failure alert (0-4, where 0 is critical) | `number` | `1` | no |
| function_min_invocations_threshold | Minimum function invocations threshold (set to 0 to disable low activity alerts) | `number` | `0` | no |
| function_activity_alert_severity | Severity level for function low activity alert (0-4, where 0 is critical) | `number` | `3` | no |
| enable_app_service_alerts | Enable App Service Plan alerts | `bool` | `true` | no |
| cpu_threshold_percent | CPU usage threshold percentage for App Service Plans | `number` | `80` | no |
| app_service_cpu_alert_severity | Severity level for App Service Plan CPU alert (0-4, where 0 is critical) | `number` | `2` | no |
| memory_threshold_percent | Memory usage threshold percentage for App Service Plans | `number` | `80` | no |
| app_service_memory_alert_severity | Severity level for App Service Plan memory alert (0-4, where 0 is critical) | `number` | `2` | no |
| enable_cold_start_detection | Enable cold start detection alerts (requires Log Analytics workspace) | `bool` | `true` | no |
| cold_start_threshold | Cold start count threshold (per 5-minute window) | `number` | `5` | no |
| cold_start_alert_severity | Severity level for cold start alert (0-4, where 0 is critical) | `number` | `3` | no |
| enable_exception_detection | Enable exception detection alerts (requires Log Analytics workspace) | `bool` | `true` | no |
| exception_rate_threshold | Exception rate threshold (count per 5-minute window) | `number` | `10` | no |
| exception_alert_severity | Severity level for exception alert (0-4, where 0 is critical) | `number` | `1` | no |
| enable_function_dashboard | Enable Function App monitoring dashboard creation | `bool` | `true` | no |
| dashboard_display_name | Display name for the Function App monitoring dashboard | `string` | `null` | no |
| dashboard_time_range | Default time range for dashboard queries (in days) | `number` | `7` | no |
| notification_action_group_id | Action Group ID for alert notifications (optional) | `string` | `null` | no |
| enable_dependency_tracking | Enable dependency tracking in dashboard | `bool` | `true` | no |
| enable_performance_counters | Enable performance counter monitoring | `bool` | `true` | no |
| enable_custom_metrics | Enable custom metrics monitoring | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| function_duration_alert_id | ID of the function duration alert rule |
| function_failure_alert_id | ID of the function failure rate alert rule |
| function_low_activity_alert_id | ID of the function low activity alert rule |
| app_service_cpu_alert_ids | Map of App Service Plan CPU alert rule IDs |
| app_service_memory_alert_ids | Map of App Service Plan memory alert rule IDs |
| cold_start_alert_id | ID of the cold start detection alert rule |
| exception_alert_id | ID of the function exception alert rule |
| alert_rule_names | Map of alert rule names |
| app_service_alert_names | Map of App Service Plan alert rule names |
| function_dashboard_id | ID of the Function App monitoring dashboard |
| function_dashboard_name | Name of the Function App monitoring dashboard |
| function_dashboard_display_name | Display name of the Function App monitoring dashboard |
| application_insights_id | ID of the monitored Application Insights instance |
| application_insights_name | Name of the monitored Application Insights instance |
| application_insights_app_id | App ID of the monitored Application Insights instance |
| resource_group_id | ID of the monitored resource group |
| resource_group_name | Name of the monitored resource group |
| monitored_function_apps | Information about monitored Function Apps |
| monitored_app_service_plans | Information about monitored App Service Plans |
| log_analytics_workspace_id | ID of the Log Analytics Workspace (if provided) |
| log_analytics_workspace_name | Name of the Log Analytics Workspace (if provided) |
| function_monitoring_configuration | Summary of Function App monitoring configuration |
| alert_summary | Summary of configured alerts |
| dashboard_summary | Summary of dashboard configuration |
| location | Azure region where monitoring resources are deployed |
| tags | Tags applied to the monitoring resources |
| feature_flags | Summary of enabled features |

## Alert Severity Levels

- **0**: Critical
- **1**: Error
- **2**: Warning
- **3**: Informational
- **4**: Verbose

## Default Alert Thresholds

- **Function Duration**: 30,000ms (30 seconds)
- **Function Failure Rate**: 5%
- **CPU Usage**: 80%
- **Memory Usage**: 80%
- **Cold Start Threshold**: 5 occurrences per 5 minutes
- **Exception Rate**: 10 exceptions per 5 minutes

## Dashboard Features

The Function monitoring dashboard provides:

- **Function Invocations**: Real-time invocation trends over time
- **Execution Duration**: Performance percentiles (P50, P95, P99)
- **Success Rates**: Function success rates by application
- **Failure Analysis**: Failure trends by result code
- **Dependency Tracking**: Top dependencies by call count
- **Cold Start Analysis**: Cold start patterns and frequency
- **Exception Monitoring**: Exception trends by type
- **24-Hour Summary**: Key metrics and statistics

## Monitoring Capabilities

### Function-Specific Metrics

- **Execution Time**: Track function execution duration and identify performance bottlenecks
- **Invocation Count**: Monitor function usage patterns and detect anomalies
- **Success Rate**: Track function reliability and failure patterns
- **Cold Starts**: Identify and optimize cold start occurrences
- **Dependencies**: Monitor external service calls and performance

### App Service Plan Metrics

- **Resource Utilization**: CPU and memory usage monitoring
- **Scaling Events**: Track auto-scaling behavior
- **Instance Health**: Monitor plan instance availability
- **Performance Trends**: Historical resource usage analysis

### Advanced Analytics

- **Performance Percentiles**: P50, P95, P99 execution time analysis
- **Error Rate Trends**: Failure pattern identification
- **Dependency Performance**: External service impact analysis
- **Cost Optimization**: Resource utilization insights

## Prerequisites

1. **Azure Subscription**: Active Azure subscription with appropriate permissions
2. **Resource Group**: Existing resource group containing Function Apps
3. **Application Insights**: Existing Application Insights instance
4. **Function Apps**: One or more Function Apps to monitor
5. **App Service Plans**: App Service Plans hosting the Function Apps
6. **Log Analytics Workspace** (optional): Required for advanced alerts (cold start, exception detection)

## Permissions Required

The service principal or user running Terraform needs:

- `Contributor` or `Monitoring Contributor` role on the resource group
- `Application Insights Component Contributor` for dashboard creation
- `Log Analytics Contributor` (if using Log Analytics workspace)
- `Reader` access to Function Apps and App Service Plans

## Best Practices

### Alert Configuration

1. **Start Conservative**: Begin with higher thresholds and adjust based on baseline performance
2. **Environment-Specific**: Use different thresholds for dev, staging, and production
3. **Severity Mapping**: Align alert severities with your incident response procedures
4. **Action Groups**: Configure appropriate notification channels for each severity level

### Dashboard Usage

1. **Regular Review**: Monitor dashboard regularly to identify trends
2. **Performance Baselines**: Establish performance baselines for comparison
3. **Capacity Planning**: Use resource utilization data for scaling decisions
4. **Cost Optimization**: Identify underutilized resources for optimization

### Function Optimization

1. **Cold Start Reduction**: Monitor cold start patterns and optimize accordingly
2. **Dependency Performance**: Track external service performance impact
3. **Error Handling**: Use exception tracking to improve error handling
4. **Resource Sizing**: Use performance data to optimize Function App sizing

## Troubleshooting

### Common Issues

1. **Missing Metrics**: Ensure Application Insights is properly configured for Function Apps
2. **Alert Not Firing**: Verify alert thresholds and evaluation windows
3. **Dashboard Empty**: Check that Function Apps are sending telemetry to Application Insights
4. **Permission Errors**: Verify required permissions on all resources

### Validation Steps

1. **Verify Function Apps**: Ensure Function Apps are running and sending telemetry
2. **Check Application Insights**: Confirm telemetry data is flowing
3. **Test Alerts**: Validate alert rules are properly configured
4. **Dashboard Access**: Confirm dashboard is accessible and displaying data

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
| [azurerm_application_insights_workbook.function_dashboard](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights_workbook) | resource |
| [azurerm_monitor_metric_alert.app_service_cpu](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.app_service_memory](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.function_duration](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.function_failure_rate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.function_low_activity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_scheduled_query_rules_alert_v2.cold_starts](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_scheduled_query_rules_alert_v2) | resource |
| [azurerm_monitor_scheduled_query_rules_alert_v2.function_exceptions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_scheduled_query_rules_alert_v2) | resource |
| [random_uuid.function_dashboard](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |
| [azurerm_application_insights.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/application_insights) | data source |
| [azurerm_function_app.functions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/function_app) | data source |
| [azurerm_log_analytics_workspace.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/log_analytics_workspace) | data source |
| [azurerm_resource_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_service_plan.plans](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/service_plan) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_service_cpu_alert_severity"></a> [app\_service\_cpu\_alert\_severity](#input\_app\_service\_cpu\_alert\_severity) | Severity level for App Service Plan CPU alert (0-4, where 0 is critical) | `number` | `2` | no |
| <a name="input_app_service_memory_alert_severity"></a> [app\_service\_memory\_alert\_severity](#input\_app\_service\_memory\_alert\_severity) | Severity level for App Service Plan memory alert (0-4, where 0 is critical) | `number` | `2` | no |
| <a name="input_app_service_plan_names"></a> [app\_service\_plan\_names](#input\_app\_service\_plan\_names) | List of App Service Plan names to monitor (if null, will monitor all App Service Plans in the resource group) | `list(string)` | `null` | no |
| <a name="input_application_insights_name"></a> [application\_insights\_name](#input\_application\_insights\_name) | Name of the existing Application Insights instance | `string` | n/a | yes |
| <a name="input_cold_start_alert_severity"></a> [cold\_start\_alert\_severity](#input\_cold\_start\_alert\_severity) | Severity level for cold start alert (0-4, where 0 is critical) | `number` | `3` | no |
| <a name="input_cold_start_threshold"></a> [cold\_start\_threshold](#input\_cold\_start\_threshold) | Cold start count threshold (per 5-minute window) | `number` | `5` | no |
| <a name="input_cpu_threshold_percent"></a> [cpu\_threshold\_percent](#input\_cpu\_threshold\_percent) | CPU usage threshold percentage for App Service Plans | `number` | `80` | no |
| <a name="input_dashboard_display_name"></a> [dashboard\_display\_name](#input\_dashboard\_display\_name) | Display name for the Function App monitoring dashboard | `string` | `null` | no |
| <a name="input_dashboard_time_range"></a> [dashboard\_time\_range](#input\_dashboard\_time\_range) | Default time range for dashboard queries (in days) | `number` | `7` | no |
| <a name="input_enable_app_service_alerts"></a> [enable\_app\_service\_alerts](#input\_enable\_app\_service\_alerts) | Enable App Service Plan alerts | `bool` | `true` | no |
| <a name="input_enable_cold_start_detection"></a> [enable\_cold\_start\_detection](#input\_enable\_cold\_start\_detection) | Enable cold start detection alerts (requires Log Analytics workspace) | `bool` | `true` | no |
| <a name="input_enable_custom_metrics"></a> [enable\_custom\_metrics](#input\_enable\_custom\_metrics) | Enable custom metrics monitoring | `bool` | `false` | no |
| <a name="input_enable_dependency_tracking"></a> [enable\_dependency\_tracking](#input\_enable\_dependency\_tracking) | Enable dependency tracking in dashboard | `bool` | `true` | no |
| <a name="input_enable_exception_detection"></a> [enable\_exception\_detection](#input\_enable\_exception\_detection) | Enable exception detection alerts (requires Log Analytics workspace) | `bool` | `true` | no |
| <a name="input_enable_function_alerts"></a> [enable\_function\_alerts](#input\_enable\_function\_alerts) | Enable function-specific alerts | `bool` | `true` | no |
| <a name="input_enable_function_dashboard"></a> [enable\_function\_dashboard](#input\_enable\_function\_dashboard) | Enable Function App monitoring dashboard creation | `bool` | `true` | no |
| <a name="input_enable_performance_counters"></a> [enable\_performance\_counters](#input\_enable\_performance\_counters) | Enable performance counter monitoring | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, staging, prod) (used in naming convention) | `string` | `"dev"` | no |
| <a name="input_exception_alert_severity"></a> [exception\_alert\_severity](#input\_exception\_alert\_severity) | Severity level for exception alert (0-4, where 0 is critical) | `number` | `1` | no |
| <a name="input_exception_rate_threshold"></a> [exception\_rate\_threshold](#input\_exception\_rate\_threshold) | Exception rate threshold (count per 5-minute window) | `number` | `10` | no |
| <a name="input_function_activity_alert_severity"></a> [function\_activity\_alert\_severity](#input\_function\_activity\_alert\_severity) | Severity level for function low activity alert (0-4, where 0 is critical) | `number` | `3` | no |
| <a name="input_function_app_names"></a> [function\_app\_names](#input\_function\_app\_names) | List of Function App names to monitor (if null, will monitor all Function Apps in the resource group) | `list(string)` | `null` | no |
| <a name="input_function_duration_alert_severity"></a> [function\_duration\_alert\_severity](#input\_function\_duration\_alert\_severity) | Severity level for function duration alert (0-4, where 0 is critical) | `number` | `2` | no |
| <a name="input_function_duration_threshold_ms"></a> [function\_duration\_threshold\_ms](#input\_function\_duration\_threshold\_ms) | Function execution duration threshold in milliseconds | `number` | `30000` | no |
| <a name="input_function_failure_alert_severity"></a> [function\_failure\_alert\_severity](#input\_function\_failure\_alert\_severity) | Severity level for function failure alert (0-4, where 0 is critical) | `number` | `1` | no |
| <a name="input_function_failure_rate_threshold"></a> [function\_failure\_rate\_threshold](#input\_function\_failure\_rate\_threshold) | Function failure rate threshold (percentage) | `number` | `5` | no |
| <a name="input_function_min_invocations_threshold"></a> [function\_min\_invocations\_threshold](#input\_function\_min\_invocations\_threshold) | Minimum function invocations threshold (set to 0 to disable low activity alerts) | `number` | `0` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for resources | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_name"></a> [log\_analytics\_workspace\_name](#input\_log\_analytics\_workspace\_name) | Name of the Log Analytics Workspace (optional, for advanced queries) | `string` | `null` | no |
| <a name="input_memory_threshold_percent"></a> [memory\_threshold\_percent](#input\_memory\_threshold\_percent) | Memory usage threshold percentage for App Service Plans | `number` | `80` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group containing the Function Apps and App Service Plans | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Name of the workload or application (used in naming convention) | `string` | `"app"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alert_rule_names"></a> [alert\_rule\_names](#output\_alert\_rule\_names) | Map of alert rule names |
| <a name="output_alert_summary"></a> [alert\_summary](#output\_alert\_summary) | Summary of configured alerts |
| <a name="output_app_service_alert_names"></a> [app\_service\_alert\_names](#output\_app\_service\_alert\_names) | Map of App Service Plan alert rule names |
| <a name="output_app_service_cpu_alert_ids"></a> [app\_service\_cpu\_alert\_ids](#output\_app\_service\_cpu\_alert\_ids) | Map of App Service Plan CPU alert rule IDs |
| <a name="output_app_service_memory_alert_ids"></a> [app\_service\_memory\_alert\_ids](#output\_app\_service\_memory\_alert\_ids) | Map of App Service Plan memory alert rule IDs |
| <a name="output_application_insights_app_id"></a> [application\_insights\_app\_id](#output\_application\_insights\_app\_id) | App ID of the monitored Application Insights instance |
| <a name="output_application_insights_id"></a> [application\_insights\_id](#output\_application\_insights\_id) | ID of the monitored Application Insights instance |
| <a name="output_application_insights_name"></a> [application\_insights\_name](#output\_application\_insights\_name) | Name of the monitored Application Insights instance |
| <a name="output_cold_start_alert_id"></a> [cold\_start\_alert\_id](#output\_cold\_start\_alert\_id) | ID of the cold start detection alert rule |
| <a name="output_dashboard_summary"></a> [dashboard\_summary](#output\_dashboard\_summary) | Summary of dashboard configuration |
| <a name="output_exception_alert_id"></a> [exception\_alert\_id](#output\_exception\_alert\_id) | ID of the function exception alert rule |
| <a name="output_feature_flags"></a> [feature\_flags](#output\_feature\_flags) | Summary of enabled features |
| <a name="output_function_dashboard_display_name"></a> [function\_dashboard\_display\_name](#output\_function\_dashboard\_display\_name) | Display name of the Function App monitoring dashboard |
| <a name="output_function_dashboard_id"></a> [function\_dashboard\_id](#output\_function\_dashboard\_id) | ID of the Function App monitoring dashboard |
| <a name="output_function_dashboard_name"></a> [function\_dashboard\_name](#output\_function\_dashboard\_name) | Name of the Function App monitoring dashboard |
| <a name="output_function_duration_alert_id"></a> [function\_duration\_alert\_id](#output\_function\_duration\_alert\_id) | ID of the function duration alert rule |
| <a name="output_function_failure_alert_id"></a> [function\_failure\_alert\_id](#output\_function\_failure\_alert\_id) | ID of the function failure rate alert rule |
| <a name="output_function_low_activity_alert_id"></a> [function\_low\_activity\_alert\_id](#output\_function\_low\_activity\_alert\_id) | ID of the function low activity alert rule |
| <a name="output_function_monitoring_configuration"></a> [function\_monitoring\_configuration](#output\_function\_monitoring\_configuration) | Summary of Function App monitoring configuration |
| <a name="output_location"></a> [location](#output\_location) | Azure region where monitoring resources are deployed |
| <a name="output_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#output\_log\_analytics\_workspace\_id) | ID of the Log Analytics Workspace (if provided) |
| <a name="output_log_analytics_workspace_name"></a> [log\_analytics\_workspace\_name](#output\_log\_analytics\_workspace\_name) | Name of the Log Analytics Workspace (if provided) |
| <a name="output_monitored_app_service_plans"></a> [monitored\_app\_service\_plans](#output\_monitored\_app\_service\_plans) | Information about monitored App Service Plans |
| <a name="output_monitored_function_apps"></a> [monitored\_function\_apps](#output\_monitored\_function\_apps) | Information about monitored Function Apps |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | ID of the monitored resource group |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Name of the monitored resource group |
| <a name="output_tags"></a> [tags](#output\_tags) | Tags applied to the monitoring resources |
<!-- END_TF_DOCS -->
