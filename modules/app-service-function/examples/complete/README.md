# Complete App Service Function Example

This example demonstrates all available configuration options for the `app-service-function` module, showcasing advanced features and production-ready configurations.

## What This Example Creates

- **Resource Group**: Container for all resources
- **Virtual Network**: Network isolation for the Function App
- **Subnet**: Dedicated subnet with delegation for Function Apps
- **Function App Module**: Complete Function App setup with advanced configuration:
  - Storage Account for Function App state
  - App Service Plan with EP1 SKU (Elastic Premium)
  - Linux Function App with Python 3.11 runtime
  - VNet integration for network isolation
  - Application Insights for comprehensive monitoring
  - Custom scaling configuration (2 always-ready instances, up to 10 max)
  - Extensive app settings for production workloads
  - Security configurations (HTTPS-only, etc.)

## Advanced Features Demonstrated

### Scaling Configuration
- **Always Ready Instances**: 2 instances kept warm for immediate response
- **Maximum Elastic Workers**: Scale up to 10 instances under load
- **SKU**: EP1 (Elastic Premium) for production performance

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
- VNet integration for network isolation
- HTTPS-only enforcement
- Comprehensive tagging for compliance (SOC2)
- Managed identity support

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
- **SKU**: EP1 (Elastic Premium)
- **Python Version**: 3.11
- **Always Ready Instances**: 2
- **Maximum Workers**: 10
- **Location**: East US

### Network Configuration
- **VNet Integration**: Enabled with dedicated subnet
- **Public Network Access**: Disabled (VNet only)
- **Route All Traffic**: Through VNet

### Monitoring
- **Application Insights**: Enabled
- **Log Level**: INFO
- **Enhanced Monitoring**: Enabled via tags

## Outputs

After deployment, you'll get comprehensive outputs including:
- Function App details (name, ID, hostname)
- Storage account information
- App Service Plan ID
- Application Insights ID
- Network resource IDs

## Production Considerations

This example demonstrates production-ready configurations:

1. **Performance**: EP1 SKU with pre-warmed instances
2. **Security**: VNet integration and HTTPS-only
3. **Monitoring**: Application Insights with custom settings
4. **Scalability**: Elastic scaling configuration
5. **Compliance**: Comprehensive tagging strategy

## Next Steps

- Deploy your Python functions to the created Function App
- Configure managed identities for secure service access
- Set up CI/CD pipelines for function deployment
- Configure custom domains and SSL certificates
- Implement monitoring dashboards and alerts
- Set up backup and disaster recovery procedures

For simpler configurations, see the [basic example](../basic/).

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
| <a name="module_function_app"></a> [function\_app](#module\_function\_app) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.functions](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_service_plan_id"></a> [app\_service\_plan\_id](#output\_app\_service\_plan\_id) | The ID of the App Service Plan |
| <a name="output_application_insights_id"></a> [application\_insights\_id](#output\_application\_insights\_id) | The ID of Application Insights |
| <a name="output_function_app_default_hostname"></a> [function\_app\_default\_hostname](#output\_function\_app\_default\_hostname) | The default hostname of the Function App |
| <a name="output_function_app_id"></a> [function\_app\_id](#output\_function\_app\_id) | The ID of the Function App |
| <a name="output_function_app_name"></a> [function\_app\_name](#output\_function\_app\_name) | The name of the Function App |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | The ID of the Functions storage account |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | The name of the Functions storage account |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | The ID of the functions subnet |
| <a name="output_virtual_network_id"></a> [virtual\_network\_id](#output\_virtual\_network\_id) | The ID of the virtual network |
<!-- END_TF_DOCS -->
