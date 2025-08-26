# Complete App Service Function Example

This example demonstrates all available configuration options for the `app-service-function` module, showcasing advanced features and production-ready configurations. The Function App itself is intentionally NOT created here and should be deployed separately using the plan produced by this example.

## What This Example Creates

- **Resource Group**: Container for all resources
- **App Service Plan**: Elastic Premium plan configured for Function Apps
- **Storage Account**: For use by your Function App(s)
- **Application Insights**: For telemetry from your Function App(s)

## Advanced Features Demonstrated

### Scaling Configuration
- **Maximum Elastic Workers**: Scale up to 10 instances under load
- **SKU**: EP2 (Elastic Premium) for production performance

### Application Settings
This example includes comprehensive app settings for:
- Environment configuration
- Database connections
- Redis caching
- Storage accounts
- API endpoints
- Logging configuration
- Azure service integrations (Key Vault, Event Hub, Service Bus, Cosmos DB)
- Managed identity configuration

### Monitoring & Observability
- Application Insights enabled for telemetry
- Custom logging levels
- Performance monitoring

### Security & Compliance
- Managed identity support
- Comprehensive tagging for compliance (SOC2)

## Usage

1. **Initialize Terraform**:
   ```bash
   terraform init
   ```

2. **Plan the deployment**:
   ```bash
   terraform plan
   ```

3. **Apply the configuration**:
   ```bash
   terraform apply
   ```

4. **Clean up resources**:
   ```bash
   terraform destroy
   ```

## Configuration Details

### SKU and Performance
- **SKU**: EP2 (Elastic Premium)
- **Location**: East US

### Network Configuration
Network integration for Function Apps is not configured in this example. Configure VNet integration on your Function App resource when you create it separately, using a dedicated subnet with Microsoft.Web/serverFarms delegation.

### Monitoring
- **Application Insights**: Enabled
- **Log Level**: INFO
- **Enhanced Monitoring**: Enabled via tags

## Outputs

After deployment, you'll get outputs including:
- App Service Plan details (ID, name, SKU, OS type)
- Storage account name
- Application Insights connection string

## Production Considerations

This example demonstrates production-ready configurations for the plan and supporting resources:

1. **Performance**: Elastic Premium SKU and scaling configuration
2. **Monitoring**: Application Insights available for instrumentation
3. **Scalability**: Elastic scaling configuration on the plan
4. **Compliance**: Comprehensive tagging strategy

## Next Steps

- Create your Function App(s) referencing this plan
- Configure managed identities for secure service access
- Set up CI/CD pipelines for function deployment
- Configure custom domains and SSL certificates
- Implement monitoring dashboards and alerts
- Set up backup and disaster recovery procedures

For simpler configurations, see the [basic example](../basic/).

## Creating a Function App (Decoupled)

Use the outputs from this example to create Function Apps separately. For example, a Windows Function App with VNet integration:

```hcl
# Create a virtual network and subnet for Function App VNet integration
resource "azurerm_virtual_network" "example" {
  name                = "vnet-${local.workload}-${local.environment}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "functions" {
  name                 = "subnet-functions"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "function-delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_windows_function_app" "example" {
  name                = "func-${local.workload}-${local.environment}-001"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  storage_account_name       = azurerm_storage_account.functions.name
  storage_account_access_key = azurerm_storage_account.functions.primary_access_key
  service_plan_id            = module.function_app_service_plan.app_service_plan_id

  https_only = true

  site_config {
    application_stack {
      dotnet_version = "v6.0"
    }
    always_on = true
  }

  app_settings = {
    "FUNCTIONS_EXTENSION_VERSION"           = "~4"
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.functions.connection_string
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = azurerm_application_insights.functions.instrumentation_key
  }
}

# Configure VNet integration for the Function App
resource "azurerm_app_service_virtual_network_swift_connection" "example" {
  app_service_id = azurerm_windows_function_app.example.id
  subnet_id      = azurerm_subnet.functions.id
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.40 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.41.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_function_app_service_plan"></a> [function\_app\_service\_plan](#module\_function\_app\_service\_plan) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_application_insights.functions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_storage_account.functions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_service_plan_id"></a> [app\_service\_plan\_id](#output\_app\_service\_plan\_id) | The ID of the App Service Plan |
| <a name="output_app_service_plan_name"></a> [app\_service\_plan\_name](#output\_app\_service\_plan\_name) | The name of the App Service Plan |
| <a name="output_app_service_plan_os_type"></a> [app\_service\_plan\_os\_type](#output\_app\_service\_plan\_os\_type) | The operating system type of the App Service Plan |
| <a name="output_app_service_plan_sku"></a> [app\_service\_plan\_sku](#output\_app\_service\_plan\_sku) | The SKU of the App Service Plan |
| <a name="output_application_insights_connection_string"></a> [application\_insights\_connection\_string](#output\_application\_insights\_connection\_string) | Application Insights connection string |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | The name of the storage account |
<!-- END_TF_DOCS -->
