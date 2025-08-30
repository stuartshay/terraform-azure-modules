# Complete Function App Example

This example demonstrates all features and configuration options available in the Function App module, including VNet integration, deployment slots, Key Vault integration, and comprehensive security configurations.

## What This Example Creates

- **App Service Plan**: EP1 (Elastic Premium) plan with configurable scaling
- **Function App**: Fully configured Function App with all security features
- **Storage Account**: Dedicated storage account with network restrictions
- **Application Insights**: Monitoring and telemetry with Log Analytics integration
- **Log Analytics Workspace**: Centralized logging and monitoring
- **Key Vault**: Secure storage for secrets and connection strings
- **User-Assigned Managed Identity**: For secure Key Vault access
- **VNet Integration**: Secure network connectivity
- **Deployment Slots**: Staging and testing environments
- **Comprehensive Security**: IP restrictions, TLS configuration, and more

## Features Demonstrated

- ✅ **Cross-Platform Support**: Linux and Windows Function Apps
- ✅ **Multiple Runtimes**: Python, Node.js, .NET, Java, PowerShell
- ✅ **VNet Integration**: Secure network connectivity
- ✅ **Deployment Slots**: Blue-green deployments with staging and testing slots
- ✅ **Key Vault Integration**: Secure secret management with managed identity
- ✅ **Application Insights**: Comprehensive monitoring and telemetry
- ✅ **Security Features**: IP restrictions, client certificates, TLS configuration
- ✅ **Storage Security**: Network rules and access restrictions
- ✅ **Diagnostic Settings**: Comprehensive logging and monitoring
- ✅ **Authentication**: Support for Azure AD and other providers
- ✅ **Backup Configuration**: Optional backup and restore capabilities
- ✅ **CORS Configuration**: Cross-origin resource sharing setup

## Prerequisites

1. **Azure Subscription**: Active Azure subscription with appropriate permissions
2. **Resource Group**: Existing resource group for deployment
3. **Virtual Network**: Existing VNet with a subnet for Function App integration
4. **Terraform**: Version >= 1.6
5. **Azure CLI**: For authentication and resource management

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Resource Group                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────┐    ┌─────────────────┐                    │
│  │   Key Vault     │    │  Log Analytics  │                    │
│  │   (Private)     │    │   Workspace     │                    │
│  └─────────────────┘    └─────────────────┘                    │
│                                                                 │
│  ┌─────────────────┐    ┌─────────────────┐                    │
│  │ App Service Plan│    │ Application     │                    │
│  │     (EP1)       │    │   Insights      │                    │
│  └─────────────────┘    └─────────────────┘                    │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────────┤
│  │                Function App                                 │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │  │ Production  │  │   Staging   │  │   Testing   │        │
│  │  │    Slot     │  │    Slot     │  │    Slot     │        │
│  │  └─────────────┘  └─────────────┘  └─────────────┘        │
│  └─────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────┐    ┌─────────────────┐                    │
│  │ Storage Account │    │ User Assigned   │                    │
│  │   (Private)     │    │   Identity      │                    │
│  └─────────────────┘    └─────────────────┘                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
                                │
                    ┌─────────────────┐
                    │ Virtual Network │
                    │   Integration   │
                    └─────────────────┘
```

## Usage

### 1. Clone and Navigate

```bash
git clone <repository-url>
cd modules/function-app/examples/complete
```

### 2. Configure Variables

Create a `terraform.tfvars` file:

```hcl
# Basic configuration
workload            = "myapp"
environment         = "prod"
resource_group_name = "rg-myapp-prod-001"

# Network configuration
virtual_network_name = "vnet-myapp-prod-001"
subnet_name         = "snet-functions-prod-001"

# App Service Plan configuration
app_service_plan_sku         = "EP2"
maximum_elastic_worker_count = 20

# Function App configuration
runtime_name    = "python"
runtime_version = "3.11"

# Security configuration
public_network_access_enabled = false
client_certificate_enabled    = true
client_certificate_mode       = "Required"

# Performance configuration
pre_warmed_instance_count = 3
elastic_instance_minimum  = 2
function_app_scale_limit  = 200

# Network security
ip_restrictions = [
  {
    name       = "AllowOfficeIP"
    ip_address = "203.0.113.0/24"
    priority   = 100
    action     = "Allow"
  },
  {
    name       = "AllowAzurePortal"
    service_tag = "AzurePortal"
    priority   = 200
    action     = "Allow"
  }
]

# Custom app settings
app_settings = {
  "API_VERSION"        = "v2"
  "FEATURE_FLAGS"      = "production"
  "CACHE_TIMEOUT"      = "3600"
  "MAX_CONNECTIONS"    = "100"
}

# Deployment slots
deployment_slots = {
  staging = {
    public_network_access_enabled = false
    app_settings = {
      "SLOT_NAME"     = "staging"
      "ENVIRONMENT"   = "staging"
      "DEBUG_MODE"    = "true"
    }
  }
}

# Authentication (optional)
enable_auth_settings = true
auth_settings_active_directory = {
  client_id     = "your-aad-client-id"
  client_secret = "your-aad-client-secret"
  allowed_audiences = [
    "api://myapp-functions"
  ]
}

# Tags
cost_center = "engineering"
owner       = "platform-team"
```

### 3. Initialize and Deploy

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

### 4. Access Your Resources

After deployment, you can access your resources using the provided outputs:

```bash
# Get the Function App URL
terraform output function_app_url

# Get deployment summary
terraform output deployment_summary

# Get access information
terraform output access_information
```

## Configuration Options

### Runtime Configuration

```hcl
# Python Function App
runtime_name    = "python"
runtime_version = "3.11"

# Node.js Function App
runtime_name    = "node"
runtime_version = "18"

# .NET Function App
runtime_name                = "dotnet"
runtime_version             = "6.0"
use_dotnet_isolated_runtime = true

# Java Function App
runtime_name    = "java"
runtime_version = "11"

# PowerShell Function App
runtime_name    = "powershell"
runtime_version = "7.2"
```

### Security Configuration

```hcl
# Network security
public_network_access_enabled = false
enable_vnet_integration       = true

# Client certificates
client_certificate_enabled = true
client_certificate_mode     = "Required"

# TLS configuration
minimum_tls_version     = "1.2"
scm_minimum_tls_version = "1.2"

# IP restrictions
ip_restrictions = [
  {
    name       = "AllowOfficeNetwork"
    ip_address = "203.0.113.0/24"
    priority   = 100
    action     = "Allow"
  },
  {
    name               = "AllowVNetSubnet"
    virtual_network_subnet_id = data.azurerm_subnet.allowed.id
    priority           = 200
    action             = "Allow"
  }
]
```

### Performance Configuration

```hcl
# App Service Plan scaling
app_service_plan_sku         = "EP2"
maximum_elastic_worker_count = 20

# Function App performance
pre_warmed_instance_count = 3
elastic_instance_minimum  = 2
function_app_scale_limit  = 200
worker_count             = 2

# Health monitoring
health_check_path                 = "/api/health"
health_check_eviction_time_in_min = 5
```

### Storage Configuration

```hcl
# Storage security
storage_public_network_access_enabled = false
enable_storage_network_rules          = true

# Storage performance
storage_account_tier             = "Standard"
storage_account_replication_type = "LRS"

# Data retention
storage_blob_delete_retention_days      = 30
storage_container_delete_retention_days = 30
```

### Deployment Slots

```hcl
deployment_slots = {
  staging = {
    public_network_access_enabled = false
    app_settings = {
      "ENVIRONMENT" = "staging"
      "DEBUG_MODE"  = "true"
      "LOG_LEVEL"   = "DEBUG"
    }
  }
  testing = {
    public_network_access_enabled = false
    app_settings = {
      "ENVIRONMENT"   = "testing"
      "FEATURE_FLAGS" = "experimental"
    }
  }
  canary = {
    public_network_access_enabled = false
    app_settings = {
      "ENVIRONMENT"    = "canary"
      "CANARY_PERCENT" = "10"
    }
  }
}

# Sticky settings (won't swap between slots)
sticky_app_setting_names = [
  "ENVIRONMENT",
  "SLOT_NAME",
  "DATABASE_CONNECTION_STRING"
]
```

### Authentication Configuration

```hcl
enable_auth_settings = true

# Azure Active Directory
auth_settings_active_directory = {
  client_id     = "your-aad-client-id"
  client_secret = "your-aad-client-secret"
  allowed_audiences = [
    "api://myapp-functions",
    "https://myapp.azurewebsites.net"
  ]
}

# Authentication behavior
auth_settings_unauthenticated_client_action = "RedirectToLoginPage"
auth_settings_token_store_enabled           = true
```

## Key Vault Integration

This example demonstrates secure secret management using Azure Key Vault:

```hcl
# App settings with Key Vault references
app_settings = {
  "DATABASE_CONNECTION_STRING" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.database_connection.id})"
  "API_KEY"                   = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.api_key.id})"
  "STORAGE_CONNECTION_STRING" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.storage_connection.id})"
}
```

The Function App uses a user-assigned managed identity to access Key Vault secrets securely.

## Monitoring and Observability

### Application Insights

- **Telemetry Collection**: Automatic collection of requests, dependencies, and exceptions
- **Custom Metrics**: Support for custom telemetry and metrics
- **Log Analytics Integration**: Centralized logging with query capabilities
- **Alerting**: Configurable alerts based on metrics and logs

### Diagnostic Settings

- **Function App Logs**: Comprehensive logging of function executions
- **Storage Account Logs**: Access and operation logs
- **Metrics**: Performance and usage metrics
- **Integration**: Seamless integration with Azure Monitor

## Deployment Strategies

### Blue-Green Deployment

```bash
# Deploy to staging slot
az functionapp deployment source config-zip \
  --resource-group rg-myapp-prod-001 \
  --name func-myapp-prod-eastus-001 \
  --slot staging \
  --src function-app.zip

# Test staging slot
curl https://func-myapp-prod-eastus-001-staging.azurewebsites.net/api/health

# Swap staging to production
az functionapp deployment slot swap \
  --resource-group rg-myapp-prod-001 \
  --name func-myapp-prod-eastus-001 \
  --slot staging \
  --target-slot production
```

### Canary Deployment

```bash
# Deploy to canary slot with traffic splitting
az functionapp traffic-routing set \
  --resource-group rg-myapp-prod-001 \
  --name func-myapp-prod-eastus-001 \
  --distribution canary=10 production=90
```

## Security Best Practices

This example implements comprehensive security measures:

### Network Security
- Private VNet integration
- Storage account network restrictions
- IP allowlisting for management access
- HTTPS-only enforcement

### Identity and Access Management
- System-assigned and user-assigned managed identities
- Key Vault integration for secrets
- Azure AD authentication
- Role-based access control

### Data Protection
- TLS 1.2 minimum enforcement
- Client certificate authentication
- Encrypted storage with retention policies
- Secure backup configuration

## Troubleshooting

### Common Issues

1. **VNet Integration Failures**
   ```bash
   # Check subnet delegation
   az network vnet subnet show \
     --resource-group rg-myapp-prod-001 \
     --vnet-name vnet-myapp-prod-001 \
     --name snet-functions-prod-001 \
     --query delegations
   ```

2. **Key Vault Access Issues**
   ```bash
   # Verify managed identity permissions
   az keyvault show \
     --name kv-myapp-prod-001 \
     --query properties.accessPolicies
   ```

3. **Storage Account Access**
   ```bash
   # Check network rules
   az storage account show \
     --name stfuncmyappprod001 \
     --resource-group rg-myapp-prod-001 \
     --query networkRuleSet
   ```

### Debugging

Enable comprehensive logging:

```bash
# View Function App logs
az functionapp log tail \
  --resource-group rg-myapp-prod-001 \
  --name func-myapp-prod-eastus-001

# Query Application Insights
az monitor app-insights query \
  --app appi-myapp-functions-prod-eastus-001 \
  --analytics-query "requests | limit 10"
```

## Outputs

This example provides comprehensive outputs for integration and management:

| Output | Description |
|--------|-------------|
| `function_app_url` | Main Function App URL |
| `deployment_summary` | Complete deployment information |
| `access_information` | URLs for accessing all resources |
| `security_configuration` | Security settings summary |
| `monitoring` | Monitoring and logging information |

## Cleanup

To remove all resources:

```bash
terraform destroy
```

**Note**: This will permanently delete all resources including data in storage accounts and Key Vault.

## Next Steps

After deploying this complete example:

1. **Deploy Function Code**: Use Azure Functions Core Tools or CI/CD pipelines
2. **Configure Monitoring**: Set up alerts and dashboards
3. **Implement CI/CD**: Automate deployments with Azure DevOps or GitHub Actions
4. **Scale Testing**: Test scaling behavior under load
5. **Security Review**: Conduct security assessment and penetration testing

## Related Examples

- [Basic Example](../basic/) - Minimal configuration for getting started

## Contributing

Contributions are welcome! Please read the contributing guidelines and submit pull requests for any improvements.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.40 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.42.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_app_service_plan"></a> [app\_service\_plan](#module\_app\_service\_plan) | app.terraform.io/azure-policy-cloud/app-service-plan-function/azurerm | 1.1.34 |
| <a name="module_function_app"></a> [function\_app](#module\_function\_app) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_access_policy.function_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_secret.database_connection](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_log_analytics_workspace.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_user_assigned_identity.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subnet.functions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |
| [azurerm_virtual_network.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_service_plan_sku"></a> [app\_service\_plan\_sku](#input\_app\_service\_plan\_sku) | The SKU for the App Service Plan | `string` | `"EP1"` | no |
| <a name="input_app_settings"></a> [app\_settings](#input\_app\_settings) | Additional app settings for the Function App | `map(string)` | <pre>{<br/>  "API_VERSION": "v1",<br/>  "CUSTOM_SETTING": "example_value",<br/>  "FEATURE_FLAGS": "enabled"<br/>}</pre> | no |
| <a name="input_client_certificate_enabled"></a> [client\_certificate\_enabled](#input\_client\_certificate\_enabled) | Whether client certificates are enabled | `bool` | `true` | no |
| <a name="input_client_certificate_mode"></a> [client\_certificate\_mode](#input\_client\_certificate\_mode) | The client certificate mode | `string` | `"Optional"` | no |
| <a name="input_cors_allowed_origins"></a> [cors\_allowed\_origins](#input\_cors\_allowed\_origins) | The allowed origins for CORS | `list(string)` | <pre>[<br/>  "https://portal.azure.com",<br/>  "https://ms.portal.azure.com"<br/>]</pre> | no |
| <a name="input_cors_support_credentials"></a> [cors\_support\_credentials](#input\_cors\_support\_credentials) | Whether CORS should support credentials | `bool` | `false` | no |
| <a name="input_cost_center"></a> [cost\_center](#input\_cost\_center) | Cost center for resource billing | `string` | `"engineering"` | no |
| <a name="input_database_connection_string"></a> [database\_connection\_string](#input\_database\_connection\_string) | Database connection string to store in Key Vault | `string` | `"Server=tcp:example.database.windows.net,1433;Database=example;User ID=admin;Password=SecurePassword123!;Encrypt=true;TrustServerCertificate=false;Connection Timeout=30;"` | no |
| <a name="input_deployment_slots"></a> [deployment\_slots](#input\_deployment\_slots) | Map of deployment slots to create | <pre>map(object({<br/>    public_network_access_enabled = optional(bool, true)<br/>    app_settings                  = optional(map(string), {})<br/>  }))</pre> | <pre>{<br/>  "staging": {<br/>    "app_settings": {<br/>      "DEBUG_MODE": "true",<br/>      "ENVIRONMENT": "staging",<br/>      "LOG_LEVEL": "DEBUG",<br/>      "SLOT_NAME": "staging"<br/>    },<br/>    "public_network_access_enabled": false<br/>  },<br/>  "testing": {<br/>    "app_settings": {<br/>      "DEBUG_MODE": "true",<br/>      "ENVIRONMENT": "testing",<br/>      "FEATURE_FLAGS": "experimental",<br/>      "LOG_LEVEL": "DEBUG",<br/>      "SLOT_NAME": "testing"<br/>    },<br/>    "public_network_access_enabled": false<br/>  }<br/>}</pre> | no |
| <a name="input_elastic_instance_minimum"></a> [elastic\_instance\_minimum](#input\_elastic\_instance\_minimum) | The minimum number of elastic instances for Premium plans | `number` | `1` | no |
| <a name="input_enable_cors"></a> [enable\_cors](#input\_enable\_cors) | Whether to enable CORS | `bool` | `true` | no |
| <a name="input_enable_storage_network_rules"></a> [enable\_storage\_network\_rules](#input\_enable\_storage\_network\_rules) | Whether to enable network rules for the storage account | `bool` | `true` | no |
| <a name="input_enable_vnet_integration"></a> [enable\_vnet\_integration](#input\_enable\_vnet\_integration) | Whether to enable VNet integration for the Function App | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name | `string` | `"dev"` | no |
| <a name="input_function_app_scale_limit"></a> [function\_app\_scale\_limit](#input\_function\_app\_scale\_limit) | The maximum number of instances for the Function App | `number` | `100` | no |
| <a name="input_maximum_elastic_worker_count"></a> [maximum\_elastic\_worker\_count](#input\_maximum\_elastic\_worker\_count) | Maximum number of elastic workers for the App Service Plan | `number` | `10` | no |
| <a name="input_os_type"></a> [os\_type](#input\_os\_type) | The operating system type for the Function App | `string` | `"Linux"` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | Owner of the resources | `string` | `"platform-team"` | no |
| <a name="input_pre_warmed_instance_count"></a> [pre\_warmed\_instance\_count](#input\_pre\_warmed\_instance\_count) | The number of pre-warmed instances for Premium plans | `number` | `2` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether public network access is enabled for the Function App | `bool` | `false` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the existing resource group | `string` | `"rg-example-dev-001"` | no |
| <a name="input_runtime_name"></a> [runtime\_name](#input\_runtime\_name) | The runtime name for the Function App | `string` | `"python"` | no |
| <a name="input_runtime_version"></a> [runtime\_version](#input\_runtime\_version) | The runtime version for the Function App | `string` | `"3.11"` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | The name of the existing subnet for VNet integration | `string` | `"snet-functions-dev-001"` | no |
| <a name="input_use_dotnet_isolated_runtime"></a> [use\_dotnet\_isolated\_runtime](#input\_use\_dotnet\_isolated\_runtime) | Whether to use .NET isolated runtime | `bool` | `false` | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | The name of the existing virtual network | `string` | `"vnet-example-dev-001"` | no |
| <a name="input_websockets_enabled"></a> [websockets\_enabled](#input\_websockets\_enabled) | Whether WebSockets are enabled | `bool` | `false` | no |
| <a name="input_worker_count"></a> [worker\_count](#input\_worker\_count) | The number of workers for the Function App | `number` | `1` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | The workload name | `string` | `"example"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_service_plan_id"></a> [app\_service\_plan\_id](#output\_app\_service\_plan\_id) | The ID of the App Service Plan |
| <a name="output_app_service_plan_name"></a> [app\_service\_plan\_name](#output\_app\_service\_plan\_name) | The name of the App Service Plan |
| <a name="output_app_service_plan_sku"></a> [app\_service\_plan\_sku](#output\_app\_service\_plan\_sku) | The SKU of the App Service Plan |
| <a name="output_application_insights_app_id"></a> [application\_insights\_app\_id](#output\_application\_insights\_app\_id) | The app ID of Application Insights |
| <a name="output_application_insights_connection_string"></a> [application\_insights\_connection\_string](#output\_application\_insights\_connection\_string) | The connection string of Application Insights |
| <a name="output_application_insights_id"></a> [application\_insights\_id](#output\_application\_insights\_id) | The ID of Application Insights |
| <a name="output_application_insights_instrumentation_key"></a> [application\_insights\_instrumentation\_key](#output\_application\_insights\_instrumentation\_key) | The instrumentation key of Application Insights |
| <a name="output_application_insights_name"></a> [application\_insights\_name](#output\_application\_insights\_name) | The name of Application Insights |
| <a name="output_deployment_slot_count"></a> [deployment\_slot\_count](#output\_deployment\_slot\_count) | Number of deployment slots created |
| <a name="output_deployment_slot_names"></a> [deployment\_slot\_names](#output\_deployment\_slot\_names) | List of deployment slot names |
| <a name="output_diagnostic_settings_enabled"></a> [diagnostic\_settings\_enabled](#output\_diagnostic\_settings\_enabled) | Whether diagnostic settings are enabled |
| <a name="output_environment"></a> [environment](#output\_environment) | The environment name |
| <a name="output_function_app_default_hostname"></a> [function\_app\_default\_hostname](#output\_function\_app\_default\_hostname) | The default hostname of the Function App |
| <a name="output_function_app_id"></a> [function\_app\_id](#output\_function\_app\_id) | The ID of the Function App |
| <a name="output_function_app_name"></a> [function\_app\_name](#output\_function\_app\_name) | The name of the Function App |
| <a name="output_function_app_outbound_ip_addresses"></a> [function\_app\_outbound\_ip\_addresses](#output\_function\_app\_outbound\_ip\_addresses) | The outbound IP addresses of the Function App |
| <a name="output_function_app_possible_outbound_ip_addresses"></a> [function\_app\_possible\_outbound\_ip\_addresses](#output\_function\_app\_possible\_outbound\_ip\_addresses) | The possible outbound IP addresses of the Function App |
| <a name="output_function_app_summary"></a> [function\_app\_summary](#output\_function\_app\_summary) | Summary of the Function App deployment |
| <a name="output_location"></a> [location](#output\_location) | The Azure region where resources are deployed |
| <a name="output_network_configuration"></a> [network\_configuration](#output\_network\_configuration) | Network configuration of the Function App |
| <a name="output_performance_configuration"></a> [performance\_configuration](#output\_performance\_configuration) | Performance configuration of the Function App |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group |
| <a name="output_runtime_configuration"></a> [runtime\_configuration](#output\_runtime\_configuration) | Runtime configuration of the Function App |
| <a name="output_security_configuration"></a> [security\_configuration](#output\_security\_configuration) | Security configuration of the Function App |
| <a name="output_vnet_integration_enabled"></a> [vnet\_integration\_enabled](#output\_vnet\_integration\_enabled) | Whether VNet integration is enabled |
| <a name="output_vnet_integration_subnet_id"></a> [vnet\_integration\_subnet\_id](#output\_vnet\_integration\_subnet\_id) | The subnet ID used for VNet integration |
| <a name="output_workload"></a> [workload](#output\_workload) | The workload name |
<!-- END_TF_DOCS -->
