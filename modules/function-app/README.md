# Azure Function App Module

This Terraform module creates an Azure Function App with comprehensive features including VNet integration, Application Insights, deployment slots, and advanced security configurations. This module is designed to be decoupled from App Service Plans, allowing for flexible and cost-effective Function App deployments.

## Features

- **Cross-Platform Support**: Supports both Linux and Windows Function Apps
- **Multiple Runtime Support**: Python, Node.js, .NET, Java, PowerShell, and custom runtimes
- **Deployment Slots**: Support for staging and production deployment slots
- **VNet Integration**: Optional VNet integration for secure network connectivity
- **Application Insights**: Built-in monitoring and telemetry with Application Insights
- **Security Features**: HTTPS enforcement, TLS configuration, IP restrictions, and managed identity
- **Storage Account**: Dedicated storage account with security best practices
- **Backup Support**: Optional backup configuration for Function Apps
- **Authentication**: Support for multiple authentication providers
- **Diagnostic Settings**: Comprehensive logging and monitoring capabilities
- **Flexible Configuration**: Extensive customization options for all aspects of the Function App

## Quick Start

### Basic Linux Function App

```hcl
module "function_app" {
  source = "app.terraform.io/azure-policy-cloud/function-app/azurerm"
  version = "1.0.0"

  # Required variables
  workload            = "myapp"
  environment         = "dev"
  resource_group_name = "rg-myapp-dev-001"
  location            = "East US"
  service_plan_id     = module.app_service_plan.app_service_plan_id

  # Runtime configuration
  runtime_name    = "python"
  runtime_version = "3.11"

  tags = {
    Environment = "dev"
    Project     = "myapp"
  }
}
```

### Complete Configuration with All Features

```hcl
module "function_app" {
  source = "app.terraform.io/azure-policy-cloud/function-app/azurerm"
  version = "1.0.0"

  # Required variables
  workload            = "myapp"
  environment         = "prod"
  resource_group_name = "rg-myapp-prod-001"
  location            = "East US"
  service_plan_id     = module.app_service_plan.app_service_plan_id

  # Runtime configuration
  os_type         = "Linux"
  runtime_name    = "python"
  runtime_version = "3.11"

  # Security configuration
  https_only                     = true
  public_network_access_enabled = false
  client_certificate_enabled    = true
  minimum_tls_version           = "1.2"

  # Performance configuration
  always_on                   = true
  pre_warmed_instance_count   = 2
  elastic_instance_minimum    = 1
  function_app_scale_limit    = 100

  # VNet integration
  enable_vnet_integration    = true
  vnet_integration_subnet_id = data.azurerm_subnet.functions.id

  # Application Insights
  enable_application_insights = true
  log_analytics_workspace_id  = data.azurerm_log_analytics_workspace.main.id

  # Deployment slots
  deployment_slots = {
    staging = {
      public_network_access_enabled = false
      app_settings = {
        "ENVIRONMENT" = "staging"
      }
    }
  }

  # App settings
  app_settings = {
    "CUSTOM_SETTING"     = "production_value"
    "DATABASE_URL"       = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.db_url.id})"
    "ENABLE_MONITORING"  = "true"
  }

  # IP restrictions
  ip_restrictions = [
    {
      name       = "AllowOfficeIP"
      ip_address = "203.0.113.0/24"
      priority   = 100
      action     = "Allow"
    }
  ]

  # Diagnostic settings
  enable_diagnostic_settings = true

  # Identity
  identity_type = "SystemAssigned"

  tags = {
    Environment = "prod"
    Project     = "myapp"
    CostCenter  = "engineering"
  }
}
```

## Usage Examples

### Python Function App with VNet Integration

```hcl
# App Service Plan (using separate module)
module "app_service_plan" {
  source = "app.terraform.io/azure-policy-cloud/app-service-plan-function/azurerm"
  version = "1.1.34"

  workload            = "myapp"
  environment         = "dev"
  resource_group_name = "rg-myapp-dev-001"
  location            = "East US"
  sku_name            = "EP1"

  tags = local.common_tags
}

# Function App
module "function_app" {
  source = "app.terraform.io/azure-policy-cloud/function-app/azurerm"
  version = "1.0.0"

  workload            = "myapp"
  environment         = "dev"
  resource_group_name = "rg-myapp-dev-001"
  location            = "East US"
  service_plan_id     = module.app_service_plan.app_service_plan_id

  # Python runtime
  runtime_name    = "python"
  runtime_version = "3.11"

  # VNet integration
  enable_vnet_integration    = true
  vnet_integration_subnet_id = azurerm_subnet.functions.id

  # Application Insights
  enable_application_insights = true
  log_analytics_workspace_id  = azurerm_log_analytics_workspace.main.id

  # Custom app settings
  app_settings = {
    "PYTHON_ENABLE_WORKER_EXTENSIONS" = "1"
    "FUNCTIONS_WORKER_PROCESS_COUNT"  = "4"
  }

  tags = local.common_tags
}
```

### .NET Function App with Authentication

```hcl
module "function_app" {
  source = "app.terraform.io/azure-policy-cloud/function-app/azurerm"
  version = "1.0.0"

  workload            = "myapp"
  environment         = "prod"
  resource_group_name = "rg-myapp-prod-001"
  location            = "East US"
  service_plan_id     = module.app_service_plan.app_service_plan_id

  # .NET runtime
  os_type                     = "Windows"
  runtime_name                = "dotnet"
  runtime_version             = "6.0"
  use_dotnet_isolated_runtime = true

  # Authentication
  enable_auth_settings = true
  auth_settings_active_directory = {
    client_id     = var.aad_client_id
    client_secret = var.aad_client_secret
    allowed_audiences = [
      "api://myapp-functions"
    ]
  }

  # Security
  client_certificate_enabled = true
  client_certificate_mode     = "Required"

  tags = local.common_tags
}
```

### Node.js Function App with Deployment Slots

```hcl
module "function_app" {
  source = "app.terraform.io/azure-policy-cloud/function-app/azurerm"
  version = "1.0.0"

  workload            = "myapp"
  environment         = "prod"
  resource_group_name = "rg-myapp-prod-001"
  location            = "East US"
  service_plan_id     = module.app_service_plan.app_service_plan_id

  # Node.js runtime
  runtime_name    = "node"
  runtime_version = "18"

  # Deployment slots
  deployment_slots = {
    staging = {
      public_network_access_enabled = true
      app_settings = {
        "NODE_ENV"     = "staging"
        "API_BASE_URL" = "https://api-staging.example.com"
      }
    }
    testing = {
      public_network_access_enabled = true
      app_settings = {
        "NODE_ENV"     = "testing"
        "API_BASE_URL" = "https://api-testing.example.com"
      }
    }
  }

  # Sticky settings (won't swap between slots)
  sticky_app_setting_names = [
    "NODE_ENV",
    "API_BASE_URL"
  ]

  # Production app settings
  app_settings = {
    "NODE_ENV"                    = "production"
    "API_BASE_URL"               = "https://api.example.com"
    "WEBSITE_NODE_DEFAULT_VERSION" = "18"
  }

  tags = local.common_tags
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6 |
| azurerm | >= 4.40 |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 4.40 |

## Resources

| Name | Type |
|------|------|
| [azurerm_storage_account.functions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_application_insights.functions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights) | resource |
| [azurerm_linux_function_app.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app) | resource |
| [azurerm_windows_function_app.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_function_app) | resource |
| [azurerm_app_service_virtual_network_swift_connection.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_virtual_network_swift_connection) | resource |
| [azurerm_linux_function_app_slot.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app_slot) | resource |
| [azurerm_windows_function_app_slot.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_function_app_slot) | resource |
| [azurerm_monitor_diagnostic_setting.function_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| workload | The workload name | `string` | n/a | yes |
| environment | The environment name | `string` | n/a | yes |
| resource_group_name | The name of the resource group | `string` | n/a | yes |
| location | The Azure region | `string` | n/a | yes |
| service_plan_id | The ID of the App Service Plan to use for the Function App | `string` | n/a | yes |
| os_type | The operating system type for the Function App (Linux or Windows) | `string` | `"Linux"` | no |
| runtime_name | The runtime name for the Function App | `string` | `"python"` | no |
| runtime_version | The runtime version for the Function App | `string` | `"3.11"` | no |
| functions_extension_version | The version of the Azure Functions runtime | `string` | `"~4"` | no |
| use_dotnet_isolated_runtime | Whether to use .NET isolated runtime | `bool` | `false` | no |
| https_only | Whether the Function App should only accept HTTPS requests | `bool` | `true` | no |
| public_network_access_enabled | Whether public network access is enabled for the Function App | `bool` | `true` | no |
| client_certificate_enabled | Whether client certificates are enabled | `bool` | `false` | no |
| client_certificate_mode | The client certificate mode | `string` | `"Optional"` | no |
| key_vault_reference_identity_id | The identity ID to use for Key Vault references | `string` | `null` | no |
| minimum_tls_version | The minimum TLS version for the Function App | `string` | `"1.2"` | no |
| scm_minimum_tls_version | The minimum TLS version for SCM | `string` | `"1.2"` | no |
| scm_use_main_ip_restriction | Whether SCM should use the main IP restrictions | `bool` | `false` | no |
| ftps_state | The FTPS state | `string` | `"Disabled"` | no |
| always_on | Whether the Function App should always be on (not applicable for Consumption plan) | `bool` | `true` | no |
| pre_warmed_instance_count | The number of pre-warmed instances for Premium plans | `number` | `1` | no |
| elastic_instance_minimum | The minimum number of elastic instances for Premium plans | `number` | `1` | no |
| function_app_scale_limit | The maximum number of instances for the Function App | `number` | `200` | no |
| worker_count | The number of workers for the Function App | `number` | `1` | no |
| use_32_bit_worker | Whether to use 32-bit worker process | `bool` | `false` | no |
| health_check_path | The health check path for the Function App | `string` | `null` | no |
| health_check_eviction_time_in_min | The time in minutes after which an instance is evicted if health check fails | `number` | `10` | no |
| enable_vnet_integration | Whether to enable VNet integration for the Function App | `bool` | `false` | no |
| vnet_integration_subnet_id | The subnet ID for VNet integration | `string` | `null` | no |
| websockets_enabled | Whether WebSockets are enabled | `bool` | `false` | no |
| remote_debugging_enabled | Whether remote debugging is enabled | `bool` | `false` | no |
| remote_debugging_version | The remote debugging version | `string` | `"VS2019"` | no |
| enable_cors | Whether to enable CORS | `bool` | `false` | no |
| cors_allowed_origins | The allowed origins for CORS | `list(string)` | `[]` | no |
| cors_support_credentials | Whether CORS should support credentials | `bool` | `false` | no |
| ip_restrictions | List of IP restrictions for the Function App | `list(object)` | `[]` | no |
| scm_ip_restrictions | List of SCM IP restrictions for the Function App | `list(object)` | `[]` | no |
| app_settings | Additional app settings for the Function App | `map(string)` | `{}` | no |
| run_from_package | Whether to run the Function App from a package | `bool` | `true` | no |
| connection_strings | Connection strings for the Function App | `list(object)` | `[]` | no |
| identity_type | The type of managed identity for the Function App | `string` | `"SystemAssigned"` | no |
| identity_ids | List of user assigned identity IDs | `list(string)` | `[]` | no |
| storage_account_tier | The tier of the storage account | `string` | `"Standard"` | no |
| storage_account_replication_type | The replication type of the storage account | `string` | `"LRS"` | no |
| storage_min_tls_version | The minimum TLS version for the storage account | `string` | `"TLS1_2"` | no |
| storage_public_network_access_enabled | Whether public network access is enabled for the storage account | `bool` | `true` | no |
| storage_blob_delete_retention_days | The number of days to retain deleted blobs | `number` | `7` | no |
| storage_container_delete_retention_days | The number of days to retain deleted containers | `number` | `7` | no |
| storage_sas_expiration_period | The SAS expiration period for the storage account | `string` | `"01.00:00:00"` | no |
| storage_sas_expiration_action | The action to take when SAS expires | `string` | `"Log"` | no |
| enable_storage_network_rules | Whether to enable network rules for the storage account | `bool` | `false` | no |
| storage_network_rules_default_action | The default action for storage network rules | `string` | `"Allow"` | no |
| storage_network_rules_bypass | The bypass rules for storage network rules | `list(string)` | `["AzureServices"]` | no |
| storage_network_rules_ip_rules | The IP rules for storage network rules | `list(string)` | `[]` | no |
| storage_network_rules_subnet_ids | The subnet IDs for storage network rules | `list(string)` | `[]` | no |
| enable_application_insights | Whether to enable Application Insights | `bool` | `true` | no |
| application_insights_type | The type of Application Insights | `string` | `"web"` | no |
| application_insights_retention_days | The retention period in days for Application Insights | `number` | `90` | no |
| application_insights_sampling_percentage | The sampling percentage for Application Insights | `number` | `100` | no |
| application_insights_disable_ip_masking | Whether to disable IP masking in Application Insights | `bool` | `false` | no |
| application_insights_local_auth_disabled | Whether local authentication is disabled for Application Insights | `bool` | `true` | no |
| application_insights_internet_ingestion_enabled | Whether internet ingestion is enabled for Application Insights | `bool` | `true` | no |
| application_insights_internet_query_enabled | Whether internet query is enabled for Application Insights | `bool` | `true` | no |
| log_analytics_workspace_id | The Log Analytics workspace ID for Application Insights | `string` | `null` | no |
| deployment_slots | Map of deployment slots to create | `map(object)` | `{}` | no |
| sticky_app_setting_names | List of app setting names that should be sticky to deployment slots | `list(string)` | `[]` | no |
| sticky_connection_string_names | List of connection string names that should be sticky to deployment slots | `list(string)` | `[]` | no |
| enable_auth_settings | Whether to enable authentication settings | `bool` | `false` | no |
| auth_settings_default_provider | The default authentication provider | `string` | `"AzureActiveDirectory"` | no |
| auth_settings_unauthenticated_client_action | The action to take for unauthenticated clients | `string` | `"RedirectToLoginPage"` | no |
| auth_settings_token_store_enabled | Whether token store is enabled | `bool` | `false` | no |
| auth_settings_token_refresh_extension_hours | The token refresh extension hours | `number` | `72` | no |
| auth_settings_issuer | The issuer URL for authentication | `string` | `null` | no |
| auth_settings_runtime_version | The runtime version for authentication | `string` | `"~1"` | no |
| auth_settings_additional_login_parameters | Additional login parameters | `map(string)` | `{}` | no |
| auth_settings_allowed_external_redirect_urls | List of allowed external redirect URLs | `list(string)` | `[]` | no |
| auth_settings_active_directory | Active Directory authentication settings | `object` | `null` | no |
| auth_settings_facebook | Facebook authentication settings | `object` | `null` | no |
| auth_settings_google | Google authentication settings | `object` | `null` | no |
| auth_settings_microsoft | Microsoft authentication settings | `object` | `null` | no |
| auth_settings_twitter | Twitter authentication settings | `object` | `null` | no |
| enable_backup | Whether to enable backup for the Function App | `bool` | `false` | no |
| backup_name | The name of the backup | `string` | `"DefaultBackup"` | no |
| backup_storage_account_url | The storage account URL for backups | `string` | `null` | no |
| backup_schedule_frequency_interval | The frequency interval for backup schedule | `number` | `1` | no |
| backup_schedule_frequency_unit | The frequency unit for backup schedule | `string` | `"Day"` | no |
| backup_schedule_keep_at_least_one_backup | Whether to keep at least one backup | `bool` | `true` | no |
| backup_schedule_retention_period_days | The retention period in days for backups | `number` | `30` | no |
| backup_schedule_start_time | The start time for backup schedule (ISO 8601 format) | `string` | `null` | no |
| enable_diagnostic_settings | Whether to enable diagnostic settings | `bool` | `false` | no |
| diagnostic_storage_account_id | The storage account ID for diagnostic settings | `string` | `null` | no |
| eventhub_authorization_rule_id | The Event Hub authorization rule ID for diagnostic settings | `string` | `null` | no |
| eventhub_name | The Event Hub name for diagnostic settings | `string` | `null` | no |
| diagnostic_metrics | List of metrics to enable for diagnostic settings | `list(string)` | `["AllMetrics"]` | no |
| tags | A map of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| function_app_id | The ID of the Function App |
| function_app_name | The name of the Function App |
| function_app_default_hostname | The default hostname of the Function App |
| function_app_kind | The kind of the Function App |
| function_app_outbound_ip_addresses | The outbound IP addresses of the Function App |
| function_app_possible_outbound_ip_addresses | The possible outbound IP addresses of the Function App |
| function_app_site_credential | The site credentials for the Function App |
| function_app_custom_domain_verification_id | The custom domain verification ID for the Function App |
| function_app_hosting_environment_id | The hosting environment ID of the Function App |
| function_app_identity | The managed identity of the Function App |
| function_app_principal_id | The principal ID of the Function App's managed identity |
| function_app_tenant_id | The tenant ID of the Function App's managed identity |
| storage_account_id | The ID of the storage account |
| storage_account_name | The name of the storage account |
| storage_account_primary_access_key | The primary access key for the storage account |
| storage_account_secondary_access_key | The secondary access key for the storage account |
| storage_account_primary_connection_string | The primary connection string for the storage account |
| storage_account_secondary_connection_string | The secondary connection string for the storage account |
| storage_account_primary_blob_endpoint | The primary blob endpoint for the storage account |
| storage_account_primary_queue_endpoint | The primary queue endpoint for the storage account |
| storage_account_primary_table_endpoint | The primary table endpoint for the storage account |
| storage_account_primary_file_endpoint | The primary file endpoint for the storage account |
| application_insights_id | The ID of Application Insights |
| application_insights_name | The name of Application Insights |
| application_insights_instrumentation_key | The instrumentation key of Application Insights |
| application_insights_connection_string | The connection string of Application Insights |
| application_insights_app_id | The app ID of Application Insights |
| vnet_integration_enabled | Whether VNet integration is enabled |
| vnet_integration_subnet_id | The subnet ID used for VNet integration |
| vnet_integration_id | The ID of the VNet integration |
| deployment_slots | Information about deployment slots |
| deployment_slot_names | List of deployment slot names |
| deployment_slot_count | Number of deployment slots created |
| runtime_configuration | Runtime configuration of the Function App |
| security_configuration | Security configuration of the Function App |
| performance_configuration | Performance configuration of the Function App |
| network_configuration | Network configuration of the Function App |
| service_plan_id | The ID of the App Service Plan used by the Function App |
| resource_group_name | The name of the resource group |
| location | The Azure region where resources are deployed |
| workload | The workload name |
| environment | The environment name |
| diagnostic_settings_enabled | Whether diagnostic settings are enabled |
| diagnostic_settings_function_app_id | The ID of the Function App diagnostic settings |
| diagnostic_settings_storage_account_id | The ID of the storage account diagnostic settings |
| tags | The tags applied to the resources |
| function_app_summary | Summary of the Function App deployment |

## Supported Runtimes

### Linux Function Apps
- **Python**: 3.8, 3.9, 3.10, 3.11, 3.12, 3.13
- **Node.js**: 14, 16, 18, 20
- **.NET**: 6.0, 7.0, 8.0 (isolated and in-process)
- **Java**: 8, 11, 17, 21
- **PowerShell**: 7.0, 7.2, 7.4
- **Custom**: Custom runtime support

### Windows Function Apps
- **Python**: 3.8, 3.9, 3.10, 3.11
- **Node.js**: 14, 16, 18, 20
- **.NET**: 6.0, 7.0, 8.0, .NET Framework 4.8
- **Java**: 8, 11, 17
- **PowerShell**: 7.0, 7.2, 7.4

## Security Best Practices

This module implements several security best practices by default:

### Network Security
- HTTPS-only traffic enforcement
- Configurable TLS minimum version (default: 1.2)
- IP restrictions support for both main site and SCM
- VNet integration for private network connectivity
- Storage account network rules

### Identity and Access Management
- Managed identity support (System-assigned and User-assigned)
- Key Vault integration for secure app settings
- Client certificate authentication support
- Multiple authentication provider support

### Storage Security
- Storage account with minimum TLS 1.2
- Shared access key management
- SAS token expiration policies
- Blob and container delete retention policies
- Network access restrictions

### Monitoring and Compliance
- Application Insights integration
- Diagnostic settings for comprehensive logging
- Security-focused default configurations
- Compliance with Azure security baselines

## Deployment Slots

Deployment slots allow you to deploy different versions of your Function App to separate environments within the same Function App resource. This is useful for:

- **Blue-Green Deployments**: Deploy to a staging slot and swap with production
- **A/B Testing**: Test different versions with different user groups
- **Safe Deployments**: Validate changes before promoting to production

### Slot Configuration

```hcl
deployment_slots = {
  staging = {
    public_network_access_enabled = false
    app_settings = {
      "ENVIRONMENT" = "staging"
      "DEBUG_MODE" = "true"
    }
  }
  testing = {
    public_network_access_enabled = true
    app_settings = {
      "ENVIRONMENT" = "testing"
      "FEATURE_FLAGS" = "experimental"
    }
  }
}

# Settings that won't swap between slots
sticky_app_setting_names = [
  "ENVIRONMENT",
  "DATABASE_CONNECTION_STRING"
]
```

## VNet Integration

VNet integration allows your Function App to access resources in your virtual network securely:

```hcl
# Enable VNet integration
enable_vnet_integration    = true
vnet_integration_subnet_id = azurerm_subnet.functions.id

# Configure storage account for VNet
enable_storage_network_rules = true
storage_network_rules_default_action = "Deny"
storage_network_rules_subnet_ids = [
  azurerm_subnet.functions.id
]
```

## Application Insights Integration

Application Insights provides comprehensive monitoring and telemetry:

```hcl
# Enable Application Insights
enable_application_insights = true
log_analytics_workspace_id  = azurerm_log_analytics_workspace.main.id

# Configure retention and sampling
application_insights_retention_days     = 90
application_insights_sampling_percentage = 100

# Security settings
application_insights_local_auth_disabled = true
application_insights_disable_ip_masking  = false
```

## Examples

- [Basic](examples/basic/) - Minimal configuration for a Linux Function App
- [Complete](examples/complete/) - Full-featured Function App with all options

## Migration from Existing Infrastructure

If you're migrating from an existing Function App setup:

1. **Identify Dependencies**: Note your current App Service Plan, storage account, and Application Insights
2. **Extract Configuration**: Document current app settings, connection strings, and security configurations
3. **Plan Migration**: Decide whether to migrate in-place or create new resources
4. **Update References**: Update any downstream dependencies to use the new module outputs

## Troubleshooting

### Common Issues

1. **Storage Account Access**: Ensure the Function App has access to the storage account
2. **VNet Integration**: Verify subnet delegation and network security group rules
3. **Application Insights**: Check that the Log Analytics workspace is in the same region
4. **Runtime Versions**: Ensure the runtime version is supported for the selected OS type

### Debugging

Enable diagnostic settings to get detailed logs:

```hcl
enable_diagnostic_settings = true
log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Ensure all tests pass
5. Submit a pull request

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](../../LICENSE) file for details.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.40 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.41.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_app_service_virtual_network_swift_connection.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/app_service_virtual_network_swift_connection) | resource |
| [azurerm_application_insights.functions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights) | resource |
| [azurerm_linux_function_app.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app) | resource |
| [azurerm_linux_function_app_slot.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app_slot) | resource |
| [azurerm_monitor_diagnostic_setting.function_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_monitor_diagnostic_setting.storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_storage_account.functions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_windows_function_app.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_function_app) | resource |
| [azurerm_windows_function_app_slot.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_function_app_slot) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_always_on"></a> [always\_on](#input\_always\_on) | Whether the Function App should always be on (not applicable for Consumption plan) | `bool` | `true` | no |
| <a name="input_app_settings"></a> [app\_settings](#input\_app\_settings) | Additional app settings for the Function App | `map(string)` | `{}` | no |
| <a name="input_application_insights_disable_ip_masking"></a> [application\_insights\_disable\_ip\_masking](#input\_application\_insights\_disable\_ip\_masking) | Whether to disable IP masking in Application Insights | `bool` | `false` | no |
| <a name="input_application_insights_internet_ingestion_enabled"></a> [application\_insights\_internet\_ingestion\_enabled](#input\_application\_insights\_internet\_ingestion\_enabled) | Whether internet ingestion is enabled for Application Insights | `bool` | `true` | no |
| <a name="input_application_insights_internet_query_enabled"></a> [application\_insights\_internet\_query\_enabled](#input\_application\_insights\_internet\_query\_enabled) | Whether internet query is enabled for Application Insights | `bool` | `true` | no |
| <a name="input_application_insights_local_auth_disabled"></a> [application\_insights\_local\_auth\_disabled](#input\_application\_insights\_local\_auth\_disabled) | Whether local authentication is disabled for Application Insights | `bool` | `true` | no |
| <a name="input_application_insights_retention_days"></a> [application\_insights\_retention\_days](#input\_application\_insights\_retention\_days) | The retention period in days for Application Insights | `number` | `90` | no |
| <a name="input_application_insights_sampling_percentage"></a> [application\_insights\_sampling\_percentage](#input\_application\_insights\_sampling\_percentage) | The sampling percentage for Application Insights | `number` | `100` | no |
| <a name="input_application_insights_type"></a> [application\_insights\_type](#input\_application\_insights\_type) | The type of Application Insights | `string` | `"web"` | no |
| <a name="input_auth_settings_active_directory"></a> [auth\_settings\_active\_directory](#input\_auth\_settings\_active\_directory) | Active Directory authentication settings | <pre>object({<br/>    client_id         = string<br/>    client_secret     = string<br/>    allowed_audiences = optional(list(string), [])<br/>  })</pre> | `null` | no |
| <a name="input_auth_settings_additional_login_parameters"></a> [auth\_settings\_additional\_login\_parameters](#input\_auth\_settings\_additional\_login\_parameters) | Additional login parameters | `map(string)` | `{}` | no |
| <a name="input_auth_settings_allowed_external_redirect_urls"></a> [auth\_settings\_allowed\_external\_redirect\_urls](#input\_auth\_settings\_allowed\_external\_redirect\_urls) | List of allowed external redirect URLs | `list(string)` | `[]` | no |
| <a name="input_auth_settings_default_provider"></a> [auth\_settings\_default\_provider](#input\_auth\_settings\_default\_provider) | The default authentication provider | `string` | `"AzureActiveDirectory"` | no |
| <a name="input_auth_settings_facebook"></a> [auth\_settings\_facebook](#input\_auth\_settings\_facebook) | Facebook authentication settings | <pre>object({<br/>    app_id       = string<br/>    app_secret   = string<br/>    oauth_scopes = optional(list(string), [])<br/>  })</pre> | `null` | no |
| <a name="input_auth_settings_google"></a> [auth\_settings\_google](#input\_auth\_settings\_google) | Google authentication settings | <pre>object({<br/>    client_id     = string<br/>    client_secret = string<br/>    oauth_scopes  = optional(list(string), [])<br/>  })</pre> | `null` | no |
| <a name="input_auth_settings_issuer"></a> [auth\_settings\_issuer](#input\_auth\_settings\_issuer) | The issuer URL for authentication | `string` | `null` | no |
| <a name="input_auth_settings_microsoft"></a> [auth\_settings\_microsoft](#input\_auth\_settings\_microsoft) | Microsoft authentication settings | <pre>object({<br/>    client_id     = string<br/>    client_secret = string<br/>    oauth_scopes  = optional(list(string), [])<br/>  })</pre> | `null` | no |
| <a name="input_auth_settings_runtime_version"></a> [auth\_settings\_runtime\_version](#input\_auth\_settings\_runtime\_version) | The runtime version for authentication | `string` | `"~1"` | no |
| <a name="input_auth_settings_token_refresh_extension_hours"></a> [auth\_settings\_token\_refresh\_extension\_hours](#input\_auth\_settings\_token\_refresh\_extension\_hours) | The token refresh extension hours | `number` | `72` | no |
| <a name="input_auth_settings_token_store_enabled"></a> [auth\_settings\_token\_store\_enabled](#input\_auth\_settings\_token\_store\_enabled) | Whether token store is enabled | `bool` | `false` | no |
| <a name="input_auth_settings_twitter"></a> [auth\_settings\_twitter](#input\_auth\_settings\_twitter) | Twitter authentication settings | <pre>object({<br/>    consumer_key    = string<br/>    consumer_secret = string<br/>  })</pre> | `null` | no |
| <a name="input_auth_settings_unauthenticated_client_action"></a> [auth\_settings\_unauthenticated\_client\_action](#input\_auth\_settings\_unauthenticated\_client\_action) | The action to take for unauthenticated clients | `string` | `"RedirectToLoginPage"` | no |
| <a name="input_backup_name"></a> [backup\_name](#input\_backup\_name) | The name of the backup | `string` | `"DefaultBackup"` | no |
| <a name="input_backup_schedule_frequency_interval"></a> [backup\_schedule\_frequency\_interval](#input\_backup\_schedule\_frequency\_interval) | The frequency interval for backup schedule | `number` | `1` | no |
| <a name="input_backup_schedule_frequency_unit"></a> [backup\_schedule\_frequency\_unit](#input\_backup\_schedule\_frequency\_unit) | The frequency unit for backup schedule | `string` | `"Day"` | no |
| <a name="input_backup_schedule_keep_at_least_one_backup"></a> [backup\_schedule\_keep\_at\_least\_one\_backup](#input\_backup\_schedule\_keep\_at\_least\_one\_backup) | Whether to keep at least one backup | `bool` | `true` | no |
| <a name="input_backup_schedule_retention_period_days"></a> [backup\_schedule\_retention\_period\_days](#input\_backup\_schedule\_retention\_period\_days) | The retention period in days for backups | `number` | `30` | no |
| <a name="input_backup_schedule_start_time"></a> [backup\_schedule\_start\_time](#input\_backup\_schedule\_start\_time) | The start time for backup schedule (ISO 8601 format) | `string` | `null` | no |
| <a name="input_backup_storage_account_url"></a> [backup\_storage\_account\_url](#input\_backup\_storage\_account\_url) | The storage account URL for backups | `string` | `null` | no |
| <a name="input_client_certificate_enabled"></a> [client\_certificate\_enabled](#input\_client\_certificate\_enabled) | Whether client certificates are enabled | `bool` | `false` | no |
| <a name="input_client_certificate_mode"></a> [client\_certificate\_mode](#input\_client\_certificate\_mode) | The client certificate mode | `string` | `"Optional"` | no |
| <a name="input_connection_strings"></a> [connection\_strings](#input\_connection\_strings) | Connection strings for the Function App | <pre>list(object({<br/>    name  = string<br/>    type  = string<br/>    value = string<br/>  }))</pre> | `[]` | no |
| <a name="input_cors_allowed_origins"></a> [cors\_allowed\_origins](#input\_cors\_allowed\_origins) | The allowed origins for CORS | `list(string)` | `[]` | no |
| <a name="input_cors_support_credentials"></a> [cors\_support\_credentials](#input\_cors\_support\_credentials) | Whether CORS should support credentials | `bool` | `false` | no |
| <a name="input_deployment_slots"></a> [deployment\_slots](#input\_deployment\_slots) | Map of deployment slots to create | <pre>map(object({<br/>    public_network_access_enabled = optional(bool, true)<br/>    app_settings                  = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_diagnostic_metrics"></a> [diagnostic\_metrics](#input\_diagnostic\_metrics) | List of metrics to enable for diagnostic settings | `list(string)` | <pre>[<br/>  "AllMetrics"<br/>]</pre> | no |
| <a name="input_diagnostic_storage_account_id"></a> [diagnostic\_storage\_account\_id](#input\_diagnostic\_storage\_account\_id) | The storage account ID for diagnostic settings | `string` | `null` | no |
| <a name="input_elastic_instance_minimum"></a> [elastic\_instance\_minimum](#input\_elastic\_instance\_minimum) | The minimum number of elastic instances for Premium plans | `number` | `1` | no |
| <a name="input_enable_application_insights"></a> [enable\_application\_insights](#input\_enable\_application\_insights) | Whether to enable Application Insights | `bool` | `true` | no |
| <a name="input_enable_auth_settings"></a> [enable\_auth\_settings](#input\_enable\_auth\_settings) | Whether to enable authentication settings | `bool` | `false` | no |
| <a name="input_enable_backup"></a> [enable\_backup](#input\_enable\_backup) | Whether to enable backup for the Function App | `bool` | `false` | no |
| <a name="input_enable_cors"></a> [enable\_cors](#input\_enable\_cors) | Whether to enable CORS | `bool` | `false` | no |
| <a name="input_enable_diagnostic_settings"></a> [enable\_diagnostic\_settings](#input\_enable\_diagnostic\_settings) | Whether to enable diagnostic settings | `bool` | `false` | no |
| <a name="input_enable_storage_network_rules"></a> [enable\_storage\_network\_rules](#input\_enable\_storage\_network\_rules) | Whether to enable network rules for the storage account | `bool` | `false` | no |
| <a name="input_enable_vnet_integration"></a> [enable\_vnet\_integration](#input\_enable\_vnet\_integration) | Whether to enable VNet integration for the Function App | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name | `string` | n/a | yes |
| <a name="input_eventhub_authorization_rule_id"></a> [eventhub\_authorization\_rule\_id](#input\_eventhub\_authorization\_rule\_id) | The Event Hub authorization rule ID for diagnostic settings | `string` | `null` | no |
| <a name="input_eventhub_name"></a> [eventhub\_name](#input\_eventhub\_name) | The Event Hub name for diagnostic settings | `string` | `null` | no |
| <a name="input_ftps_state"></a> [ftps\_state](#input\_ftps\_state) | The FTPS state | `string` | `"Disabled"` | no |
| <a name="input_function_app_scale_limit"></a> [function\_app\_scale\_limit](#input\_function\_app\_scale\_limit) | The maximum number of instances for the Function App | `number` | `200` | no |
| <a name="input_functions_extension_version"></a> [functions\_extension\_version](#input\_functions\_extension\_version) | The version of the Azure Functions runtime | `string` | `"~4"` | no |
| <a name="input_health_check_eviction_time_in_min"></a> [health\_check\_eviction\_time\_in\_min](#input\_health\_check\_eviction\_time\_in\_min) | The time in minutes after which an instance is evicted if health check fails | `number` | `10` | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | The health check path for the Function App | `string` | `null` | no |
| <a name="input_https_only"></a> [https\_only](#input\_https\_only) | Whether the Function App should only accept HTTPS requests | `bool` | `true` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | List of user assigned identity IDs | `list(string)` | `[]` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | The type of managed identity for the Function App | `string` | `"SystemAssigned"` | no |
| <a name="input_ip_restrictions"></a> [ip\_restrictions](#input\_ip\_restrictions) | List of IP restrictions for the Function App | <pre>list(object({<br/>    ip_address                = optional(string)<br/>    service_tag               = optional(string)<br/>    virtual_network_subnet_id = optional(string)<br/>    name                      = string<br/>    priority                  = number<br/>    action                    = string<br/>    headers = optional(object({<br/>      x_azure_fdid      = optional(list(string))<br/>      x_fd_health_probe = optional(list(string))<br/>      x_forwarded_for   = optional(list(string))<br/>      x_forwarded_host  = optional(list(string))<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_key_vault_reference_identity_id"></a> [key\_vault\_reference\_identity\_id](#input\_key\_vault\_reference\_identity\_id) | The identity ID to use for Key Vault references | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | The Log Analytics workspace ID for Application Insights | `string` | `null` | no |
| <a name="input_minimum_tls_version"></a> [minimum\_tls\_version](#input\_minimum\_tls\_version) | The minimum TLS version for the Function App | `string` | `"1.2"` | no |
| <a name="input_os_type"></a> [os\_type](#input\_os\_type) | The operating system type for the Function App (Linux or Windows) | `string` | `"Linux"` | no |
| <a name="input_pre_warmed_instance_count"></a> [pre\_warmed\_instance\_count](#input\_pre\_warmed\_instance\_count) | The number of pre-warmed instances for Premium plans | `number` | `1` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether public network access is enabled for the Function App | `bool` | `true` | no |
| <a name="input_remote_debugging_enabled"></a> [remote\_debugging\_enabled](#input\_remote\_debugging\_enabled) | Whether remote debugging is enabled | `bool` | `false` | no |
| <a name="input_remote_debugging_version"></a> [remote\_debugging\_version](#input\_remote\_debugging\_version) | The remote debugging version | `string` | `"VS2019"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group | `string` | n/a | yes |
| <a name="input_run_from_package"></a> [run\_from\_package](#input\_run\_from\_package) | Whether to run the Function App from a package | `bool` | `true` | no |
| <a name="input_runtime_name"></a> [runtime\_name](#input\_runtime\_name) | The runtime name for the Function App | `string` | `"python"` | no |
| <a name="input_runtime_version"></a> [runtime\_version](#input\_runtime\_version) | The runtime version for the Function App | `string` | `"3.11"` | no |
| <a name="input_scm_ip_restrictions"></a> [scm\_ip\_restrictions](#input\_scm\_ip\_restrictions) | List of SCM IP restrictions for the Function App | <pre>list(object({<br/>    ip_address                = optional(string)<br/>    service_tag               = optional(string)<br/>    virtual_network_subnet_id = optional(string)<br/>    name                      = string<br/>    priority                  = number<br/>    action                    = string<br/>    headers = optional(object({<br/>      x_azure_fdid      = optional(list(string))<br/>      x_fd_health_probe = optional(list(string))<br/>      x_forwarded_for   = optional(list(string))<br/>      x_forwarded_host  = optional(list(string))<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_scm_minimum_tls_version"></a> [scm\_minimum\_tls\_version](#input\_scm\_minimum\_tls\_version) | The minimum TLS version for SCM | `string` | `"1.2"` | no |
| <a name="input_scm_use_main_ip_restriction"></a> [scm\_use\_main\_ip\_restriction](#input\_scm\_use\_main\_ip\_restriction) | Whether SCM should use the main IP restrictions | `bool` | `false` | no |
| <a name="input_service_plan_id"></a> [service\_plan\_id](#input\_service\_plan\_id) | The ID of the App Service Plan to use for the Function App | `string` | n/a | yes |
| <a name="input_sticky_app_setting_names"></a> [sticky\_app\_setting\_names](#input\_sticky\_app\_setting\_names) | List of app setting names that should be sticky to deployment slots | `list(string)` | `[]` | no |
| <a name="input_sticky_connection_string_names"></a> [sticky\_connection\_string\_names](#input\_sticky\_connection\_string\_names) | List of connection string names that should be sticky to deployment slots | `list(string)` | `[]` | no |
| <a name="input_storage_account_replication_type"></a> [storage\_account\_replication\_type](#input\_storage\_account\_replication\_type) | The replication type of the storage account | `string` | `"LRS"` | no |
| <a name="input_storage_account_tier"></a> [storage\_account\_tier](#input\_storage\_account\_tier) | The tier of the storage account | `string` | `"Standard"` | no |
| <a name="input_storage_blob_delete_retention_days"></a> [storage\_blob\_delete\_retention\_days](#input\_storage\_blob\_delete\_retention\_days) | The number of days to retain deleted blobs | `number` | `7` | no |
| <a name="input_storage_container_delete_retention_days"></a> [storage\_container\_delete\_retention\_days](#input\_storage\_container\_delete\_retention\_days) | The number of days to retain deleted containers | `number` | `7` | no |
| <a name="input_storage_min_tls_version"></a> [storage\_min\_tls\_version](#input\_storage\_min\_tls\_version) | The minimum TLS version for the storage account | `string` | `"TLS1_2"` | no |
| <a name="input_storage_network_rules_bypass"></a> [storage\_network\_rules\_bypass](#input\_storage\_network\_rules\_bypass) | The bypass rules for storage network rules | `list(string)` | <pre>[<br/>  "AzureServices"<br/>]</pre> | no |
| <a name="input_storage_network_rules_default_action"></a> [storage\_network\_rules\_default\_action](#input\_storage\_network\_rules\_default\_action) | The default action for storage network rules | `string` | `"Allow"` | no |
| <a name="input_storage_network_rules_ip_rules"></a> [storage\_network\_rules\_ip\_rules](#input\_storage\_network\_rules\_ip\_rules) | The IP rules for storage network rules | `list(string)` | `[]` | no |
| <a name="input_storage_network_rules_subnet_ids"></a> [storage\_network\_rules\_subnet\_ids](#input\_storage\_network\_rules\_subnet\_ids) | The subnet IDs for storage network rules | `list(string)` | `[]` | no |
| <a name="input_storage_sas_expiration_action"></a> [storage\_sas\_expiration\_action](#input\_storage\_sas\_expiration\_action) | The action to take when SAS expires | `string` | `"Log"` | no |
| <a name="input_storage_sas_expiration_period"></a> [storage\_sas\_expiration\_period](#input\_storage\_sas\_expiration\_period) | The SAS expiration period for the storage account | `string` | `"01.00:00:00"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resources | `map(string)` | `{}` | no |
| <a name="input_use_32_bit_worker"></a> [use\_32\_bit\_worker](#input\_use\_32\_bit\_worker) | Whether to use 32-bit worker process | `bool` | `false` | no |
| <a name="input_use_dotnet_isolated_runtime"></a> [use\_dotnet\_isolated\_runtime](#input\_use\_dotnet\_isolated\_runtime) | Whether to use .NET isolated runtime | `bool` | `false` | no |
| <a name="input_vnet_integration_subnet_id"></a> [vnet\_integration\_subnet\_id](#input\_vnet\_integration\_subnet\_id) | The subnet ID for VNet integration | `string` | `null` | no |
| <a name="input_websockets_enabled"></a> [websockets\_enabled](#input\_websockets\_enabled) | Whether WebSockets are enabled | `bool` | `false` | no |
| <a name="input_worker_count"></a> [worker\_count](#input\_worker\_count) | The number of workers for the Function App | `number` | `1` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | The workload name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_insights_app_id"></a> [application\_insights\_app\_id](#output\_application\_insights\_app\_id) | The app ID of Application Insights |
| <a name="output_application_insights_connection_string"></a> [application\_insights\_connection\_string](#output\_application\_insights\_connection\_string) | The connection string of Application Insights |
| <a name="output_application_insights_id"></a> [application\_insights\_id](#output\_application\_insights\_id) | The ID of Application Insights |
| <a name="output_application_insights_instrumentation_key"></a> [application\_insights\_instrumentation\_key](#output\_application\_insights\_instrumentation\_key) | The instrumentation key of Application Insights |
| <a name="output_application_insights_name"></a> [application\_insights\_name](#output\_application\_insights\_name) | The name of Application Insights |
| <a name="output_deployment_slot_count"></a> [deployment\_slot\_count](#output\_deployment\_slot\_count) | Number of deployment slots created |
| <a name="output_deployment_slot_names"></a> [deployment\_slot\_names](#output\_deployment\_slot\_names) | List of deployment slot names |
| <a name="output_deployment_slots"></a> [deployment\_slots](#output\_deployment\_slots) | Information about deployment slots |
| <a name="output_diagnostic_settings_enabled"></a> [diagnostic\_settings\_enabled](#output\_diagnostic\_settings\_enabled) | Whether diagnostic settings are enabled |
| <a name="output_diagnostic_settings_function_app_id"></a> [diagnostic\_settings\_function\_app\_id](#output\_diagnostic\_settings\_function\_app\_id) | The ID of the Function App diagnostic settings |
| <a name="output_diagnostic_settings_storage_account_id"></a> [diagnostic\_settings\_storage\_account\_id](#output\_diagnostic\_settings\_storage\_account\_id) | The ID of the storage account diagnostic settings |
| <a name="output_environment"></a> [environment](#output\_environment) | The environment name |
| <a name="output_function_app_custom_domain_verification_id"></a> [function\_app\_custom\_domain\_verification\_id](#output\_function\_app\_custom\_domain\_verification\_id) | The custom domain verification ID for the Function App |
| <a name="output_function_app_default_hostname"></a> [function\_app\_default\_hostname](#output\_function\_app\_default\_hostname) | The default hostname of the Function App |
| <a name="output_function_app_hosting_environment_id"></a> [function\_app\_hosting\_environment\_id](#output\_function\_app\_hosting\_environment\_id) | The hosting environment ID of the Function App |
| <a name="output_function_app_id"></a> [function\_app\_id](#output\_function\_app\_id) | The ID of the Function App |
| <a name="output_function_app_identity"></a> [function\_app\_identity](#output\_function\_app\_identity) | The managed identity of the Function App |
| <a name="output_function_app_kind"></a> [function\_app\_kind](#output\_function\_app\_kind) | The kind of the Function App |
| <a name="output_function_app_name"></a> [function\_app\_name](#output\_function\_app\_name) | The name of the Function App |
| <a name="output_function_app_outbound_ip_addresses"></a> [function\_app\_outbound\_ip\_addresses](#output\_function\_app\_outbound\_ip\_addresses) | The outbound IP addresses of the Function App |
| <a name="output_function_app_possible_outbound_ip_addresses"></a> [function\_app\_possible\_outbound\_ip\_addresses](#output\_function\_app\_possible\_outbound\_ip\_addresses) | The possible outbound IP addresses of the Function App |
| <a name="output_function_app_principal_id"></a> [function\_app\_principal\_id](#output\_function\_app\_principal\_id) | The principal ID of the Function App's managed identity |
| <a name="output_function_app_site_credential"></a> [function\_app\_site\_credential](#output\_function\_app\_site\_credential) | The site credentials for the Function App |
| <a name="output_function_app_summary"></a> [function\_app\_summary](#output\_function\_app\_summary) | Summary of the Function App deployment |
| <a name="output_function_app_tenant_id"></a> [function\_app\_tenant\_id](#output\_function\_app\_tenant\_id) | The tenant ID of the Function App's managed identity |
| <a name="output_location"></a> [location](#output\_location) | The Azure region where resources are deployed |
| <a name="output_network_configuration"></a> [network\_configuration](#output\_network\_configuration) | Network configuration of the Function App |
| <a name="output_performance_configuration"></a> [performance\_configuration](#output\_performance\_configuration) | Performance configuration of the Function App |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group |
| <a name="output_runtime_configuration"></a> [runtime\_configuration](#output\_runtime\_configuration) | Runtime configuration of the Function App |
| <a name="output_security_configuration"></a> [security\_configuration](#output\_security\_configuration) | Security configuration of the Function App |
| <a name="output_service_plan_id"></a> [service\_plan\_id](#output\_service\_plan\_id) | The ID of the App Service Plan used by the Function App |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | The ID of the storage account |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | The name of the storage account |
| <a name="output_storage_account_primary_access_key"></a> [storage\_account\_primary\_access\_key](#output\_storage\_account\_primary\_access\_key) | The primary access key for the storage account |
| <a name="output_storage_account_primary_blob_endpoint"></a> [storage\_account\_primary\_blob\_endpoint](#output\_storage\_account\_primary\_blob\_endpoint) | The primary blob endpoint for the storage account |
| <a name="output_storage_account_primary_connection_string"></a> [storage\_account\_primary\_connection\_string](#output\_storage\_account\_primary\_connection\_string) | The primary connection string for the storage account |
| <a name="output_storage_account_primary_file_endpoint"></a> [storage\_account\_primary\_file\_endpoint](#output\_storage\_account\_primary\_file\_endpoint) | The primary file endpoint for the storage account |
| <a name="output_storage_account_primary_queue_endpoint"></a> [storage\_account\_primary\_queue\_endpoint](#output\_storage\_account\_primary\_queue\_endpoint) | The primary queue endpoint for the storage account |
| <a name="output_storage_account_primary_table_endpoint"></a> [storage\_account\_primary\_table\_endpoint](#output\_storage\_account\_primary\_table\_endpoint) | The primary table endpoint for the storage account |
| <a name="output_storage_account_secondary_access_key"></a> [storage\_account\_secondary\_access\_key](#output\_storage\_account\_secondary\_access\_key) | The secondary access key for the storage account |
| <a name="output_storage_account_secondary_connection_string"></a> [storage\_account\_secondary\_connection\_string](#output\_storage\_account\_secondary\_connection\_string) | The secondary connection string for the storage account |
| <a name="output_tags"></a> [tags](#output\_tags) | The tags applied to the resources |
| <a name="output_vnet_integration_enabled"></a> [vnet\_integration\_enabled](#output\_vnet\_integration\_enabled) | Whether VNet integration is enabled |
| <a name="output_vnet_integration_id"></a> [vnet\_integration\_id](#output\_vnet\_integration\_id) | The ID of the VNet integration |
| <a name="output_vnet_integration_subnet_id"></a> [vnet\_integration\_subnet\_id](#output\_vnet\_integration\_subnet\_id) | The subnet ID used for VNet integration |
| <a name="output_workload"></a> [workload](#output\_workload) | The workload name |
<!-- END_TF_DOCS -->
