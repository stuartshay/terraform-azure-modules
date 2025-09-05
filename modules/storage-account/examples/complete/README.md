# Complete Storage Account Example

This example demonstrates the full capabilities of the storage-account module with all features enabled and configured for a production environment.

## Features

- **GRS Storage Account** with enterprise-grade configuration
- **Data Lake Gen2** enabled for big data analytics
- **Private Endpoints** for secure network access
- **Static Website** hosting capability
- **Lifecycle Management** for cost optimization
- **Advanced Security** with encryption and access controls
- **Comprehensive Monitoring** with diagnostic settings
- **Multiple Storage Services** (Blobs, Files, Queues, Tables)

## Architecture

This example creates:

- Resource Group with Log Analytics workspace
- Virtual Network with private endpoint subnet
- Storage Account with all advanced features
- Multiple blob containers, file shares, queues, and tables
- Private endpoints for blob, file, and DFS services
- Lifecycle management policies
- Diagnostic settings for monitoring

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

## What This Example Creates

### Infrastructure
- Resource Group: `rg-storage-complete-example`
- Virtual Network: `vnet-storage-example` (10.0.0.0/16)
- Subnet: `snet-private-endpoints` (10.0.1.0/24)
- Log Analytics Workspace: `law-storage-example`

### Storage Account
- Name: `stexampleprodeastus001`
- Type: Standard GRS StorageV2
- Features: Data Lake Gen2, Large File Share, Infrastructure Encryption

### Storage Services
- **Blob Containers**: documents, backups, logs
- **File Shares**: shared (100GB Hot), backup (500GB Cool)
- **Queues**: notifications, processing, deadletter
- **Tables**: users, sessions, audit

### Security & Networking
- Private endpoints for blob, file, and DFS services
- Network rules restricting public access
- HTTPS-only with TLS 1.2 minimum
- System-assigned managed identity
- Azure AD authentication for file shares

### Monitoring & Compliance
- Diagnostic settings with Log Analytics integration
- Lifecycle management for cost optimization
- Blob versioning and change feed
- Soft delete policies
- Immutability policies

## Configuration Highlights

### Security
- **Encryption**: Infrastructure encryption enabled
- **Network Access**: Private endpoints only, public access denied
- **Authentication**: Azure AD integration, system-assigned identity
- **TLS**: Minimum version 1.2, HTTPS-only traffic

### Data Protection
- **Soft Delete**: 30 days for blobs and containers
- **Versioning**: Enabled for blob data
- **Change Feed**: 30-day retention for audit trails
- **Immutability**: 30-day retention policy

### Cost Optimization
- **Lifecycle Rules**: Automatic tiering and deletion
- **Access Tiers**: Hot for active data, Cool for backups
- **Replication**: GRS for disaster recovery

### Monitoring
- **Diagnostic Logs**: Read, Write, Delete operations
- **Metrics**: Transaction and Capacity monitoring
- **Log Analytics**: Centralized logging and analysis

## Outputs

This example provides comprehensive outputs including:

- Storage account details and endpoints
- Container, share, queue, and table information
- Private endpoint details and IP addresses
- Security and compliance summaries
- Cost optimization recommendations
- Connectivity information for integration

## Security Considerations

This configuration implements enterprise security best practices:

1. **Network Isolation**: Private endpoints with denied public access
2. **Encryption**: Infrastructure encryption and HTTPS-only
3. **Access Control**: Azure AD authentication and managed identity
4. **Monitoring**: Comprehensive logging and alerting
5. **Data Protection**: Versioning, soft delete, and immutability

## Cost Considerations

This configuration includes cost optimization features:

1. **Lifecycle Management**: Automatic data tiering and cleanup
2. **Access Tiers**: Appropriate tiers for different use cases
3. **Monitoring**: Usage tracking for optimization opportunities

## Integration Examples

This storage account can be integrated with other Azure services:

```hcl
# App Service integration
resource "azurerm_app_service" "example" {
  # ... other configuration
  
  app_settings = {
    "STORAGE_CONNECTION_STRING" = module.storage_account.primary_connection_string
    "STORAGE_ACCOUNT_NAME"      = module.storage_account.storage_account_name
  }
}

# Function App integration
resource "azurerm_function_app" "example" {
  # ... other configuration
  
  storage_account_name       = module.storage_account.storage_account_name
  storage_account_access_key = module.storage_account.primary_access_key
}
```

## Clean Up

To remove all resources created by this example:

```bash
terraform destroy
```

**Note**: This will permanently delete all data in the storage account.

## Next Steps

- Review the [module documentation](../../README.md) for detailed configuration options
- Explore the [basic example](../basic/) for simpler use cases
- Consider implementing additional security measures like customer-managed keys
- Set up monitoring alerts based on the diagnostic data

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.13.1 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.42.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.41.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_storage_account"></a> [storage\_account](#module\_storage\_account) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_log_analytics_workspace.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.private_endpoints](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_blob_container_names"></a> [blob\_container\_names](#output\_blob\_container\_names) | Names of the created blob containers |
| <a name="output_compliance_info"></a> [compliance\_info](#output\_compliance\_info) | Compliance and governance information |
| <a name="output_connectivity_info"></a> [connectivity\_info](#output\_connectivity\_info) | Connectivity information |
| <a name="output_cost_optimization_info"></a> [cost\_optimization\_info](#output\_cost\_optimization\_info) | Cost optimization information |
| <a name="output_file_share_names"></a> [file\_share\_names](#output\_file\_share\_names) | Names of the created file shares |
| <a name="output_identity"></a> [identity](#output\_identity) | Managed identity information |
| <a name="output_primary_blob_endpoint"></a> [primary\_blob\_endpoint](#output\_primary\_blob\_endpoint) | Primary blob endpoint of the storage account |
| <a name="output_primary_dfs_endpoint"></a> [primary\_dfs\_endpoint](#output\_primary\_dfs\_endpoint) | Primary DFS endpoint (Data Lake Gen2) |
| <a name="output_primary_web_endpoint"></a> [primary\_web\_endpoint](#output\_primary\_web\_endpoint) | Primary web endpoint (Static Website) |
| <a name="output_private_endpoint_ids"></a> [private\_endpoint\_ids](#output\_private\_endpoint\_ids) | IDs of the created private endpoints |
| <a name="output_private_endpoint_ips"></a> [private\_endpoint\_ips](#output\_private\_endpoint\_ips) | Private IP addresses of the private endpoints |
| <a name="output_queue_names"></a> [queue\_names](#output\_queue\_names) | Names of the created queues |
| <a name="output_security_summary"></a> [security\_summary](#output\_security\_summary) | Summary of security configuration |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | ID of the created storage account |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | Name of the created storage account |
| <a name="output_storage_account_summary"></a> [storage\_account\_summary](#output\_storage\_account\_summary) | Summary of storage account configuration |
| <a name="output_table_names"></a> [table\_names](#output\_table\_names) | Names of the created tables |
<!-- END_TF_DOCS -->
