# Complete Enhanced Storage Account Example

This example demonstrates all the new storage account module features including:

## Features Demonstrated

### 1. Enhanced Diagnostics
- Separate diagnostic settings for blob, file, queue, and table services
- StorageRead, StorageWrite, and StorageDelete log categories enabled
- 30-day retention policy for diagnostic logs
- Log Analytics workspace integration

### 2. Blob Versioning and Data Protection
- Blob versioning enabled by default
- Change feed enabled with 30-day retention
- Blob soft delete with 14-day retention
- Container soft delete with 7-day retention

### 3. Container Immutability Policies
- Immutability policies applied to `audit` and `compliance` containers
- 30-day immutability period for compliance requirements
- Write-once-read-many (WORM) protection

### 4. SAS Token and Key Vault Integration
- SAS token generation with configurable permissions
- Token stored securely in Azure Key Vault
- 24-hour TTL with HTTPS-only restrictions
- Supports blob, queue, table, and file services

### 5. Security Best Practices
- HTTPS-only traffic enforcement
- TLS 1.2 minimum version
- Public network access disabled
- Private access only for blob containers

## Resources Created

- **Resource Group**: Contains all example resources
- **Log Analytics Workspace**: For diagnostic log collection
- **Key Vault**: For secure SAS token storage
- **Storage Account**: With all enhanced features enabled
- **Blob Containers**: Including immutable containers for compliance
- **File Shares**: For shared storage scenarios
- **Queues**: For messaging workloads
- **Tables**: For NoSQL storage

## Usage

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply
```

## Outputs

The example provides comprehensive outputs including:
- Storage account details and endpoints
- Diagnostic setting IDs for each service
- Blob versioning status
- Key Vault secret ID for SAS token
- Security and compliance summary

## Configuration Highlights

### Diagnostics Configuration
```hcl
enable_diagnostics         = true
diagnostics_retention_days = 30
log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
```

### Data Protection Configuration
```hcl
enable_blob_versioning          = true
enable_change_feed              = true
blob_delete_retention_days      = 14
container_delete_retention_days = 7
```

### Container Immutability
```hcl
enable_container_immutability = true
container_immutability_days   = 30
immutable_containers          = ["audit", "compliance"]
```

### SAS Token Integration
```hcl
enable_sas_secret     = true
key_vault_id          = azurerm_key_vault.example.id
key_vault_secret_name = "storage-sas-token"
sas_ttl_hours         = 24
```

## Security Notes

- All containers use private access only (enforced by module)
- Public network access is disabled for enhanced security
- SAS tokens are stored securely in Key Vault (never exposed in outputs)
- Diagnostic logs provide comprehensive audit trail
- Immutability policies ensure data integrity for compliance containers

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
| <a name="module_storage_account_enhanced"></a> [storage\_account\_enhanced](#module\_storage\_account\_enhanced) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_log_analytics_workspace.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_container_immutability_days"></a> [container\_immutability\_days](#input\_container\_immutability\_days) | Number of days for container immutability policy | `number` | `30` | no |
| <a name="input_diagnostics_retention_days"></a> [diagnostics\_retention\_days](#input\_diagnostics\_retention\_days) | Number of days to retain diagnostic logs | `number` | `30` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | `"dev"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for resources | `string` | `"East US"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group (leave empty to create a new one) | `string` | `""` | no |
| <a name="input_sas_ttl_hours"></a> [sas\_ttl\_hours](#input\_sas\_ttl\_hours) | SAS token time-to-live in hours | `number` | `24` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_blob_container_names"></a> [blob\_container\_names](#output\_blob\_container\_names) | Map of blob container keys to their actual names |
| <a name="output_blob_versioning_enabled"></a> [blob\_versioning\_enabled](#output\_blob\_versioning\_enabled) | Whether blob versioning is enabled |
| <a name="output_diagnostic_setting_ids"></a> [diagnostic\_setting\_ids](#output\_diagnostic\_setting\_ids) | Map of diagnostic setting IDs for each storage service |
| <a name="output_key_vault_id"></a> [key\_vault\_id](#output\_key\_vault\_id) | ID of the Key Vault for SAS token storage |
| <a name="output_key_vault_sas_secret_id"></a> [key\_vault\_sas\_secret\_id](#output\_key\_vault\_sas\_secret\_id) | ID of the Key Vault secret containing the SAS token |
| <a name="output_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#output\_log\_analytics\_workspace\_id) | ID of the Log Analytics workspace for diagnostics |
| <a name="output_primary_blob_endpoint"></a> [primary\_blob\_endpoint](#output\_primary\_blob\_endpoint) | Primary blob endpoint |
| <a name="output_primary_file_endpoint"></a> [primary\_file\_endpoint](#output\_primary\_file\_endpoint) | Primary file endpoint |
| <a name="output_primary_queue_endpoint"></a> [primary\_queue\_endpoint](#output\_primary\_queue\_endpoint) | Primary queue endpoint |
| <a name="output_primary_table_endpoint"></a> [primary\_table\_endpoint](#output\_primary\_table\_endpoint) | Primary table endpoint |
| <a name="output_security_summary"></a> [security\_summary](#output\_security\_summary) | Summary of security and compliance features |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | ID of the created storage account |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | Name of the created storage account |
<!-- END_TF_DOCS -->
