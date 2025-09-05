# Application Insights Network Module

This Terraform module creates alerting rules and dashboards for Azure Application Insights monitoring. It provides basic alerting capabilities and a sample dashboard for monitoring application performance and health.

## Features

- **Configurable Alert Rules**:
  - Response time alerts
  - Failed request rate alerts
  - Exception rate alerts
  - Availability alerts
  - Server error (5xx) alerts

- **Sample Dashboard**: Basic monitoring dashboard with key performance metrics

- **Flexible Configuration**: All alert thresholds and severities are configurable

- **No Notifications**: Alert rules are created without action groups (can be added separately)

## Usage

### Basic Usage

```hcl
module "app_insights_monitoring" {
  source = "./modules/application-insights-network"

  # Required variables
  resource_group_name       = "rg-myapp-prod-eus-001"
  location                 = "East US"
  application_insights_name = "appi-myapp-prod-eus-001"

  # Optional naming
  workload       = "myapp"
  environment    = "prod"
  location_short = "eus"

  tags = {
    Environment = "Production"
    Project     = "MyApp"
  }
}
```

### Advanced Usage with Custom Thresholds

```hcl
module "app_insights_monitoring" {
  source = "./modules/application-insights-network"

  # Required variables
  resource_group_name       = "rg-myapp-prod-eus-001"
  location                 = "East US"
  application_insights_name = "appi-myapp-prod-eus-001"

  # Custom alert thresholds
  response_time_threshold_ms     = 3000  # 3 seconds
  failed_request_rate_threshold  = 2     # 2%
  exception_rate_threshold       = 5     # 5 exceptions per 5 minutes
  availability_threshold_percent = 99.5  # 99.5%
  server_error_threshold        = 5      # 5 server errors per 5 minutes

  # Custom alert severities (0=Critical, 1=Error, 2=Warning, 3=Informational, 4=Verbose)
  response_time_alert_severity = 1
  availability_alert_severity  = 0

  # Optional features
  enable_dashboard = true
  dashboard_display_name = "MyApp Production Monitoring"

  # Optional Log Analytics integration
  log_analytics_workspace_name = "log-myapp-prod-eus-001"

  tags = {
    Environment = "Production"
    Project     = "MyApp"
  }
}
```

### Selective Alert Configuration

```hcl
module "app_insights_monitoring" {
  source = "./modules/application-insights-network"

  # Required variables
  resource_group_name       = "rg-myapp-dev-eus-001"
  location                 = "East US"
  application_insights_name = "appi-myapp-dev-eus-001"

  # Enable only specific alerts for development environment
  enable_response_time_alert  = true
  enable_failed_request_alert = true
  enable_exception_alert      = true
  enable_availability_alert   = false  # Disable for dev
  enable_server_error_alert   = false  # Disable for dev

  # Disable dashboard for dev environment
  enable_dashboard = false

  workload    = "myapp"
  environment = "dev"

  tags = {
    Environment = "Development"
    Project     = "MyApp"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | >= 3.0 |
| random | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 3.0 |
| random | >= 3.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_metric_alert.response_time](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.failed_request_rate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.exception_rate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.availability](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.server_errors](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_application_insights_workbook.dashboard](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights_workbook) | resource |
| [random_uuid.dashboard](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |
| [azurerm_application_insights.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/application_insights) | data source |
| [azurerm_log_analytics_workspace.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/log_analytics_workspace) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| resource_group_name | Name of the resource group | `string` | n/a | yes |
| location | Azure region for resources | `string` | n/a | yes |
| application_insights_name | Name of the existing Application Insights instance to monitor | `string` | n/a | yes |
| workload | Name of the workload or application (used in naming convention) | `string` | `"app"` | no |
| environment | Environment name (dev, staging, prod) (used in naming convention) | `string` | `"dev"` | no |
| location_short | Short name for the location (used in naming convention) | `string` | `"eus"` | no |
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |
| log_analytics_workspace_name | Name of the Log Analytics Workspace (optional, for advanced queries) | `string` | `null` | no |
| enable_response_time_alert | Enable response time alert | `bool` | `true` | no |
| response_time_threshold_ms | Response time threshold in milliseconds | `number` | `5000` | no |
| response_time_alert_severity | Severity level for response time alert (0-4, where 0 is critical) | `number` | `2` | no |
| enable_failed_request_alert | Enable failed request rate alert | `bool` | `true` | no |
| failed_request_rate_threshold | Failed request rate threshold (percentage) | `number` | `5` | no |
| failed_request_alert_severity | Severity level for failed request alert (0-4, where 0 is critical) | `number` | `1` | no |
| enable_exception_alert | Enable exception rate alert | `bool` | `true` | no |
| exception_rate_threshold | Exception rate threshold (count per 5 minutes) | `number` | `10` | no |
| exception_alert_severity | Severity level for exception alert (0-4, where 0 is critical) | `number` | `1` | no |
| enable_availability_alert | Enable availability alert | `bool` | `true` | no |
| availability_threshold_percent | Availability threshold percentage | `number` | `99` | no |
| availability_alert_severity | Severity level for availability alert (0-4, where 0 is critical) | `number` | `0` | no |
| enable_server_error_alert | Enable server error (5xx) alert | `bool` | `true` | no |
| server_error_threshold | Server error threshold (count per 5 minutes) | `number` | `10` | no |
| server_error_alert_severity | Severity level for server error alert (0-4, where 0 is critical) | `number` | `1` | no |
| enable_dashboard | Enable Application Insights dashboard creation | `bool` | `true` | no |
| dashboard_display_name | Display name for the Application Insights dashboard | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| response_time_alert_id | ID of the response time alert rule |
| failed_request_alert_id | ID of the failed request alert rule |
| exception_alert_id | ID of the exception alert rule |
| availability_alert_id | ID of the availability alert rule |
| server_error_alert_id | ID of the server error alert rule |
| alert_rule_names | Map of alert rule names |
| dashboard_id | ID of the Application Insights dashboard |
| dashboard_name | Name of the Application Insights dashboard |
| dashboard_display_name | Display name of the Application Insights dashboard |
| application_insights_id | ID of the monitored Application Insights instance |
| application_insights_name | Name of the monitored Application Insights instance |
| application_insights_app_id | App ID of the monitored Application Insights instance |
| log_analytics_workspace_id | ID of the Log Analytics Workspace (if provided) |
| log_analytics_workspace_name | Name of the Log Analytics Workspace (if provided) |
| configuration | Summary of Application Insights Network monitoring configuration |
| resource_group_name | Resource group name where monitoring resources are deployed |
| location | Azure region where monitoring resources are deployed |
| tags | Tags applied to the monitoring resources |

## Alert Severity Levels

- **0**: Critical
- **1**: Error
- **2**: Warning
- **3**: Informational
- **4**: Verbose

## Default Alert Thresholds

- **Response Time**: 5000ms (5 seconds)
- **Failed Request Rate**: 5%
- **Exception Rate**: 10 exceptions per 5 minutes
- **Availability**: 99%
- **Server Errors**: 10 errors per 5 minutes

## Dashboard Features

The included dashboard provides:

- Request rate over time
- Average response time trends
- Failed request tracking
- Exception monitoring
- Availability percentage
- 24-hour summary statistics

## Integration with Application Insights Module

This module is designed to work with the `application-insights` module:

```hcl
# Create Application Insights with workspace
module "app_insights" {
  source = "./modules/application-insights"

  resource_group_name = "rg-myapp-prod-eus-001"
  location           = "East US"
  workload           = "myapp"
  environment        = "prod"
  location_short     = "eus"

  # Create workspace and Key Vault secret
  create_workspace = true
  key_vault_id     = "/subscriptions/.../resourceGroups/.../providers/Microsoft.KeyVault/vaults/kv-myapp-prod"

  tags = {
    Environment = "Production"
    Project     = "MyApp"
  }
}

# Add monitoring and alerting
module "app_insights_monitoring" {
  source = "./modules/application-insights-network"

  resource_group_name       = module.app_insights.resource_group_name
  location                 = module.app_insights.location
  application_insights_name = module.app_insights.name

  # Use the same naming convention
  workload       = "myapp"
  environment    = "prod"
  location_short = "eus"

  # Reference the created workspace
  log_analytics_workspace_name = module.app_insights.log_analytics_workspace_name

  tags = {
    Environment = "Production"
    Project     = "MyApp"
  }

  depends_on = [module.app_insights]
}
```

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
| [azurerm_application_insights_workbook.dashboard](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights_workbook) | resource |
| [azurerm_monitor_metric_alert.availability](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.exception_rate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.failed_request_rate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.response_time](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [azurerm_monitor_metric_alert.server_errors](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert) | resource |
| [random_uuid.dashboard](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |
| [azurerm_application_insights.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/application_insights) | data source |
| [azurerm_log_analytics_workspace.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/log_analytics_workspace) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_insights_name"></a> [application\_insights\_name](#input\_application\_insights\_name) | Name of the existing Application Insights instance to monitor | `string` | n/a | yes |
| <a name="input_availability_alert_severity"></a> [availability\_alert\_severity](#input\_availability\_alert\_severity) | Severity level for availability alert (0-4, where 0 is critical) | `number` | `0` | no |
| <a name="input_availability_threshold_percent"></a> [availability\_threshold\_percent](#input\_availability\_threshold\_percent) | Availability threshold percentage | `number` | `99` | no |
| <a name="input_dashboard_display_name"></a> [dashboard\_display\_name](#input\_dashboard\_display\_name) | Display name for the Application Insights dashboard | `string` | `null` | no |
| <a name="input_enable_availability_alert"></a> [enable\_availability\_alert](#input\_enable\_availability\_alert) | Enable availability alert | `bool` | `true` | no |
| <a name="input_enable_dashboard"></a> [enable\_dashboard](#input\_enable\_dashboard) | Enable Application Insights dashboard creation | `bool` | `true` | no |
| <a name="input_enable_exception_alert"></a> [enable\_exception\_alert](#input\_enable\_exception\_alert) | Enable exception rate alert | `bool` | `true` | no |
| <a name="input_enable_failed_request_alert"></a> [enable\_failed\_request\_alert](#input\_enable\_failed\_request\_alert) | Enable failed request rate alert | `bool` | `true` | no |
| <a name="input_enable_response_time_alert"></a> [enable\_response\_time\_alert](#input\_enable\_response\_time\_alert) | Enable response time alert | `bool` | `true` | no |
| <a name="input_enable_server_error_alert"></a> [enable\_server\_error\_alert](#input\_enable\_server\_error\_alert) | Enable server error (5xx) alert | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, staging, prod) (used in naming convention) | `string` | `"dev"` | no |
| <a name="input_exception_alert_severity"></a> [exception\_alert\_severity](#input\_exception\_alert\_severity) | Severity level for exception alert (0-4, where 0 is critical) | `number` | `1` | no |
| <a name="input_exception_rate_threshold"></a> [exception\_rate\_threshold](#input\_exception\_rate\_threshold) | Exception rate threshold (count per 5 minutes) | `number` | `10` | no |
| <a name="input_failed_request_alert_severity"></a> [failed\_request\_alert\_severity](#input\_failed\_request\_alert\_severity) | Severity level for failed request alert (0-4, where 0 is critical) | `number` | `1` | no |
| <a name="input_failed_request_rate_threshold"></a> [failed\_request\_rate\_threshold](#input\_failed\_request\_rate\_threshold) | Failed request rate threshold (percentage) | `number` | `5` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for resources | `string` | n/a | yes |
| <a name="input_location_short"></a> [location\_short](#input\_location\_short) | Short name for the location (used in naming convention) | `string` | `"eus"` | no |
| <a name="input_log_analytics_workspace_name"></a> [log\_analytics\_workspace\_name](#input\_log\_analytics\_workspace\_name) | Name of the Log Analytics Workspace (optional, for advanced queries) | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_response_time_alert_severity"></a> [response\_time\_alert\_severity](#input\_response\_time\_alert\_severity) | Severity level for response time alert (0-4, where 0 is critical) | `number` | `2` | no |
| <a name="input_response_time_threshold_ms"></a> [response\_time\_threshold\_ms](#input\_response\_time\_threshold\_ms) | Response time threshold in milliseconds | `number` | `5000` | no |
| <a name="input_server_error_alert_severity"></a> [server\_error\_alert\_severity](#input\_server\_error\_alert\_severity) | Severity level for server error alert (0-4, where 0 is critical) | `number` | `1` | no |
| <a name="input_server_error_threshold"></a> [server\_error\_threshold](#input\_server\_error\_threshold) | Server error threshold (count per 5 minutes) | `number` | `10` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Name of the workload or application (used in naming convention) | `string` | `"app"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alert_rule_names"></a> [alert\_rule\_names](#output\_alert\_rule\_names) | Map of alert rule names |
| <a name="output_application_insights_app_id"></a> [application\_insights\_app\_id](#output\_application\_insights\_app\_id) | App ID of the monitored Application Insights instance |
| <a name="output_application_insights_id"></a> [application\_insights\_id](#output\_application\_insights\_id) | ID of the monitored Application Insights instance |
| <a name="output_application_insights_name"></a> [application\_insights\_name](#output\_application\_insights\_name) | Name of the monitored Application Insights instance |
| <a name="output_availability_alert_id"></a> [availability\_alert\_id](#output\_availability\_alert\_id) | ID of the availability alert rule |
| <a name="output_configuration"></a> [configuration](#output\_configuration) | Summary of Application Insights Network monitoring configuration |
| <a name="output_dashboard_display_name"></a> [dashboard\_display\_name](#output\_dashboard\_display\_name) | Display name of the Application Insights dashboard |
| <a name="output_dashboard_id"></a> [dashboard\_id](#output\_dashboard\_id) | ID of the Application Insights dashboard |
| <a name="output_dashboard_name"></a> [dashboard\_name](#output\_dashboard\_name) | Name of the Application Insights dashboard |
| <a name="output_exception_alert_id"></a> [exception\_alert\_id](#output\_exception\_alert\_id) | ID of the exception alert rule |
| <a name="output_failed_request_alert_id"></a> [failed\_request\_alert\_id](#output\_failed\_request\_alert\_id) | ID of the failed request alert rule |
| <a name="output_location"></a> [location](#output\_location) | Azure region where monitoring resources are deployed |
| <a name="output_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#output\_log\_analytics\_workspace\_id) | ID of the Log Analytics Workspace (if provided) |
| <a name="output_log_analytics_workspace_name"></a> [log\_analytics\_workspace\_name](#output\_log\_analytics\_workspace\_name) | Name of the Log Analytics Workspace (if provided) |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Resource group name where monitoring resources are deployed |
| <a name="output_response_time_alert_id"></a> [response\_time\_alert\_id](#output\_response\_time\_alert\_id) | ID of the response time alert rule |
| <a name="output_server_error_alert_id"></a> [server\_error\_alert\_id](#output\_server\_error\_alert\_id) | ID of the server error alert rule |
| <a name="output_tags"></a> [tags](#output\_tags) | Tags applied to the monitoring resources |
<!-- END_TF_DOCS -->
