# Complete Private Endpoint Example

This example demonstrates advanced usage of the private endpoint module with DNS integration, multiple private endpoints, and comprehensive configuration for both Azure Service Bus and Storage Account services.

## Overview

This example creates:
- Azure Service Bus namespace with private endpoint
- Azure Storage Account with multiple private endpoints (blob and file)
- Private DNS zones for proper name resolution
- DNS zone links to the virtual network
- Complete DNS integration for all private endpoints

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Virtual Network                          │
│  ┌─────────────────────────────────────────────────────────┐│
│  │              Private Endpoint Subnet                   ││
│  │                                                         ││
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ││
│  │  │ Service Bus  │  │ Storage Blob │  │ Storage File │  ││
│  │  │ Private EP   │  │ Private EP   │  │ Private EP   │  ││
│  │  └──────────────┘  └──────────────┘  └──────────────┘  ││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   Private DNS Zones                         │
│  • privatelink.servicebus.windows.net                      │
│  • privatelink.blob.core.windows.net                       │
│  • privatelink.file.core.windows.net                       │
└─────────────────────────────────────────────────────────────┘
```

## Prerequisites

Before running this example, ensure you have:

1. **Existing Infrastructure**:
   - Resource group
   - Virtual network
   - Subnet designated for private endpoints

2. **Azure CLI or PowerShell**: Authenticated and configured
3. **Terraform**: Version >= 1.5 installed
4. **Permissions**: Contributor access to the resource group and Network Contributor for VNet operations

## Usage

1. **Clone the repository** and navigate to this example:
   ```bash
   cd modules/private-endpoint/examples/complete
   ```

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

3. **Review and customize variables** (optional):
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

4. **Plan the deployment**:
   ```bash
   terraform plan
   ```

5. **Apply the configuration**:
   ```bash
   terraform apply
   ```

6. **Clean up** when done:
   ```bash
   terraform destroy
   ```

## Configuration

### Required Variables

You need to provide values for the following variables:

```hcl
resource_group_name           = "rg-myproject-prod-eastus-001"
virtual_network_name          = "vnet-myproject-prod-eastus-001"
private_endpoint_subnet_name  = "snet-private-endpoints-myproject-prod-eastus-001"
servicebus_namespace_name     = "sb-myproject-pe-complete-001"  # Must be globally unique
storage_account_name          = "stmyprojectpecomplete001"      # Must be globally unique
```

### Example terraform.tfvars

```hcl
resource_group_name          = "rg-example-prod-eastus-001"
virtual_network_name         = "vnet-example-prod-eastus-001"
private_endpoint_subnet_name = "snet-private-endpoints-example-prod-eastus-001"
servicebus_namespace_name    = "sb-example-pe-complete-001"
storage_account_name         = "stexamplepecomplete001"

tags = {
  Environment = "prod"
  Project     = "private-endpoint-example"
  Owner       = "platform-team"
  CostCenter  = "engineering"
  Application = "messaging-storage"
}
```

## What This Example Creates

### Azure Resources

1. **Service Bus Namespace** (`azurerm_servicebus_namespace.example`)
   - Premium SKU with 1 messaging unit
   - Public network access disabled
   - Private endpoint for namespace subresource

2. **Storage Account** (`azurerm_storage_account.example`)
   - Standard LRS storage account
   - Public network access disabled
   - HTTPS traffic only enabled
   - TLS 1.2 minimum version
   - Private endpoints for blob and file services

3. **Private DNS Zones**:
   - `privatelink.servicebus.windows.net`
   - `privatelink.blob.core.windows.net`
   - `privatelink.file.core.windows.net`

4. **Private Endpoints** (via module):
   - Service Bus namespace private endpoint
   - Storage account blob private endpoint
   - Storage account file private endpoint

5. **DNS Zone Virtual Network Links**:
   - Links all private DNS zones to the virtual network
   - Enables automatic DNS resolution for private endpoints

### Network Configuration

- All private endpoints are deployed in your specified subnet
- Public network access is disabled for all services
- Traffic flows privately through the Azure backbone network
- DNS resolution is handled automatically via private DNS zones

## Outputs

After successful deployment, you'll see comprehensive outputs including:

### Service Bus Outputs
- `servicebus_namespace_id`: Resource ID of the Service Bus namespace
- `servicebus_private_endpoint_id`: Resource ID of the Service Bus private endpoint
- `servicebus_private_endpoint_ip`: Private IP address of the Service Bus endpoint

### Storage Account Outputs
- `storage_account_id`: Resource ID of the storage account
- `storage_private_endpoint_ids`: Map of private endpoint IDs (blob, file)
- `storage_private_endpoint_ips`: Map of private IP addresses

### DNS Configuration
- `private_dns_zone_ids`: IDs of all created private DNS zones
- `servicebus_dns_configs`: DNS configurations for Service Bus
- `storage_dns_configs`: DNS configurations for storage endpoints

## Testing the Private Endpoints

After deployment, you can test the private endpoints:

### 1. DNS Resolution Test

From a VM in the same VNet:

```bash
# Test Service Bus DNS resolution
nslookup sb-example-pe-complete-001.servicebus.windows.net

# Test Storage Account DNS resolution
nslookup stexamplepecomplete001.blob.core.windows.net
nslookup stexamplepecomplete001.file.core.windows.net

# All should resolve to private IPs (10.x.x.x)
```

### 2. Azure CLI Validation

```bash
# List all private endpoints
az network private-endpoint list --resource-group rg-example-prod-eastus-001

# Check Service Bus private endpoint
az network private-endpoint show \
  --name pe-sb-example-pe-complete-001-namespace \
  --resource-group rg-example-prod-eastus-001

# Check storage private endpoints
az network private-endpoint show \
  --name pe-stexamplepecomplete001-blob \
  --resource-group rg-example-prod-eastus-001

# Verify DNS zones
az network private-dns zone list --resource-group rg-example-prod-eastus-001
```

### 3. Connectivity Test

From a VM in the VNet:

```bash
# Test Service Bus connectivity (requires Service Bus client)
# This would typically be done through application code

# Test Storage Account connectivity
curl -I https://stexamplepecomplete001.blob.core.windows.net
curl -I https://stexamplepecomplete001.file.core.windows.net
```

## Advanced Features Demonstrated

### 1. Multiple Private Endpoints
- Shows how to create multiple private endpoints for different subresources
- Demonstrates proper DNS zone configuration for each service type

### 2. DNS Integration
- Complete private DNS zone setup
- Automatic DNS resolution within the VNet
- Proper zone linking to virtual networks

### 3. Custom Naming
- Custom private service connection names
- Custom DNS zone group names
- Consistent naming patterns

### 4. Security Best Practices
- Public network access disabled
- HTTPS-only configuration
- Minimum TLS version enforcement
- Proper network isolation

## Security Considerations

1. **Network Isolation**: All services are isolated from the public internet
2. **DNS Security**: Private DNS zones prevent DNS hijacking
3. **Encryption**: All traffic uses HTTPS/TLS encryption
4. **Access Control**: Implement proper RBAC and network security groups
5. **Monitoring**: Enable diagnostic settings for all resources

## Troubleshooting

### Common Issues

1. **Resource name conflicts**:
   - Service Bus and Storage Account names must be globally unique
   - Try different names if you encounter conflicts

2. **DNS resolution issues**:
   - Verify private DNS zones are linked to the correct VNet
   - Check that VMs are using Azure-provided DNS (168.63.129.16)

3. **Connectivity problems**:
   - Ensure Network Security Groups allow traffic to private endpoints
   - Verify subnet has sufficient IP addresses

4. **Permission errors**:
   - Ensure you have Contributor access to the resource group
   - Verify Network Contributor permissions for VNet operations

### Validation Commands

```bash
# Verify all resources exist
terraform state list

# Check private endpoint connection states
az network private-endpoint list \
  --resource-group rg-example-prod-eastus-001 \
  --query "[].{Name:name, State:privateLinkServiceConnections[0].privateLinkServiceConnectionState.status}"

# Test DNS resolution from Azure Cloud Shell
nslookup sb-example-pe-complete-001.servicebus.windows.net
nslookup stexamplepecomplete001.blob.core.windows.net
```

## Cost Considerations

This example creates the following billable resources:
- Service Bus Premium namespace (higher cost than Standard/Basic)
- Storage Account (minimal cost for LRS)
- Private endpoints (per endpoint per hour)
- Private DNS zones (minimal cost)

Estimated monthly cost: $50-100 USD (varies by region and usage)

## Next Steps

After successfully running this complete example:

1. **Integrate with applications**: Connect your applications to use these private endpoints
2. **Add monitoring**: Implement Azure Monitor and diagnostic settings
3. **Scale the solution**: Add more services and private endpoints
4. **Implement automation**: Use this pattern in your CI/CD pipelines
5. **Add security**: Implement additional security controls and monitoring

## Related Documentation

- [Azure Private Endpoints Overview](https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-overview)
- [Private Endpoints for Service Bus](https://docs.microsoft.com/en-us/azure/service-bus-messaging/private-link-service)
- [Private Endpoints for Storage Accounts](https://docs.microsoft.com/en-us/azure/storage/common/storage-private-endpoints)
- [Azure Private DNS Zones](https://docs.microsoft.com/en-us/azure/dns/private-dns-overview)
- [Terraform AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.42.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_servicebus_private_endpoint"></a> [servicebus\_private\_endpoint](#module\_servicebus\_private\_endpoint) | ../../ | n/a |
| <a name="module_storage_private_endpoints"></a> [storage\_private\_endpoints](#module\_storage\_private\_endpoints) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_private_dns_zone.blob](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone.file](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone.servicebus](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.blob](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_dns_zone_virtual_network_link.file](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_dns_zone_virtual_network_link.servicebus](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_servicebus_namespace.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace) | resource |
| [azurerm_storage_account.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subnet.private_endpoints](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |
| [azurerm_virtual_network.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_private_endpoint_subnet_name"></a> [private\_endpoint\_subnet\_name](#input\_private\_endpoint\_subnet\_name) | Name of the existing subnet for private endpoints | `string` | `"snet-private-endpoints-example-prod-eastus-001"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the existing resource group | `string` | `"rg-example-prod-eastus-001"` | no |
| <a name="input_servicebus_namespace_name"></a> [servicebus\_namespace\_name](#input\_servicebus\_namespace\_name) | Name of the Service Bus namespace to create (must be globally unique) | `string` | `"sb-example-pe-complete-001"` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Name of the storage account to create (must be globally unique) | `string` | `"stexamplepecomplete001"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | <pre>{<br/>  "CostCenter": "engineering",<br/>  "Environment": "prod",<br/>  "Example": "complete",<br/>  "ManagedBy": "terraform",<br/>  "Owner": "platform-team",<br/>  "Project": "private-endpoint-example"<br/>}</pre> | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | Name of the existing virtual network | `string` | `"vnet-example-prod-eastus-001"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_dns_zone_ids"></a> [private\_dns\_zone\_ids](#output\_private\_dns\_zone\_ids) | IDs of the created private DNS zones |
| <a name="output_private_dns_zone_names"></a> [private\_dns\_zone\_names](#output\_private\_dns\_zone\_names) | Names of the created private DNS zones |
| <a name="output_private_endpoint_subnet_id"></a> [private\_endpoint\_subnet\_id](#output\_private\_endpoint\_subnet\_id) | ID of the private endpoint subnet |
| <a name="output_servicebus_dns_configs"></a> [servicebus\_dns\_configs](#output\_servicebus\_dns\_configs) | DNS configurations for the Service Bus private endpoint |
| <a name="output_servicebus_namespace_id"></a> [servicebus\_namespace\_id](#output\_servicebus\_namespace\_id) | ID of the created Service Bus namespace |
| <a name="output_servicebus_namespace_name"></a> [servicebus\_namespace\_name](#output\_servicebus\_namespace\_name) | Name of the created Service Bus namespace |
| <a name="output_servicebus_private_endpoint_id"></a> [servicebus\_private\_endpoint\_id](#output\_servicebus\_private\_endpoint\_id) | ID of the Service Bus private endpoint |
| <a name="output_servicebus_private_endpoint_ip"></a> [servicebus\_private\_endpoint\_ip](#output\_servicebus\_private\_endpoint\_ip) | Private IP address of the Service Bus private endpoint |
| <a name="output_servicebus_private_service_connection"></a> [servicebus\_private\_service\_connection](#output\_servicebus\_private\_service\_connection) | Private service connection details for Service Bus |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | ID of the created storage account |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | Name of the created storage account |
| <a name="output_storage_dns_configs"></a> [storage\_dns\_configs](#output\_storage\_dns\_configs) | DNS configurations for the storage account private endpoints |
| <a name="output_storage_private_endpoint_ids"></a> [storage\_private\_endpoint\_ids](#output\_storage\_private\_endpoint\_ids) | IDs of the storage account private endpoints |
| <a name="output_storage_private_endpoint_ips"></a> [storage\_private\_endpoint\_ips](#output\_storage\_private\_endpoint\_ips) | Private IP addresses of the storage account private endpoints |
| <a name="output_storage_private_service_connections"></a> [storage\_private\_service\_connections](#output\_storage\_private\_service\_connections) | Private service connection details for storage account |
| <a name="output_virtual_network_id"></a> [virtual\_network\_id](#output\_virtual\_network\_id) | ID of the virtual network |
<!-- END_TF_DOCS -->
