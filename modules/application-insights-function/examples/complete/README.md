# Complete Application Insights Function Monitoring Example

This example demonstrates the full capabilities of the Application Insights Function module, including:

- **Complete Azure Function App setup** with Application Insights integration
- **Advanced monitoring** with Log Analytics workspace
- **Comprehensive alerting** for function performance, failures, and resource usage
- **Cold start and exception detection** using KQL queries
- **Interactive dashboard** with multiple visualizations
- **App Service Plan monitoring** for CPU and memory usage

## Architecture

This example creates:

1. **Resource Group** - Container for all resources
2. **Log Analytics Workspace** - For advanced monitoring and KQL queries
3. **Application Insights** - Connected to Log Analytics for telemetry
4. **Storage Account** - Required for Function Apps
5. **App Service Plan** - Linux consumption plan for Function Apps
6. **Function Apps** - Multiple Node.js Function Apps with Application Insights integration
7. **Monitoring Module** - Complete monitoring setup with alerts and dashboard

## Features Demonstrated

### Function Monitoring
- **Duration alerts** - Triggers when function execution time exceeds threshold
- **Failure rate alerts** - Monitors function success/failure rates
- **Low activity alerts** - Detects when functions aren't being invoked
- **Cold start detection** - Advanced monitoring using Log Analytics queries
- **Exception monitoring** - Tracks and alerts on function exceptions

### App Service Plan Monitoring
- **CPU usage alerts** - Monitors App Service Plan CPU consumption
- **Memory usage alerts** - Tracks memory utilization

### Dashboard Features
- **Function invocations over time** - Trend analysis
- **Execution duration percentiles** - Performance analysis (P50, P95, P99)
- **Success rates by function** - Reliability metrics
- **Failure analysis by result code** - Error categorization
- **Dependency tracking** - External service call monitoring
- **Cold start trends** - Performance impact analysis
- **Exception tracking** - Error monitoring and categorization
- **24-hour summary** - Key metrics overview

## Usage

### Prerequisites

- Azure subscription with appropriate permissions
- Terraform >= 1.0
- Azure CLI (for authentication)

### Deployment

1. **Clone the repository and navigate to this example:**
   ```bash
   cd modules/application-insights-function/examples/complete
   ```

2. **Initialize Terraform:**
   ```bash
   terraform init
   ```

3. **Review and customize variables:**
   ```bash
   # Copy and modify terraform.tfvars.example if needed
   cp terraform.tfvars.example terraform.tfvars
   ```

4. **Plan the deployment:**
   ```bash
   terraform plan
   ```

5. **Apply the configuration:**
   ```bash
   terraform apply
   ```

### Customization

You can customize the deployment by modifying variables in `terraform.tfvars`:

```hcl
# Basic configuration
location    = "West Europe"
workload    = "myapp"
environment = "prod"

# Function Apps to create
function_app_names = ["api-functions", "background-processor"]

# Alert thresholds
function_duration_threshold_ms  = 45000  # 45 seconds
function_failure_rate_threshold = 3      # 3%
cpu_threshold_percent          = 75      # 75%
memory_threshold_percent       = 80      # 80%

# Advanced monitoring thresholds
cold_start_threshold     = 10  # 10 cold starts in 15 minutes
exception_rate_threshold = 5   # 5 exceptions in 15 minutes

# Alert severities (0=Critical, 1=Error, 2=Warning, 3=Informational, 4=Verbose)
function_duration_alert_severity = 2
function_failure_alert_severity  = 1
cold_start_alert_severity        = 3
exception_alert_severity         = 1

# Dashboard configuration
dashboard_time_range = 30  # 30 days of data
```

## Monitoring Capabilities

### Alerts Created

| Alert Type | Metric | Threshold | Severity |
|------------|--------|-----------|----------|
| Function Duration | Average execution time | 30 seconds | Warning |
| Function Failures | Failure rate percentage | 5% | Error |
| Function Low Activity | Invocation count | 10 per 15 min | Informational |
| App Service CPU | CPU percentage | 80% | Warning |
| App Service Memory | Memory percentage | 85% | Warning |
| Cold Starts | Count per 15 min | 5 | Informational |
| Exceptions | Count per 15 min | 10 | Error |

### Dashboard Visualizations

1. **Function Invocations Over Time** - Line chart showing request volume
2. **Function Execution Duration** - Percentile analysis (P50, P95, P99)
3. **Function Success Rates** - Table with success/failure statistics
4. **Function Failures by Result Code** - Error categorization
5. **Top Dependencies** - External service call analysis
6. **Cold Starts Over Time** - Performance impact tracking
7. **Exceptions by Type** - Error monitoring
8. **24-Hour Summary** - Key performance indicators

## Outputs

After deployment, you'll receive:

- **Resource identifiers** - IDs and names of created resources
- **Application Insights connection details** - For application configuration
- **Monitoring URLs** - Direct links to dashboards and alerts
- **Function App details** - Names and IDs for reference

## Clean Up

To remove all resources:

```bash
terraform destroy
```

## Security Considerations

This example includes:
- **Secure storage** configuration for Function Apps
- **Application Insights** integration with workspace-based telemetry
- **Sensitive output** protection for connection strings
- **Resource tagging** for governance and cost management

## Cost Optimization

- Uses **Consumption plan** for Function Apps (pay-per-execution)
- **Log Analytics** with 30-day retention (configurable)
- **Application Insights** workspace-based pricing
- **Storage account** with standard tier

## Next Steps

After deployment, consider:

1. **Configure notification channels** for alerts (email, SMS, webhooks)
2. **Set up action groups** for automated responses
3. **Customize dashboard** queries for specific business metrics
4. **Implement application-level** telemetry in your Function code
5. **Review and adjust** alert thresholds based on actual usage patterns

## Troubleshooting

### Common Issues

1. **Function Apps not appearing in dashboard:**
   - Ensure Application Insights connection string is configured
   - Verify functions are being invoked to generate telemetry

2. **Alerts not triggering:**
   - Check alert thresholds against actual metrics
   - Verify notification action groups are configured

3. **Dashboard showing no data:**
   - Confirm Log Analytics workspace connection
   - Check time range settings in dashboard

### Useful Commands

```bash
# Check Function App logs
az functionapp log tail --name <function-app-name> --resource-group <resource-group>

# View Application Insights metrics
az monitor metrics list --resource <app-insights-resource-id>

# Test alert rules
az monitor metrics alert show --name <alert-name> --resource-group <resource-group>

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.42.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1 |
| <a name="requirement_required_version"></a> [required\_version](#requirement\_required\_version) | >= 1.13.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.42.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_function_monitoring"></a> [function\_monitoring](#module\_function\_monitoring) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_application_insights.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights) | resource |
| [azurerm_linux_function_app.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app) | resource |
| [azurerm_log_analytics_workspace.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_service_plan.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |
| [azurerm_storage_account.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_service_cpu_alert_severity"></a> [app\_service\_cpu\_alert\_severity](#input\_app\_service\_cpu\_alert\_severity) | Severity level for App Service Plan CPU alerts (0-4) | `number` | `2` | no |
| <a name="input_app_service_memory_alert_severity"></a> [app\_service\_memory\_alert\_severity](#input\_app\_service\_memory\_alert\_severity) | Severity level for App Service Plan memory alerts (0-4) | `number` | `2` | no |
| <a name="input_cold_start_alert_severity"></a> [cold\_start\_alert\_severity](#input\_cold\_start\_alert\_severity) | Severity level for cold start alerts (0-4) | `number` | `3` | no |
| <a name="input_cold_start_threshold"></a> [cold\_start\_threshold](#input\_cold\_start\_threshold) | Cold start count threshold for alerting | `number` | `5` | no |
| <a name="input_cpu_threshold_percent"></a> [cpu\_threshold\_percent](#input\_cpu\_threshold\_percent) | App Service Plan CPU usage threshold percentage | `number` | `80` | no |
| <a name="input_dashboard_display_name"></a> [dashboard\_display\_name](#input\_dashboard\_display\_name) | Display name for the monitoring dashboard | `string` | `null` | no |
| <a name="input_dashboard_time_range"></a> [dashboard\_time\_range](#input\_dashboard\_time\_range) | Time range for dashboard queries in days | `number` | `7` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment (e.g., dev, staging, prod) | `string` | `"dev"` | no |
| <a name="input_exception_alert_severity"></a> [exception\_alert\_severity](#input\_exception\_alert\_severity) | Severity level for exception alerts (0-4) | `number` | `1` | no |
| <a name="input_exception_rate_threshold"></a> [exception\_rate\_threshold](#input\_exception\_rate\_threshold) | Exception rate threshold for alerting | `number` | `10` | no |
| <a name="input_function_activity_alert_severity"></a> [function\_activity\_alert\_severity](#input\_function\_activity\_alert\_severity) | Severity level for function low activity alerts (0-4) | `number` | `3` | no |
| <a name="input_function_app_names"></a> [function\_app\_names](#input\_function\_app\_names) | List of Function App names to create and monitor | `list(string)` | <pre>[<br/>  "func-api",<br/>  "func-processor",<br/>  "func-scheduler"<br/>]</pre> | no |
| <a name="input_function_duration_alert_severity"></a> [function\_duration\_alert\_severity](#input\_function\_duration\_alert\_severity) | Severity level for function duration alerts (0-4) | `number` | `2` | no |
| <a name="input_function_duration_threshold_ms"></a> [function\_duration\_threshold\_ms](#input\_function\_duration\_threshold\_ms) | Function execution duration threshold in milliseconds | `number` | `30000` | no |
| <a name="input_function_failure_alert_severity"></a> [function\_failure\_alert\_severity](#input\_function\_failure\_alert\_severity) | Severity level for function failure alerts (0-4) | `number` | `1` | no |
| <a name="input_function_failure_rate_threshold"></a> [function\_failure\_rate\_threshold](#input\_function\_failure\_rate\_threshold) | Function failure rate threshold percentage | `number` | `5` | no |
| <a name="input_function_min_invocations_threshold"></a> [function\_min\_invocations\_threshold](#input\_function\_min\_invocations\_threshold) | Minimum function invocations threshold for low activity alerts | `number` | `10` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where resources will be created | `string` | `"East US"` | no |
| <a name="input_memory_threshold_percent"></a> [memory\_threshold\_percent](#input\_memory\_threshold\_percent) | App Service Plan memory usage threshold percentage | `number` | `85` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resources | `map(string)` | <pre>{<br/>  "Environment": "dev",<br/>  "ManagedBy": "terraform",<br/>  "Project": "function-monitoring"<br/>}</pre> | no |
| <a name="input_workload"></a> [workload](#input\_workload) | The name of the workload | `string` | `"example"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_service_plan_id"></a> [app\_service\_plan\_id](#output\_app\_service\_plan\_id) | The ID of the App Service Plan |
| <a name="output_app_service_plan_name"></a> [app\_service\_plan\_name](#output\_app\_service\_plan\_name) | The name of the App Service Plan |
| <a name="output_application_insights_connection_string"></a> [application\_insights\_connection\_string](#output\_application\_insights\_connection\_string) | The connection string of the Application Insights instance |
| <a name="output_application_insights_id"></a> [application\_insights\_id](#output\_application\_insights\_id) | The ID of the Application Insights instance |
| <a name="output_application_insights_instrumentation_key"></a> [application\_insights\_instrumentation\_key](#output\_application\_insights\_instrumentation\_key) | The instrumentation key of the Application Insights instance |
| <a name="output_application_insights_name"></a> [application\_insights\_name](#output\_application\_insights\_name) | The name of the Application Insights instance |
| <a name="output_function_app_ids"></a> [function\_app\_ids](#output\_function\_app\_ids) | The IDs of the created Function Apps |
| <a name="output_function_app_names"></a> [function\_app\_names](#output\_function\_app\_names) | The names of the created Function Apps |
| <a name="output_function_monitoring_alert_ids"></a> [function\_monitoring\_alert\_ids](#output\_function\_monitoring\_alert\_ids) | The IDs of the function monitoring alerts |
| <a name="output_function_monitoring_dashboard_id"></a> [function\_monitoring\_dashboard\_id](#output\_function\_monitoring\_dashboard\_id) | The ID of the function monitoring dashboard |
| <a name="output_function_monitoring_dashboard_url"></a> [function\_monitoring\_dashboard\_url](#output\_function\_monitoring\_dashboard\_url) | The URL of the function monitoring dashboard |
| <a name="output_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#output\_log\_analytics\_workspace\_id) | The ID of the Log Analytics workspace |
| <a name="output_log_analytics_workspace_name"></a> [log\_analytics\_workspace\_name](#output\_log\_analytics\_workspace\_name) | The name of the Log Analytics workspace |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | The ID of the resource group |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | The ID of the storage account |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | The name of the storage account |
<!-- END_TF_DOCS -->
