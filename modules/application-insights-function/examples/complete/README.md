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
