# Application Insights Module

This module creates and manages Azure Application Insights resources with comprehensive configuration options for monitoring applications.

## Features

- **Flexible Configuration**: Supports both workspace-based and classic Application Insights
- **Smart Detection**: Built-in anomaly detection with customizable email notifications
- **Web Tests**: Availability monitoring with multi-region testing
- **Workbooks**: Optional dashboard creation for data visualization
- **API Keys**: Programmatic access configuration
- **Multiple Application Types**: Support for web, mobile, and other application types

## Usage

### Basic Example (Classic Mode)

```hcl
module "application_insights" {
  source = "path/to/modules/application-insights"

  resource_group_name = "my-resource-group"
  location            = "East US"
  name                = "my-app-insights"
  
  application_type    = "web"
  sampling_percentage = 100
  
  enable_smart_detection = true
  smart_detection_emails = ["admin@example.com"]
  
  tags = {
    Environment = "Production"
    Application = "MyApp"
  }
}
```

### Workspace-based Example

```hcl
module "application_insights" {
  source = "path/to/modules/application-insights"

  resource_group_name = "my-resource-group"
  location            = "East US"
  name                = "my-app-insights"
  
  # Link to Log Analytics Workspace
  workspace_id = azurerm_log_analytics_workspace.main.id
  
  application_type    = "web"
  sampling_percentage = 100
  
  enable_smart_detection = true
  smart_detection_emails = ["admin@example.com"]
  enable_workbook        = true
  
  tags = {
    Environment = "Production"
    Application = "MyApp"
  }
}
```

### Multiple Instances Example

```hcl
# Frontend Application Insights
module "frontend_insights" {
  source = "path/to/modules/application-insights"

  resource_group_name = "my-resource-group"
  location            = "East US"
  name                = "appi-frontend"
  
  application_type = "web"
  
  web_tests = {
    homepage = {
      url           = "https://myapp.com"
      geo_locations = ["us-east-1", "us-west-1"]
    }
  }
}

# API Application Insights
module "api_insights" {
  source = "path/to/modules/application-insights"

  resource_group_name = "my-resource-group"
  location            = "East US"
  name                = "appi-api"
  
  application_type = "other"
  
  web_tests = {
    health_check = {
      url           = "https://api.myapp.com/health"
      geo_locations = ["us-east-1"]
    }
  }
}
```

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
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.42.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_application_insights.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights) | resource |
| [azurerm_application_insights_api_key.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights_api_key) | resource |
| [azurerm_application_insights_smart_detection_rule.exception_volume](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights_smart_detection_rule) | resource |
| [azurerm_application_insights_smart_detection_rule.failure_anomalies](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights_smart_detection_rule) | resource |
| [azurerm_application_insights_smart_detection_rule.memory_leak](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights_smart_detection_rule) | resource |
| [azurerm_application_insights_smart_detection_rule.performance_anomalies](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights_smart_detection_rule) | resource |
| [azurerm_application_insights_smart_detection_rule.security_detection](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights_smart_detection_rule) | resource |
| [azurerm_application_insights_smart_detection_rule.trace_severity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights_smart_detection_rule) | resource |
| [azurerm_application_insights_standard_web_test.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights_standard_web_test) | resource |
| [azurerm_application_insights_workbook.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights_workbook) | resource |
| [random_uuid.workbook](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_key_read_permissions"></a> [api\_key\_read\_permissions](#input\_api\_key\_read\_permissions) | List of read permissions for the API key | `list(string)` | <pre>[<br/>  "aggregate",<br/>  "api",<br/>  "draft",<br/>  "extendqueries",<br/>  "search"<br/>]</pre> | no |
| <a name="input_api_key_write_permissions"></a> [api\_key\_write\_permissions](#input\_api\_key\_write\_permissions) | List of write permissions for the API key | `list(string)` | `[]` | no |
| <a name="input_application_type"></a> [application\_type](#input\_application\_type) | Type of application being monitored | `string` | `"web"` | no |
| <a name="input_create_api_key"></a> [create\_api\_key](#input\_create\_api\_key) | Create an API key for programmatic access to Application Insights | `bool` | `false` | no |
| <a name="input_daily_data_cap_gb"></a> [daily\_data\_cap\_gb](#input\_daily\_data\_cap\_gb) | Daily data cap in GB for Application Insights (-1 for unlimited) | `number` | `null` | no |
| <a name="input_daily_data_cap_notifications_disabled"></a> [daily\_data\_cap\_notifications\_disabled](#input\_daily\_data\_cap\_notifications\_disabled) | Disable daily data cap notifications | `bool` | `false` | no |
| <a name="input_disable_ip_masking"></a> [disable\_ip\_masking](#input\_disable\_ip\_masking) | Disable IP masking for Application Insights (useful for development environments) | `bool` | `false` | no |
| <a name="input_enable_smart_detection"></a> [enable\_smart\_detection](#input\_enable\_smart\_detection) | Enable smart detection rules for Application Insights | `bool` | `true` | no |
| <a name="input_enable_workbook"></a> [enable\_workbook](#input\_enable\_workbook) | Enable Application Insights workbook creation | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, staging, prod) (used in naming convention when name is not provided) | `string` | `"dev"` | no |
| <a name="input_force_customer_storage_for_profiler"></a> [force\_customer\_storage\_for\_profiler](#input\_force\_customer\_storage\_for\_profiler) | Force customer storage for profiler (only for classic mode) | `bool` | `false` | no |
| <a name="input_internet_ingestion_enabled"></a> [internet\_ingestion\_enabled](#input\_internet\_ingestion\_enabled) | Enable internet ingestion for Application Insights | `bool` | `true` | no |
| <a name="input_internet_query_enabled"></a> [internet\_query\_enabled](#input\_internet\_query\_enabled) | Enable internet query for Application Insights | `bool` | `true` | no |
| <a name="input_local_authentication_disabled"></a> [local\_authentication\_disabled](#input\_local\_authentication\_disabled) | Disable local authentication for Application Insights | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for resources | `string` | n/a | yes |
| <a name="input_location_short"></a> [location\_short](#input\_location\_short) | Short name for the location (used in naming convention when name is not provided) | `string` | `"eus"` | no |
| <a name="input_name"></a> [name](#input\_name) | Custom name for the Application Insights instance. If not provided, will use standard naming convention. | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | Number of days to retain data in Application Insights (only for classic mode, ignored for workspace-based) | `number` | `90` | no |
| <a name="input_sampling_percentage"></a> [sampling\_percentage](#input\_sampling\_percentage) | Sampling percentage for Application Insights telemetry | `number` | `100` | no |
| <a name="input_smart_detection_emails"></a> [smart\_detection\_emails](#input\_smart\_detection\_emails) | List of email addresses to receive smart detection notifications | `list(string)` | `[]` | no |
| <a name="input_smart_detection_exception_volume_enabled"></a> [smart\_detection\_exception\_volume\_enabled](#input\_smart\_detection\_exception\_volume\_enabled) | Enable exception volume smart detection rule | `bool` | `true` | no |
| <a name="input_smart_detection_failure_anomalies_enabled"></a> [smart\_detection\_failure\_anomalies\_enabled](#input\_smart\_detection\_failure\_anomalies\_enabled) | Enable failure anomalies smart detection rule | `bool` | `true` | no |
| <a name="input_smart_detection_memory_leak_enabled"></a> [smart\_detection\_memory\_leak\_enabled](#input\_smart\_detection\_memory\_leak\_enabled) | Enable memory leak smart detection rule | `bool` | `true` | no |
| <a name="input_smart_detection_performance_anomalies_enabled"></a> [smart\_detection\_performance\_anomalies\_enabled](#input\_smart\_detection\_performance\_anomalies\_enabled) | Enable performance anomalies smart detection rule | `bool` | `true` | no |
| <a name="input_smart_detection_security_detection_enabled"></a> [smart\_detection\_security\_detection\_enabled](#input\_smart\_detection\_security\_detection\_enabled) | Enable security detection smart detection rule | `bool` | `true` | no |
| <a name="input_smart_detection_trace_severity_enabled"></a> [smart\_detection\_trace\_severity\_enabled](#input\_smart\_detection\_trace\_severity\_enabled) | Enable trace severity smart detection rule | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_web_tests"></a> [web\_tests](#input\_web\_tests) | Map of web tests to create for availability monitoring | <pre>map(object({<br/>    url                              = string<br/>    geo_locations                    = list(string)<br/>    frequency                        = optional(number, 300)<br/>    timeout                          = optional(number, 30)<br/>    enabled                          = optional(bool, true)<br/>    retry_enabled                    = optional(bool, true)<br/>    http_verb                        = optional(string, "GET")<br/>    parse_dependent_requests_enabled = optional(bool, false)<br/>    follow_redirects_enabled         = optional(bool, true)<br/>    headers                          = optional(map(string), {})<br/>    body                             = optional(string, null)<br/>    validation_rules = optional(object({<br/>      expected_status_code        = optional(number, 200)<br/>      ssl_check_enabled           = optional(bool, false)<br/>      ssl_cert_remaining_lifetime = optional(number, null)<br/>      content_validation = optional(object({<br/>        content_match      = string<br/>        ignore_case        = optional(bool, false)<br/>        pass_if_text_found = optional(bool, true)<br/>      }), null)<br/>    }), null)<br/>  }))</pre> | `{}` | no |
| <a name="input_workbook_data_json"></a> [workbook\_data\_json](#input\_workbook\_data\_json) | Custom JSON data for the workbook. If not provided, a default dashboard will be created. | `string` | `null` | no |
| <a name="input_workbook_display_name"></a> [workbook\_display\_name](#input\_workbook\_display\_name) | Display name for the Application Insights workbook | `string` | `null` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Name of the workload or application (used in naming convention when name is not provided) | `string` | `"app"` | no |
| <a name="input_workspace_id"></a> [workspace\_id](#input\_workspace\_id) | ID of the Log Analytics Workspace to associate with Application Insights (for workspace-based mode). If null, creates classic Application Insights. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_key"></a> [api\_key](#output\_api\_key) | Application Insights API key |
| <a name="output_api_key_id"></a> [api\_key\_id](#output\_api\_key\_id) | ID of the Application Insights API key |
| <a name="output_app_id"></a> [app\_id](#output\_app\_id) | App ID for Application Insights |
| <a name="output_application_type"></a> [application\_type](#output\_application\_type) | Application type of the Application Insights instance |
| <a name="output_configuration"></a> [configuration](#output\_configuration) | Summary of Application Insights configuration |
| <a name="output_connection_string"></a> [connection\_string](#output\_connection\_string) | Connection string for Application Insights |
| <a name="output_id"></a> [id](#output\_id) | ID of the Application Insights instance |
| <a name="output_instrumentation_key"></a> [instrumentation\_key](#output\_instrumentation\_key) | Instrumentation key for Application Insights |
| <a name="output_location"></a> [location](#output\_location) | Azure region where Application Insights is deployed |
| <a name="output_name"></a> [name](#output\_name) | Name of the Application Insights instance |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Resource group name where Application Insights is deployed |
| <a name="output_smart_detection_rule_ids"></a> [smart\_detection\_rule\_ids](#output\_smart\_detection\_rule\_ids) | Map of smart detection rule IDs |
| <a name="output_tags"></a> [tags](#output\_tags) | Tags applied to the Application Insights instance |
| <a name="output_web_test_ids"></a> [web\_test\_ids](#output\_web\_test\_ids) | Map of web test IDs |
| <a name="output_web_test_synthetic_monitor_ids"></a> [web\_test\_synthetic\_monitor\_ids](#output\_web\_test\_synthetic\_monitor\_ids) | Map of web test synthetic monitor IDs |
| <a name="output_workbook_id"></a> [workbook\_id](#output\_workbook\_id) | ID of the Application Insights workbook |
| <a name="output_workbook_name"></a> [workbook\_name](#output\_workbook\_name) | Name of the Application Insights workbook |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | Workspace ID associated with Application Insights (if workspace-based) |
<!-- END_TF_DOCS -->


## Smart Detection Rules

The module automatically configures the following smart detection rules when enabled:

- **Failure Anomalies**: Detects unusual rises in exception volume
- **Performance Anomalies**: Identifies slow server response times
- **Trace Severity**: Monitors degradation in trace severity ratio
- **Exception Volume**: Tracks abnormal exception patterns
- **Memory Leak**: Detects potential memory leaks
- **Security Detection**: Identifies security-related anomalies

## Web Tests

Configure availability tests to monitor your application endpoints:

```hcl
web_tests = {
  homepage = {
    url           = "https://example.com"
    geo_locations = ["us-east-1", "us-west-1", "eu-west-1"]
    frequency     = 300  # 5 minutes
    timeout       = 30   # 30 seconds
    enabled       = true
    
    validation_rules = {
      expected_status_code = 200
      content_validation = {
        content_match      = "Welcome"
        pass_if_text_found = true
      }
    }
  }
}
```

## Examples

See the `examples/` directory for complete usage examples:

- `basic/` - Simple standalone Application Insights
- `workspace-based/` - Integration with Log Analytics Workspace
- `multiple-instances/` - Multiple Application Insights for different services

## License

This module is licensed under the MIT License.
