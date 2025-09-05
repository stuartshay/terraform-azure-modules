# Basic Private Endpoint Example

This example demonstrates how to use the private endpoint module to create a simple private endpoint for an Azure Storage Account.

## Overview

This example creates:
- An Azure Storage Account with public network access disabled
- A private endpoint for the storage account's blob service
- Connection to an existing virtual network and subnet

## Prerequisites

Before running this example, ensure you have:

1. **Existing Infrastructure**: 
   - Resource group
   - Virtual network
   - Subnet designated for private endpoints

2. **Azure CLI or PowerShell**: Authenticated and configured
3. **Terraform**: Version >= 1.5 installed

## Usage

1. **Clone the repository** and navigate to this example:
   ```bash
   cd modules/private-endpoint/examples/basic
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
resource_group_name    = "rg-myproject-dev-eastus-001"
virtual_network_name   = "vnet-myproject-dev-eastus-001"
subnet_name           = "snet-private-endpoints-myproject-dev-eastus-001"
storage_account_name  = "stmyprojectpebasic001"  # Must be globally unique
```

### Example terraform.tfvars

```hcl
resource_group_name   = "rg-example-dev-eastus-001"
virtual_network_name  = "vnet-example-dev-eastus-001"
subnet_name          = "snet-private-endpoints-example-dev-eastus-001"
storage_account_name = "stexamplepebasic001"

tags = {
  Environment = "dev"
  Project     = "private-endpoint-example"
  Owner       = "platform-team"
  CostCenter  = "engineering"
}
```

## What This Example Creates

### Resources Created

1. **Storage Account** (`azurerm_storage_account.example`)
   - Standard LRS storage account
   - Public network access disabled
   - Tagged according to your configuration

2. **Private Endpoint** (via module)
   - Connected to the storage account's blob service
   - Deployed in your specified subnet
   - Named following the pattern: `pe-{storage-account-name}-blob`

### Network Configuration

- The private endpoint is created in your existing subnet
- The storage account's public network access is disabled
- Traffic flows privately through the Azure backbone network

## Outputs

After successful deployment, you'll see outputs including:

- `storage_account_id`: Resource ID of the created storage account
- `private_endpoint_id`: Resource ID of the private endpoint
- `private_ip_address`: Private IP address assigned to the endpoint
- `custom_dns_configs`: DNS configuration for private resolution

## Testing the Private Endpoint

After deployment, you can test the private endpoint:

1. **From a VM in the same VNet**:
   ```bash
   # Test DNS resolution
   nslookup mystorageaccount.blob.core.windows.net
   
   # Should resolve to a private IP (10.x.x.x)
   ```

2. **Using Azure CLI**:
   ```bash
   # List private endpoints
   az network private-endpoint list --resource-group rg-example-dev-eastus-001
   
   # Show private endpoint details
   az network private-endpoint show --name pe-stexamplepebasic001-blob --resource-group rg-example-dev-eastus-001
   ```

## Security Considerations

- The storage account has public network access disabled
- Access is only possible through the private endpoint
- Ensure your subnet has appropriate Network Security Group rules
- Consider implementing private DNS zones for proper name resolution

## Troubleshooting

### Common Issues

1. **Storage account name already exists**:
   - Storage account names must be globally unique
   - Try a different name in the `storage_account_name` variable

2. **Subnet not found**:
   - Verify the subnet exists in the specified VNet
   - Check the subnet name spelling and casing

3. **Insufficient permissions**:
   - Ensure you have Contributor access to the resource group
   - Verify Network Contributor permissions for VNet operations

### Validation Commands

```bash
# Verify resources exist
terraform state list

# Check private endpoint status
az network private-endpoint show --name pe-stexamplepebasic001-blob --resource-group rg-example-dev-eastus-001 --query "connectionState"

# Test connectivity (from a VM in the VNet)
curl -I https://stexamplepebasic001.blob.core.windows.net
```

## Next Steps

After successfully running this basic example:

1. **Explore the complete example**: See `../complete/` for advanced features
2. **Add DNS integration**: Configure private DNS zones for better name resolution
3. **Implement monitoring**: Add diagnostic settings and alerts
4. **Scale the solution**: Create multiple private endpoints for different services

## Related Documentation

- [Azure Private Endpoints Overview](https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-overview)
- [Private Endpoints for Storage Accounts](https://docs.microsoft.com/en-us/azure/storage/common/storage-private-endpoints)
- [Terraform AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.13.1 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.42.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.42.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_storage_private_endpoint"></a> [storage\_private\_endpoint](#module\_storage\_private\_endpoint) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_storage_account.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subnet.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |
| [azurerm_virtual_network.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the existing resource group | `string` | `"rg-example-dev-eastus-001"` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Name of the storage account to create (must be globally unique) | `string` | `"stexamplepebasic001"` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | Name of the existing subnet for private endpoints | `string` | `"snet-private-endpoints-example-dev-eastus-001"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | <pre>{<br/>  "Environment": "dev",<br/>  "Example": "basic",<br/>  "ManagedBy": "terraform",<br/>  "Project": "private-endpoint-example"<br/>}</pre> | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | Name of the existing virtual network | `string` | `"vnet-example-dev-eastus-001"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_custom_dns_configs"></a> [custom\_dns\_configs](#output\_custom\_dns\_configs) | Custom DNS configurations for the private endpoint |
| <a name="output_network_interface"></a> [network\_interface](#output\_network\_interface) | Network interface details of the private endpoint |
| <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id) | ID of the created private endpoint |
| <a name="output_private_endpoint_name"></a> [private\_endpoint\_name](#output\_private\_endpoint\_name) | Name of the created private endpoint |
| <a name="output_private_ip_address"></a> [private\_ip\_address](#output\_private\_ip\_address) | Private IP address of the private endpoint |
| <a name="output_private_service_connection"></a> [private\_service\_connection](#output\_private\_service\_connection) | Private service connection details |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | ID of the created storage account |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | Name of the created storage account |
<!-- END_TF_DOCS -->
