# Complete Networking Example

This example demonstrates all features and capabilities of the networking module, including advanced monitoring, security, and routing configurations.

## What This Example Creates

- Resource Group for the example
- Log Analytics Workspace for traffic analytics
- Virtual Network with comprehensive subnet configuration
- Multiple subnets with different purposes:
  - App Service subnet with delegation
  - Functions subnet with delegation
  - Private Endpoints subnet
  - Database subnet with SQL service endpoints
  - Management subnet with Storage service endpoints
- Network Security Groups with default and service-specific rules
- Route Table with custom routing
- Network Watcher for monitoring
- VNet Flow Logs with traffic analytics
- Storage Account for flow logs

## Features Demonstrated

- **Multiple Subnets**: Different subnet types for various Azure services
- **Service Endpoints**: Integration with Azure PaaS services
- **Subnet Delegations**: App Service and Function App delegations
- **Custom Routing**: Route table with default internet route
- **Network Monitoring**: Network Watcher and VNet flow logs
- **Traffic Analytics**: Integration with Log Analytics workspace
- **Security Rules**: Service-specific NSG rules for App Service and Functions
- **Comprehensive Outputs**: All available module outputs

## Architecture

```
VNet (10.0.0.0/16)
├── App Service Subnet (10.0.1.0/24)
│   ├── Service Endpoints: Microsoft.Web, Microsoft.Storage
│   └── Delegation: Microsoft.Web/serverFarms
├── Functions Subnet (10.0.2.0/24)
│   ├── Service Endpoints: Microsoft.Web, Microsoft.Storage, Microsoft.KeyVault
│   └── Delegation: Microsoft.Web/serverFarms
├── Private Endpoints Subnet (10.0.3.0/24)
├── Database Subnet (10.0.4.0/24)
│   └── Service Endpoints: Microsoft.Sql
└── Management Subnet (10.0.5.0/24)
    └── Service Endpoints: Microsoft.Storage
```

## Usage

1. Clone this repository
2. Navigate to this example directory
3. Initialize Terraform:
   ```bash
   terraform init
   ```
4. Plan the deployment:
   ```bash
   terraform plan
   ```
5. Apply the configuration:
   ```bash
   terraform apply
   ```

## Configuration

This example uses production-ready configuration:

- **Resource Group**: `rg-networking-complete-example`
- **Location**: `East US`
- **Environment**: `prod`
- **VNet Address Space**: `10.0.0.0/16`
- **Flow Log Retention**: 91 days
- **Traffic Analytics**: Enabled with Log Analytics

## Outputs

After deployment, you can view all created resources:

```bash
terraform output
```

Key outputs include:
- All Virtual Network details
- All subnet IDs and names for integration
- Network Security Group information
- Route table details
- Network Watcher and flow log information
- Log Analytics workspace details
- Comprehensive summaries and connectivity info

## Security Features

This complete example includes:

### Default Security Rules (All Subnets)
- HTTPS inbound traffic allowed (port 443)
- HTTP inbound traffic denied (port 80)
- HTTPS outbound traffic allowed (port 443)
- DNS outbound traffic allowed (port 53)

### Service-Specific Rules
- **App Service Management**: Ports 454-455 for App Service subnet
- **Function App Management**: Ports 454-455 for Functions subnet

### Monitoring and Compliance
- VNet flow logs for network traffic analysis
- Traffic analytics for security insights
- 91-day retention for compliance requirements
- Network Watcher for diagnostics

## Service Endpoints

Each subnet is configured with appropriate service endpoints:

- **App Service**: Microsoft.Web, Microsoft.Storage
- **Functions**: Microsoft.Web, Microsoft.Storage, Microsoft.KeyVault
- **Database**: Microsoft.Sql
- **Management**: Microsoft.Storage
- **Private Endpoints**: None (as recommended)

## Integration Examples

This networking setup can be integrated with other Azure services:

```hcl
# Use App Service subnet for web apps
module "app_service" {
  source = "../../../app-service-plan-web"
  
  subnet_id = module.networking.app_service_subnet_id
  # ... other configuration
}

# Use Functions subnet for function apps
module "function_app" {
  source = "../../../app-service-plan-function"
  
  subnet_id = module.networking.functions_subnet_id
  # ... other configuration
}

# Use Private Endpoints subnet for private connectivity
resource "azurerm_private_endpoint" "example" {
  subnet_id = module.networking.private_endpoints_subnet_id
  # ... other configuration
}
```

## Cost Considerations

This complete example creates several Azure resources that incur costs:

- **Log Analytics Workspace**: Pay-per-GB ingestion and retention
- **Network Watcher**: Flow logs storage costs
- **Storage Account**: Flow logs storage and transactions
- **VNet Flow Logs**: Processing and storage costs

For cost optimization in non-production environments, consider:
- Reducing flow log retention period
- Disabling traffic analytics
- Using basic Log Analytics tier

## Clean Up

To remove all resources created by this example:

```bash
terraform destroy
```

**Note**: Ensure you want to delete all resources, including the Log Analytics workspace and stored flow logs.

## Next Steps

After running this complete example:

1. **Explore Outputs**: Review all available outputs for integration
2. **Monitor Traffic**: Use Azure Monitor to view traffic analytics
3. **Integrate Services**: Deploy App Services using the created subnets
4. **Customize Security**: Add custom NSG rules as needed
5. **Scale Network**: Add additional subnets or modify address spaces

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5 |
| azurerm | ~> 4.40 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 4.40 |

## Estimated Deployment Time

- **Initial Deployment**: 5-10 minutes
- **With Flow Logs**: Additional 2-3 minutes for log configuration
- **Total**: Approximately 10-15 minutes

## Troubleshooting

Common issues and solutions:

1. **Flow Logs Not Working**: Ensure Network Watcher is enabled in the region
2. **Traffic Analytics Delays**: Data may take 10-15 minutes to appear
3. **Service Endpoint Issues**: Verify service endpoint configuration matches service requirements
4. **Delegation Conflicts**: Ensure subnet delegations match the intended Azure service

For more troubleshooting, see the main module documentation.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.13.1 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.42.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.43.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_networking"></a> [networking](#module\_networking) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_log_analytics_workspace.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_service_subnet_id"></a> [app\_service\_subnet\_id](#output\_app\_service\_subnet\_id) | ID of the App Service subnet |
| <a name="output_connectivity_info"></a> [connectivity\_info](#output\_connectivity\_info) | Information for connecting other resources to the network |
| <a name="output_flow_logs_storage_account_id"></a> [flow\_logs\_storage\_account\_id](#output\_flow\_logs\_storage\_account\_id) | ID of the flow logs storage account |
| <a name="output_functions_subnet_id"></a> [functions\_subnet\_id](#output\_functions\_subnet\_id) | ID of the Functions subnet |
| <a name="output_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#output\_log\_analytics\_workspace\_id) | ID of the Log Analytics workspace |
| <a name="output_log_analytics_workspace_name"></a> [log\_analytics\_workspace\_name](#output\_log\_analytics\_workspace\_name) | Name of the Log Analytics workspace |
| <a name="output_network_watcher_id"></a> [network\_watcher\_id](#output\_network\_watcher\_id) | ID of the Network Watcher |
| <a name="output_networking_summary"></a> [networking\_summary](#output\_networking\_summary) | Summary of networking configuration |
| <a name="output_nsg_ids"></a> [nsg\_ids](#output\_nsg\_ids) | Map of NSG names to their IDs |
| <a name="output_nsg_names"></a> [nsg\_names](#output\_nsg\_names) | Map of NSG keys to their actual names |
| <a name="output_private_endpoints_subnet_id"></a> [private\_endpoints\_subnet\_id](#output\_private\_endpoints\_subnet\_id) | ID of the Private Endpoints subnet |
| <a name="output_resource_names"></a> [resource\_names](#output\_resource\_names) | Map of all created resource names for reference |
| <a name="output_route_table_id"></a> [route\_table\_id](#output\_route\_table\_id) | ID of the route table |
| <a name="output_security_summary"></a> [security\_summary](#output\_security\_summary) | Summary of network security configuration |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | Map of subnet names to their IDs |
| <a name="output_subnet_names"></a> [subnet\_names](#output\_subnet\_names) | Map of subnet keys to their actual names |
| <a name="output_vnet_address_space"></a> [vnet\_address\_space](#output\_vnet\_address\_space) | Address space of the virtual network |
| <a name="output_vnet_flow_log_id"></a> [vnet\_flow\_log\_id](#output\_vnet\_flow\_log\_id) | ID of the VNet flow log |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | ID of the created virtual network |
| <a name="output_vnet_name"></a> [vnet\_name](#output\_vnet\_name) | Name of the created virtual network |
<!-- END_TF_DOCS -->
