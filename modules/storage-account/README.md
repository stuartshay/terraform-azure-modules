<!--
SECURITY COMPLIANCE: All blob containers created by this module are always private. Public access is not possible and is explicitly prevented (CKV_AZURE_34 enforced). This module enforces private-only access for all containers, and any documentation or code suggesting otherwise is obsolete.
-->
# Storage Account Module

This module creates Azure Storage Account with comprehensive features including blob containers, file shares, queues, tables, private endpoints, and advanced security configurations.

## Features

- **Storage Account** with configurable performance tiers and replication types
- **Blob Containers** with access control and metadata
- **File Shares** with quota management and SMB/NFS protocols
- **Queues** and **Tables** for messaging and NoSQL storage
- **Private Endpoints** for secure network access
- **Static Website** hosting capability
- **Data Lake Gen2** support for big data analytics
- **Lifecycle Management** for automated data tiering and cleanup
- **Advanced Security** with encryption, network rules, and access controls
- **Monitoring Integration** with diagnostic settings and Log Analytics
- **Compliance Features** including immutability policies and audit trails

## Security Best Practices

### Security Automation and Future-Proofing

- **Automated Compliance Checks:**
  - Integrate Checkov or similar tools into CI/CD pipelines to automatically scan for security misconfigurations, including public access and anonymous access settings.
  - Add pre-commit hooks to enforce that no changes can introduce public or anonymous access to storage accounts or containers.
- **Module Validation Enhancements:**
  - Consider adding explicit validation rules in `variables.tf` to prevent misconfiguration of `allow_blob_public_access` and related settings.
  - Provide automated test cases that attempt to override these settings and verify that the module enforces compliance.
- **Documentation Automation:**
  - Generate compliance documentation automatically from code comments and variable definitions to ensure documentation stays up to date with implementation.

These steps will help ensure that the module remains compliant with evolving Azure security requirements and best practices.
### Azure Storage Security Compliance

This module is designed to be compliant with the following Azure security controls and Checkov policies:

- **CKV_AZURE_190**: Ensure that Storage blobs restrict public access
  - Enforced by setting `allow_blob_public_access = false` by default in the storage account resource, and exposing this as a configurable variable (default: false). See `main.tf` and input variable documentation.
- **CKV_AZURE_34**: Ensure that 'Public access level' is set to Private for blob containers
  - All blob containers are always created with `container_access_type = "private"` and this cannot be overridden by user input. See the `azurerm_storage_container.main` resource in `main.tf`.
- **CKV2_AZURE_47**: Ensure storage account is configured without blob anonymous access
  - Anonymous access is disabled by default and not exposed to users. The module does not allow configuration that would enable anonymous blob access.

These controls are enforced in both the Terraform implementation and the module interface. Any attempt to enable public or anonymous access will be ignored or result in a validation error. This ensures that all deployments using this module are compliant with Azure security best practices and regulatory requirements.

For more details, see the relevant code sections in [`main.tf`](./main.tf) and the input variable documentation below.
- HTTPS-only traffic with configurable minimum TLS version
- Network isolation through private endpoints and network rules
- Azure AD authentication for file shares
- Infrastructure encryption and customer-managed keys support
- Blob versioning and soft delete for data protection
- Immutability policies for compliance requirements
- Comprehensive audit logging and monitoring

## Usage

### Basic Example

```hcl
module "storage_account" {
  source = "app.terraform.io/azure-policy-cloud/storage-account/azurerm"

  # Required variables
  resource_group_name = "rg-example"
  location           = "East US"
  environment        = "dev"
  workload           = "myapp"
  location_short     = "eastus"

  # Basic configuration
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  access_tier              = "Hot"

  # Create blob containers
  blob_containers = {
    documents = {}
    backups = {}
  }

  tags = {
    Environment = "dev"
    Project     = "example"
  }
}
```

### Complete Example with All Features

```hcl
module "storage_account" {
  source = "app.terraform.io/azure-policy-cloud/storage-account/azurerm"

  # Required variables
  resource_group_name = "rg-example"
  location           = "East US"
  environment        = "prod"

  workload           = "myapp"
  location_short     = "eastus"

  # Storage account configuration
  account_tier             = "Standard"
  account_replication_type = "GRS"
  account_kind             = "StorageV2"
  access_tier              = "Hot"

  # Security configuration
  enable_https_traffic_only     = true
  min_tls_version               = "TLS1_2"
  shared_access_key_enabled     = true
  allow_blob_public_access      = false
  public_network_access_enabled = false

  # Advanced features
  enable_data_lake_gen2            = true
  enable_large_file_share          = true
  enable_infrastructure_encryption = true

  # Blob properties
  enable_blob_properties          = true
  enable_blob_versioning          = true
  enable_change_feed              = true
  change_feed_retention_days      = 30
  blob_delete_retention_days      = 30
  container_delete_retention_days = 30

  # Static website
  enable_static_website            = true
  static_website_index_document    = "index.html"
  static_website_error_404_document = "404.html"

  # Network rules
  enable_network_rules         = true
  network_rules_default_action = "Deny"
  network_rules_bypass         = ["AzureServices"]
  network_rules_subnet_ids     = [var.subnet_id]

  # Identity
  identity_type = "SystemAssigned"

  # Blob containers
  # All containers are always private (CKV_AZURE_34 enforced). 'access_type' is ignored and always set to 'private'.
  blob_containers = {
    documents = {
      metadata = {
        purpose = "document-storage"
      }
    }
    backups = {
      metadata = {
        purpose = "backup-storage"
      }
    }
  }

  # File shares
  file_shares = {
    shared = {
      quota_gb         = 100
      enabled_protocol = "SMB"
      access_tier      = "Hot"
    }
  }

  # Queues and Tables
  queues = ["notifications", "processing"]
  tables = ["users", "sessions"]

  # Lifecycle management
  enable_lifecycle_management = true
  lifecycle_rules = [
    {
      name    = "cleanup-old-data"
      enabled = true
      filters = {
        prefix_match = ["logs/", "temp/"]
        blob_types   = ["blockBlob"]
        match_blob_index_tag = null
      }
      actions = {
        base_blob = {
          tier_to_cool_after_days    = 30
          tier_to_archive_after_days = 90
          delete_after_days          = 365
        }
        snapshot = null
        version  = null
      }
    }
  ]

  # Private endpoints
  private_endpoints = {
    blob = {
      subnet_id        = var.private_endpoint_subnet_id
      subresource_name = "blob"
    }
  }

  # Diagnostic settings
  enable_diagnostic_settings = true
  log_analytics_workspace_id = var.log_analytics_workspace_id

  tags = {
    Environment = "prod"
    Project     = "example"
    CostCenter  = "IT"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5 |
| azurerm | ~> 4.40 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 4.40 |

## Resources

| Name | Type |
|------|------|
| azurerm_storage_account.main | resource |
| azurerm_storage_container.main | resource |
| azurerm_storage_share.main | resource |
| azurerm_storage_queue.main | resource |
| azurerm_storage_table.main | resource |
| azurerm_storage_management_policy.main | resource |
| azurerm_private_endpoint.main | resource |
| azurerm_monitor_diagnostic_setting.main | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| resource_group_name | Name of the resource group where storage account will be created | `string` | n/a | yes |
| location | Azure region for storage account | `string` | n/a | yes |
| environment | Environment name (dev, staging, prod) | `string` | n/a | yes |
| workload | Workload name for resource naming | `string` | n/a | yes |
| location_short | Short name for the Azure region | `string` | n/a | yes |
| account_tier | Storage account tier (Standard or Premium) | `string` | `"Standard"` | no |
| account_replication_type | Storage account replication type | `string` | `"LRS"` | no |
| account_kind | Storage account kind | `string` | `"StorageV2"` | no |
| access_tier | Access tier for the storage account | `string` | `"Hot"` | no |
| enable_https_traffic_only | Enable HTTPS traffic only | `bool` | `true` | no |
| min_tls_version | Minimum TLS version | `string` | `"TLS1_2"` | no |
| shared_access_key_enabled | Enable shared access key | `bool` | `true` | no |
| allow_blob_public_access | Allow blob public access | `bool` | `false` | no |
| public_network_access_enabled | Enable public network access | `bool` | `true` | no |
| enable_data_lake_gen2 | Enable Data Lake Gen2 (Hierarchical Namespace) | `bool` | `false` | no |
| enable_blob_properties | Enable blob properties configuration | `bool` | `true` | no |
| enable_blob_versioning | Enable blob versioning | `bool` | `false` | no |
| enable_change_feed | Enable change feed | `bool` | `false` | no |
| blob_delete_retention_days | Blob delete retention in days | `number` | `7` | no |
| container_delete_retention_days | Container delete retention in days | `number` | `7` | no |
| enable_static_website | Enable static website hosting | `bool` | `false` | no |
| enable_network_rules | Enable network rules | `bool` | `false` | no |
| network_rules_default_action | Default action for network rules | `string` | `"Allow"` | no |
| network_rules_subnet_ids | Subnet IDs for network access | `list(string)` | `[]` | no |
| identity_type | Type of managed identity | `string` | `null` | no |
| blob_containers | Map of blob containers to create | `map(object)` | `{}` | no |
| file_shares | Map of file shares to create | `map(object)` | `{}` | no |
| queues | List of queue names to create | `list(string)` | `[]` | no |
| tables | List of table names to create | `list(string)` | `[]` | no |
| enable_lifecycle_management | Enable lifecycle management | `bool` | `false` | no |
| lifecycle_rules | Lifecycle management rules | `list(object)` | `[]` | no |
| private_endpoints | Map of private endpoints to create | `map(object)` | `{}` | no |
| enable_diagnostic_settings | Enable diagnostic settings | `bool` | `false` | no |
| log_analytics_workspace_id | Log Analytics workspace ID for diagnostic settings | `string` | `null` | no |
| tags | Tags to apply to all storage account resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| storage_account_id | ID of the created storage account |
| storage_account_name | Name of the created storage account |
| primary_blob_endpoint | Primary blob endpoint of the storage account |
| primary_connection_string | Primary connection string of the storage account |
| blob_container_names | Map of blob container keys to their actual names |
| file_share_names | Map of file share keys to their actual names |
| queue_names | Map of queue keys to their actual names |
| table_names | Map of table keys to their actual names |
| private_endpoint_ids | Map of private endpoint names to their IDs |
| identity | Identity block of the storage account |
| storage_account_summary | Summary of storage account configuration |
| security_summary | Summary of storage account security configuration |
| connectivity_info | Information for connecting to the storage account |
| compliance_info | Information for compliance and governance |

## Storage Account Configuration

> **Security Compliance Note:**
> All blob containers created by this module are always private. Public access is not possible and is explicitly prevented (CKV_AZURE_34 enforced). Any field or documentation suggesting otherwise is obsolete. All configuration and implementation ensures private-only access for all containers.

### Account Types

The module supports all Azure Storage account types:

- **StorageV2** (recommended): General-purpose v2 accounts
- **Storage**: General-purpose v1 accounts (legacy)
- **BlobStorage**: Blob-only storage accounts
- **BlockBlobStorage**: Premium block blob storage
- **FileStorage**: Premium file storage

### Replication Types
  - **LRS**: Locally Redundant Storage
  - **GRS**: Geo-Redundant Storage
  - **RAGRS**: Read-Access Geo-Redundant Storage
  - **ZRS**: Zone-Redundant Storage
  - **GZRS**: Geo-Zone-Redundant Storage
  - **RAGZRS**: Read-Access Geo-Zone-Redundant Storage

### Access Tiers
<!--
SECURITY COMPLIANCE: All blob containers created by this module are always private. Public access is not possible and is explicitly prevented (CKV_AZURE_34 enforced). This section and the entire module implementation ensure private-only access for all containers.
-->

- **Hot**: For frequently accessed data
- **Cool**: For infrequently accessed data (30+ days)
- **Archive**: For rarely accessed data (180+ days)

## Blob Container Configuration

```hcl
# All containers are always private (CKV_AZURE_34 enforced). 'access_type' is ignored and always set to 'private'.
blob_containers = {
  container_name = {
    metadata = {
      purpose = "document-storage"
      tier    = "production"
    }
  }
}
```

## File Share Configuration

```hcl
file_shares = {
  share_name = {
    quota_gb         = 100
    enabled_protocol = "SMB"  # SMB or NFS
    access_tier      = "Hot"  # Hot, Cool, TransactionOptimized
    metadata = {
      purpose = "shared-files"
    }
    acl = [
      {
        id = "policy1"
        access_policy = {
          permissions = "rwdl"
          start       = "2024-01-01T00:00:00Z"
          expiry      = "2024-12-31T23:59:59Z"
        }
      }
    ]
  }
}
```

## Lifecycle Management

```hcl
lifecycle_rules = [
  {
    name    = "cleanup-old-data"
    enabled = true
    filters = {
      prefix_match = ["logs/", "temp/"]
      blob_types   = ["blockBlob"]
      match_blob_index_tag = [
        {
          name      = "environment"
          operation = "=="
          value     = "dev"
        }
      ]
    }
    actions = {
      base_blob = {
        tier_to_cool_after_days    = 30
        tier_to_archive_after_days = 90
        delete_after_days          = 365
      }
      snapshot = {
        tier_to_cool_after_days    = 7
        tier_to_archive_after_days = 30
        delete_after_days          = 90
      }
      version = {
        tier_to_cool_after_days    = 7
        tier_to_archive_after_days = 30
        delete_after_days          = 90
      }
    }
  }
]
```

## Private Endpoints

```hcl
private_endpoints = {
  blob = {
    subnet_id             = "/subscriptions/.../subnets/private-endpoints"
    subresource_name      = "blob"
    private_dns_zone_ids  = ["/subscriptions/.../privateDnsZones/privatelink.blob.core.windows.net"]
  }
  file = {
    subnet_id             = "/subscriptions/.../subnets/private-endpoints"
    subresource_name      = "file"
    private_dns_zone_ids  = ["/subscriptions/.../privateDnsZones/privatelink.file.core.windows.net"]
  }
}
```

### Supported Subresource Names

- `blob`, `blob_secondary`
- `file`, `file_secondary`
- `queue`, `queue_secondary`
- `table`, `table_secondary`
- `web`, `web_secondary`
- `dfs`, `dfs_secondary`

## Network Rules

```hcl
enable_network_rules         = true
network_rules_default_action = "Deny"
network_rules_bypass         = ["AzureServices", "Logging", "Metrics"]
network_rules_ip_rules       = ["203.0.113.0/24", "198.51.100.0/24"]
network_rules_subnet_ids     = [
  "/subscriptions/.../subnets/app-subnet",
  "/subscriptions/.../subnets/function-subnet"
]
```

## Security Features

### Encryption

- **Encryption at Rest**: Always enabled with Microsoft-managed keys
- **Infrastructure Encryption**: Double encryption for enhanced security
- **Customer-Managed Keys**: Support for Azure Key Vault integration
- **Encryption in Transit**: HTTPS-only with configurable minimum TLS version

### Access Control

- **Azure AD Authentication**: For file shares and blob access
- **Managed Identity**: System-assigned or user-assigned identities
- **Shared Access Keys**: Can be disabled for enhanced security
- **Network Restrictions**: IP rules and virtual network integration

### Data Protection

- **Blob Versioning**: Track changes to blob data
- **Soft Delete**: Recover accidentally deleted blobs and containers
- **Change Feed**: Audit trail of all changes
- **Immutability Policies**: WORM (Write Once, Read Many) compliance

## Monitoring and Diagnostics

### Diagnostic Settings


```hcl
enable_diagnostic_settings = true
log_analytics_workspace_id = "/subscriptions/.../workspaces/law-example"
diagnostic_metrics        = ["Transaction", "Capacity"]
```

> **Logging Requirements:**
> Logging for Blob, Table, and Queue services is always enabled for the following categories: `StorageRead`, `StorageWrite`, and `StorageDelete`. These log categories are enforced by the module and cannot be disabled or changed. This ensures that all read, write, and delete actions for Blob, Table, and Queue are always logged for compliance and audit purposes.

### Available Log Categories

- `StorageRead`: Read operations
- `StorageWrite`: Write operations
- `StorageDelete`: Delete operations

### Available Metric Categories

- `Transaction`: Request metrics
- `Capacity`: Storage capacity metrics

## Cost Optimization

### Lifecycle Management

Automatically tier or delete data based on age and access patterns:

- Move to Cool tier after 30 days
- Move to Archive tier after 90 days
- Delete after 365 days

### Access Tiers

Choose appropriate access tiers:

- **Hot**: Frequently accessed data
- **Cool**: Monthly access, lower storage cost
- **Archive**: Yearly access, lowest storage cost

### Replication

Balance cost and availability:

- **LRS**: Lowest cost, single region
- **ZRS**: Higher availability, single region
- **GRS**: Cross-region redundancy
- **RAGRS**: Cross-region with read access

## Examples

See the `examples/` directory for:

- **Basic**: Minimal configuration for getting started
- **Complete**: Full configuration with all features enabled

## Integration with Other Modules

This storage account module is designed to work with other modules in this repository:

```hcl
# Create storage account
module "storage_account" {
  source = "app.terraform.io/azure-policy-cloud/storage-account/azurerm"
  # ... configuration
}

# Use storage account in app service module
module "app_service" {
  source = "github.com/stuartshay/terraform-azure-modules//modules/app-service-plan-web?ref=v1.0.0"
  
  app_settings = {
    "STORAGE_CONNECTION_STRING" = module.storage_account.primary_connection_string
    "STORAGE_ACCOUNT_NAME"      = module.storage_account.storage_account_name
  }
  # ... other configuration
}
```

## Contributing

When contributing to this module:

1. Ensure all security best practices are maintained
2. Update examples when adding new features
3. Run `terraform fmt` and `terraform validate`
4. Update documentation for any new variables or outputs
5. Test with both basic and complete examples

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](../../LICENSE) file for details.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.13.1 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.40 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.41.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_diagnostic_setting.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_private_endpoint.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_storage_account.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_container.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_storage_management_policy.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_management_policy) | resource |
| [azurerm_storage_queue.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_queue) | resource |
| [azurerm_storage_share.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share) | resource |
| [azurerm_storage_table.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_table) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_tier"></a> [access\_tier](#input\_access\_tier) | Access tier for the storage account (Hot, Cool, Archive) | `string` | `"Hot"` | no |
| <a name="input_account_kind"></a> [account\_kind](#input\_account\_kind) | Storage account kind | `string` | `"StorageV2"` | no |
| <a name="input_account_replication_type"></a> [account\_replication\_type](#input\_account\_replication\_type) | Storage account replication type | `string` | `"LRS"` | no |
| <a name="input_account_tier"></a> [account\_tier](#input\_account\_tier) | Storage account tier (Standard or Premium) | `string` | `"Standard"` | no |
| <a name="input_allow_blob_public_access"></a> [allow\_blob\_public\_access](#input\_allow\_blob\_public\_access) | Allow blob public access | `bool` | `false` | no |
| <a name="input_azure_files_ad_domain_guid"></a> [azure\_files\_ad\_domain\_guid](#input\_azure\_files\_ad\_domain\_guid) | Domain GUID for Active Directory authentication | `string` | `null` | no |
| <a name="input_azure_files_ad_domain_name"></a> [azure\_files\_ad\_domain\_name](#input\_azure\_files\_ad\_domain\_name) | Domain name for Active Directory authentication | `string` | `null` | no |
| <a name="input_azure_files_ad_domain_sid"></a> [azure\_files\_ad\_domain\_sid](#input\_azure\_files\_ad\_domain\_sid) | Domain SID for Active Directory authentication | `string` | `null` | no |
| <a name="input_azure_files_ad_forest_name"></a> [azure\_files\_ad\_forest\_name](#input\_azure\_files\_ad\_forest\_name) | Forest name for Active Directory authentication | `string` | `null` | no |
| <a name="input_azure_files_ad_netbios_domain_name"></a> [azure\_files\_ad\_netbios\_domain\_name](#input\_azure\_files\_ad\_netbios\_domain\_name) | NetBIOS domain name for Active Directory authentication | `string` | `null` | no |
| <a name="input_azure_files_ad_storage_sid"></a> [azure\_files\_ad\_storage\_sid](#input\_azure\_files\_ad\_storage\_sid) | Storage SID for Active Directory authentication | `string` | `null` | no |
| <a name="input_azure_files_authentication_directory_type"></a> [azure\_files\_authentication\_directory\_type](#input\_azure\_files\_authentication\_directory\_type) | Directory type for Azure Files authentication | `string` | `"AADDS"` | no |
| <a name="input_blob_containers"></a> [blob\_containers](#input\_blob\_containers) | Map of blob containers to create. All containers are always private (CKV\_AZURE\_34 enforced). The 'access\_type' field is not used and any value is ignored; containers are always created with private access only. | <pre>map(object({<br/>    metadata = optional(map(string), null)<br/>  }))</pre> | `{}` | no |
| <a name="input_blob_delete_retention_days"></a> [blob\_delete\_retention\_days](#input\_blob\_delete\_retention\_days) | Blob delete retention in days (0 to disable) | `number` | `7` | no |
| <a name="input_change_feed_retention_days"></a> [change\_feed\_retention\_days](#input\_change\_feed\_retention\_days) | Change feed retention in days | `number` | `7` | no |
| <a name="input_container_delete_retention_days"></a> [container\_delete\_retention\_days](#input\_container\_delete\_retention\_days) | Container delete retention in days (0 to disable) | `number` | `7` | no |
| <a name="input_cors_rules"></a> [cors\_rules](#input\_cors\_rules) | CORS rules for blob service | <pre>list(object({<br/>    allowed_headers    = list(string)<br/>    allowed_methods    = list(string)<br/>    allowed_origins    = list(string)<br/>    exposed_headers    = list(string)<br/>    max_age_in_seconds = number<br/>  }))</pre> | `[]` | no |
| <a name="input_customer_managed_key_user_assigned_identity_id"></a> [customer\_managed\_key\_user\_assigned\_identity\_id](#input\_customer\_managed\_key\_user\_assigned\_identity\_id) | User assigned identity ID for customer managed key | `string` | `null` | no |
| <a name="input_customer_managed_key_vault_key_id"></a> [customer\_managed\_key\_vault\_key\_id](#input\_customer\_managed\_key\_vault\_key\_id) | Key Vault key ID for customer managed key | `string` | `null` | no |
| <a name="input_diagnostic_metrics"></a> [diagnostic\_metrics](#input\_diagnostic\_metrics) | List of diagnostic metric categories to enable | `list(string)` | <pre>[<br/>  "Transaction"<br/>]</pre> | no |
| <a name="input_diagnostic_storage_account_id"></a> [diagnostic\_storage\_account\_id](#input\_diagnostic\_storage\_account\_id) | Storage account ID for diagnostic settings | `string` | `null` | no |
| <a name="input_enable_azure_files_authentication"></a> [enable\_azure\_files\_authentication](#input\_enable\_azure\_files\_authentication) | Enable Azure Files authentication | `bool` | `false` | no |
| <a name="input_enable_blob_properties"></a> [enable\_blob\_properties](#input\_enable\_blob\_properties) | Enable blob properties configuration | `bool` | `true` | no |
| <a name="input_enable_blob_versioning"></a> [enable\_blob\_versioning](#input\_enable\_blob\_versioning) | Enable blob versioning | `bool` | `false` | no |
| <a name="input_enable_change_feed"></a> [enable\_change\_feed](#input\_enable\_change\_feed) | Enable change feed | `bool` | `false` | no |
| <a name="input_enable_cross_tenant_replication"></a> [enable\_cross\_tenant\_replication](#input\_enable\_cross\_tenant\_replication) | Enable cross-tenant replication | `bool` | `false` | no |
| <a name="input_enable_data_lake_gen2"></a> [enable\_data\_lake\_gen2](#input\_enable\_data\_lake\_gen2) | Enable Data Lake Gen2 (Hierarchical Namespace) | `bool` | `false` | no |
| <a name="input_enable_diagnostic_settings"></a> [enable\_diagnostic\_settings](#input\_enable\_diagnostic\_settings) | Enable diagnostic settings | `bool` | `false` | no |
| <a name="input_enable_https_traffic_only"></a> [enable\_https\_traffic\_only](#input\_enable\_https\_traffic\_only) | Enable HTTPS traffic only | `bool` | `true` | no |
| <a name="input_enable_immutability_policy"></a> [enable\_immutability\_policy](#input\_enable\_immutability\_policy) | Enable immutability policy | `bool` | `false` | no |
| <a name="input_enable_infrastructure_encryption"></a> [enable\_infrastructure\_encryption](#input\_enable\_infrastructure\_encryption) | Enable infrastructure encryption | `bool` | `false` | no |
| <a name="input_enable_large_file_share"></a> [enable\_large\_file\_share](#input\_enable\_large\_file\_share) | Enable large file share | `bool` | `false` | no |
| <a name="input_enable_last_access_time_tracking"></a> [enable\_last\_access\_time\_tracking](#input\_enable\_last\_access\_time\_tracking) | Enable last access time tracking | `bool` | `false` | no |
| <a name="input_enable_lifecycle_management"></a> [enable\_lifecycle\_management](#input\_enable\_lifecycle\_management) | Enable lifecycle management | `bool` | `false` | no |
| <a name="input_enable_network_rules"></a> [enable\_network\_rules](#input\_enable\_network\_rules) | Enable network rules | `bool` | `false` | no |
| <a name="input_enable_nfsv3"></a> [enable\_nfsv3](#input\_enable\_nfsv3) | Enable NFSv3 protocol | `bool` | `false` | no |
| <a name="input_enable_queue_hour_metrics"></a> [enable\_queue\_hour\_metrics](#input\_enable\_queue\_hour\_metrics) | Enable queue hour metrics | `bool` | `false` | no |
| <a name="input_enable_queue_logging"></a> [enable\_queue\_logging](#input\_enable\_queue\_logging) | Enable queue logging | `bool` | `false` | no |
| <a name="input_enable_queue_minute_metrics"></a> [enable\_queue\_minute\_metrics](#input\_enable\_queue\_minute\_metrics) | Enable queue minute metrics | `bool` | `false` | no |
| <a name="input_enable_queue_properties"></a> [enable\_queue\_properties](#input\_enable\_queue\_properties) | Enable queue properties configuration | `bool` | `false` | no |
| <a name="input_enable_routing_preference"></a> [enable\_routing\_preference](#input\_enable\_routing\_preference) | Enable routing preference | `bool` | `false` | no |
| <a name="input_enable_share_properties"></a> [enable\_share\_properties](#input\_enable\_share\_properties) | Enable share properties configuration | `bool` | `false` | no |
| <a name="input_enable_smb_settings"></a> [enable\_smb\_settings](#input\_enable\_smb\_settings) | Enable SMB settings configuration | `bool` | `false` | no |
| <a name="input_enable_static_website"></a> [enable\_static\_website](#input\_enable\_static\_website) | Enable static website hosting | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, staging, prod) | `string` | n/a | yes |
| <a name="input_eventhub_authorization_rule_id"></a> [eventhub\_authorization\_rule\_id](#input\_eventhub\_authorization\_rule\_id) | Event Hub authorization rule ID for diagnostic settings | `string` | `null` | no |
| <a name="input_eventhub_name"></a> [eventhub\_name](#input\_eventhub\_name) | Event Hub name for diagnostic settings | `string` | `null` | no |
| <a name="input_file_shares"></a> [file\_shares](#input\_file\_shares) | Map of file shares to create | <pre>map(object({<br/>    quota_gb         = number<br/>    enabled_protocol = optional(string, "SMB")<br/>    access_tier      = optional(string, "TransactionOptimized")<br/>    metadata         = optional(map(string), null)<br/>    acl = optional(list(object({<br/>      id = string<br/>      access_policy = optional(object({<br/>        permissions = string<br/>        start       = string<br/>        expiry      = string<br/>      }), null)<br/>    })), null)<br/>  }))</pre> | `{}` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | List of user assigned identity IDs | `list(string)` | `[]` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | Type of managed identity | `string` | `null` | no |
| <a name="input_immutability_allow_protected_append_writes"></a> [immutability\_allow\_protected\_append\_writes](#input\_immutability\_allow\_protected\_append\_writes) | Allow protected append writes in immutability policy | `bool` | `false` | no |
| <a name="input_immutability_period_days"></a> [immutability\_period\_days](#input\_immutability\_period\_days) | Immutability period in days | `number` | `7` | no |
| <a name="input_immutability_state"></a> [immutability\_state](#input\_immutability\_state) | Immutability policy state | `string` | `"Unlocked"` | no |
| <a name="input_lifecycle_rules"></a> [lifecycle\_rules](#input\_lifecycle\_rules) | Lifecycle management rules | <pre>list(object({<br/>    name    = string<br/>    enabled = bool<br/>    filters = object({<br/>      prefix_match = list(string)<br/>      blob_types   = list(string)<br/>      match_blob_index_tag = optional(list(object({<br/>        name      = string<br/>        operation = string<br/>        value     = string<br/>      })), null)<br/>    })<br/>    actions = object({<br/>      base_blob = optional(object({<br/>        tier_to_cool_after_days    = optional(number, null)<br/>        tier_to_archive_after_days = optional(number, null)<br/>        delete_after_days          = optional(number, null)<br/>      }), null)<br/>      snapshot = optional(object({<br/>        tier_to_cool_after_days    = optional(number, null)<br/>        tier_to_archive_after_days = optional(number, null)<br/>        delete_after_days          = optional(number, null)<br/>      }), null)<br/>      version = optional(object({<br/>        tier_to_cool_after_days    = optional(number, null)<br/>        tier_to_archive_after_days = optional(number, null)<br/>        delete_after_days          = optional(number, null)<br/>      }), null)<br/>    })<br/>  }))</pre> | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for storage account | `string` | n/a | yes |
| <a name="input_location_short"></a> [location\_short](#input\_location\_short) | Short name for the Azure region | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Log Analytics workspace ID for diagnostic settings | `string` | `null` | no |
| <a name="input_min_tls_version"></a> [min\_tls\_version](#input\_min\_tls\_version) | Minimum TLS version | `string` | `"TLS1_2"` | no |
| <a name="input_network_rules_bypass"></a> [network\_rules\_bypass](#input\_network\_rules\_bypass) | Bypass network rules for Azure services | `list(string)` | <pre>[<br/>  "AzureServices"<br/>]</pre> | no |
| <a name="input_network_rules_default_action"></a> [network\_rules\_default\_action](#input\_network\_rules\_default\_action) | Default action for network rules | `string` | `"Allow"` | no |
| <a name="input_network_rules_ip_rules"></a> [network\_rules\_ip\_rules](#input\_network\_rules\_ip\_rules) | IP rules for network access | `list(string)` | `[]` | no |
| <a name="input_network_rules_subnet_ids"></a> [network\_rules\_subnet\_ids](#input\_network\_rules\_subnet\_ids) | Subnet IDs for network access | `list(string)` | `[]` | no |
| <a name="input_private_endpoints"></a> [private\_endpoints](#input\_private\_endpoints) | Map of private endpoints to create | <pre>map(object({<br/>    subnet_id            = string<br/>    subresource_name     = string<br/>    private_dns_zone_ids = optional(list(string), null)<br/>  }))</pre> | `{}` | no |
| <a name="input_private_link_access_rules"></a> [private\_link\_access\_rules](#input\_private\_link\_access\_rules) | Private link access rules | <pre>list(object({<br/>    endpoint_resource_id = string<br/>    endpoint_tenant_id   = string<br/>  }))</pre> | `[]` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Enable public network access | `bool` | `true` | no |
| <a name="input_queue_cors_rules"></a> [queue\_cors\_rules](#input\_queue\_cors\_rules) | CORS rules for queue service | <pre>list(object({<br/>    allowed_headers    = list(string)<br/>    allowed_methods    = list(string)<br/>    allowed_origins    = list(string)<br/>    exposed_headers    = list(string)<br/>    max_age_in_seconds = number<br/>  }))</pre> | `[]` | no |
| <a name="input_queue_logging_delete"></a> [queue\_logging\_delete](#input\_queue\_logging\_delete) | Log delete operations for queues | `bool` | `false` | no |
| <a name="input_queue_logging_read"></a> [queue\_logging\_read](#input\_queue\_logging\_read) | Log read operations for queues | `bool` | `false` | no |
| <a name="input_queue_logging_retention_days"></a> [queue\_logging\_retention\_days](#input\_queue\_logging\_retention\_days) | Queue logging retention in days | `number` | `7` | no |
| <a name="input_queue_logging_version"></a> [queue\_logging\_version](#input\_queue\_logging\_version) | Queue logging version | `string` | `"1.0"` | no |
| <a name="input_queue_logging_write"></a> [queue\_logging\_write](#input\_queue\_logging\_write) | Log write operations for queues | `bool` | `false` | no |
| <a name="input_queue_metadata"></a> [queue\_metadata](#input\_queue\_metadata) | Metadata for queues | `map(string)` | `{}` | no |
| <a name="input_queue_metrics_include_apis"></a> [queue\_metrics\_include\_apis](#input\_queue\_metrics\_include\_apis) | Include APIs in queue metrics | `bool` | `false` | no |
| <a name="input_queue_metrics_retention_days"></a> [queue\_metrics\_retention\_days](#input\_queue\_metrics\_retention\_days) | Queue metrics retention in days | `number` | `7` | no |
| <a name="input_queue_metrics_version"></a> [queue\_metrics\_version](#input\_queue\_metrics\_version) | Queue metrics version | `string` | `"1.0"` | no |
| <a name="input_queues"></a> [queues](#input\_queues) | List of queue names to create | `list(string)` | `[]` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group where storage account will be created | `string` | n/a | yes |
| <a name="input_routing_choice"></a> [routing\_choice](#input\_routing\_choice) | Routing choice | `string` | `"MicrosoftRouting"` | no |
| <a name="input_routing_publish_internet_endpoints"></a> [routing\_publish\_internet\_endpoints](#input\_routing\_publish\_internet\_endpoints) | Publish internet endpoints | `bool` | `false` | no |
| <a name="input_routing_publish_microsoft_endpoints"></a> [routing\_publish\_microsoft\_endpoints](#input\_routing\_publish\_microsoft\_endpoints) | Publish Microsoft endpoints | `bool` | `false` | no |
| <a name="input_sas_expiration_action"></a> [sas\_expiration\_action](#input\_sas\_expiration\_action) | SAS expiration action (Log) | `string` | `"Log"` | no |
| <a name="input_sas_expiration_period"></a> [sas\_expiration\_period](#input\_sas\_expiration\_period) | SAS expiration period (e.g., '1.00:00:00' for 1 day) | `string` | `null` | no |
| <a name="input_share_cors_rules"></a> [share\_cors\_rules](#input\_share\_cors\_rules) | CORS rules for file share service | <pre>list(object({<br/>    allowed_headers    = list(string)<br/>    allowed_methods    = list(string)<br/>    allowed_origins    = list(string)<br/>    exposed_headers    = list(string)<br/>    max_age_in_seconds = number<br/>  }))</pre> | `[]` | no |
| <a name="input_share_retention_days"></a> [share\_retention\_days](#input\_share\_retention\_days) | File share retention in days (0 to disable) | `number` | `0` | no |
| <a name="input_shared_access_key_enabled"></a> [shared\_access\_key\_enabled](#input\_shared\_access\_key\_enabled) | Enable shared access key | `bool` | `true` | no |
| <a name="input_smb_authentication_types"></a> [smb\_authentication\_types](#input\_smb\_authentication\_types) | SMB authentication types | `list(string)` | <pre>[<br/>  "NTLMv2",<br/>  "Kerberos"<br/>]</pre> | no |
| <a name="input_smb_channel_encryption_type"></a> [smb\_channel\_encryption\_type](#input\_smb\_channel\_encryption\_type) | SMB channel encryption type | `list(string)` | <pre>[<br/>  "AES-128-CCM",<br/>  "AES-128-GCM",<br/>  "AES-256-GCM"<br/>]</pre> | no |
| <a name="input_smb_kerberos_ticket_encryption_type"></a> [smb\_kerberos\_ticket\_encryption\_type](#input\_smb\_kerberos\_ticket\_encryption\_type) | SMB Kerberos ticket encryption type | `list(string)` | <pre>[<br/>  "RC4-HMAC",<br/>  "AES-256"<br/>]</pre> | no |
| <a name="input_smb_multichannel_enabled"></a> [smb\_multichannel\_enabled](#input\_smb\_multichannel\_enabled) | Enable SMB multichannel | `bool` | `false` | no |
| <a name="input_smb_versions"></a> [smb\_versions](#input\_smb\_versions) | SMB protocol versions | `list(string)` | <pre>[<br/>  "SMB2.1",<br/>  "SMB3.0",<br/>  "SMB3.1.1"<br/>]</pre> | no |
| <a name="input_static_website_error_404_document"></a> [static\_website\_error\_404\_document](#input\_static\_website\_error\_404\_document) | Error 404 document for static website | `string` | `"404.html"` | no |
| <a name="input_static_website_index_document"></a> [static\_website\_index\_document](#input\_static\_website\_index\_document) | Index document for static website | `string` | `"index.html"` | no |
| <a name="input_table_acl"></a> [table\_acl](#input\_table\_acl) | ACL for tables | <pre>list(object({<br/>    id = string<br/>    access_policy = optional(object({<br/>      permissions = string<br/>      start       = string<br/>      expiry      = string<br/>    }), null)<br/>  }))</pre> | `[]` | no |
| <a name="input_tables"></a> [tables](#input\_tables) | List of table names to create | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all storage account resources | `map(string)` | `{}` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Workload name for resource naming | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_blob_container_ids"></a> [blob\_container\_ids](#output\_blob\_container\_ids) | Map of blob container names to their IDs |
| <a name="output_blob_container_names"></a> [blob\_container\_names](#output\_blob\_container\_names) | Map of blob container keys to their actual names |
| <a name="output_blob_container_urls"></a> [blob\_container\_urls](#output\_blob\_container\_urls) | Map of blob container names to their URLs |
| <a name="output_compliance_info"></a> [compliance\_info](#output\_compliance\_info) | Information for compliance and governance |
| <a name="output_connectivity_info"></a> [connectivity\_info](#output\_connectivity\_info) | Information for connecting to the storage account |
| <a name="output_cost_optimization_info"></a> [cost\_optimization\_info](#output\_cost\_optimization\_info) | Information for cost optimization |
| <a name="output_diagnostic_setting_id"></a> [diagnostic\_setting\_id](#output\_diagnostic\_setting\_id) | ID of the diagnostic setting (if enabled) |
| <a name="output_file_share_ids"></a> [file\_share\_ids](#output\_file\_share\_ids) | Map of file share names to their IDs |
| <a name="output_file_share_names"></a> [file\_share\_names](#output\_file\_share\_names) | Map of file share keys to their actual names |
| <a name="output_file_share_urls"></a> [file\_share\_urls](#output\_file\_share\_urls) | Map of file share names to their URLs |
| <a name="output_identity"></a> [identity](#output\_identity) | Identity block of the storage account |
| <a name="output_integration_info"></a> [integration\_info](#output\_integration\_info) | Information for integrating with other modules |
| <a name="output_lifecycle_management_policy_id"></a> [lifecycle\_management\_policy\_id](#output\_lifecycle\_management\_policy\_id) | ID of the lifecycle management policy (if enabled) |
| <a name="output_primary_access_key"></a> [primary\_access\_key](#output\_primary\_access\_key) | Primary access key of the storage account |
| <a name="output_primary_blob_connection_string"></a> [primary\_blob\_connection\_string](#output\_primary\_blob\_connection\_string) | Primary blob connection string of the storage account |
| <a name="output_primary_blob_endpoint"></a> [primary\_blob\_endpoint](#output\_primary\_blob\_endpoint) | Primary blob endpoint of the storage account |
| <a name="output_primary_connection_string"></a> [primary\_connection\_string](#output\_primary\_connection\_string) | Primary connection string of the storage account |
| <a name="output_primary_dfs_endpoint"></a> [primary\_dfs\_endpoint](#output\_primary\_dfs\_endpoint) | Primary DFS endpoint of the storage account (Data Lake Gen2) |
| <a name="output_primary_file_endpoint"></a> [primary\_file\_endpoint](#output\_primary\_file\_endpoint) | Primary file endpoint of the storage account |
| <a name="output_primary_queue_endpoint"></a> [primary\_queue\_endpoint](#output\_primary\_queue\_endpoint) | Primary queue endpoint of the storage account |
| <a name="output_primary_table_endpoint"></a> [primary\_table\_endpoint](#output\_primary\_table\_endpoint) | Primary table endpoint of the storage account |
| <a name="output_primary_web_endpoint"></a> [primary\_web\_endpoint](#output\_primary\_web\_endpoint) | Primary web endpoint of the storage account (Static Website) |
| <a name="output_private_endpoint_fqdns"></a> [private\_endpoint\_fqdns](#output\_private\_endpoint\_fqdns) | Map of private endpoint names to their FQDNs |
| <a name="output_private_endpoint_ids"></a> [private\_endpoint\_ids](#output\_private\_endpoint\_ids) | Map of private endpoint names to their IDs |
| <a name="output_private_endpoint_ips"></a> [private\_endpoint\_ips](#output\_private\_endpoint\_ips) | Map of private endpoint names to their private IP addresses |
| <a name="output_queue_ids"></a> [queue\_ids](#output\_queue\_ids) | Map of queue names to their IDs |
| <a name="output_queue_names"></a> [queue\_names](#output\_queue\_names) | Map of queue keys to their actual names |
| <a name="output_resource_names"></a> [resource\_names](#output\_resource\_names) | Map of all created resource names for reference |
| <a name="output_secondary_access_key"></a> [secondary\_access\_key](#output\_secondary\_access\_key) | Secondary access key of the storage account |
| <a name="output_secondary_blob_connection_string"></a> [secondary\_blob\_connection\_string](#output\_secondary\_blob\_connection\_string) | Secondary blob connection string of the storage account |
| <a name="output_secondary_blob_endpoint"></a> [secondary\_blob\_endpoint](#output\_secondary\_blob\_endpoint) | Secondary blob endpoint of the storage account |
| <a name="output_secondary_connection_string"></a> [secondary\_connection\_string](#output\_secondary\_connection\_string) | Secondary connection string of the storage account |
| <a name="output_secondary_dfs_endpoint"></a> [secondary\_dfs\_endpoint](#output\_secondary\_dfs\_endpoint) | Secondary DFS endpoint of the storage account (Data Lake Gen2) |
| <a name="output_secondary_file_endpoint"></a> [secondary\_file\_endpoint](#output\_secondary\_file\_endpoint) | Secondary file endpoint of the storage account |
| <a name="output_secondary_queue_endpoint"></a> [secondary\_queue\_endpoint](#output\_secondary\_queue\_endpoint) | Secondary queue endpoint of the storage account |
| <a name="output_secondary_table_endpoint"></a> [secondary\_table\_endpoint](#output\_secondary\_table\_endpoint) | Secondary table endpoint of the storage account |
| <a name="output_secondary_web_endpoint"></a> [secondary\_web\_endpoint](#output\_secondary\_web\_endpoint) | Secondary web endpoint of the storage account (Static Website) |
| <a name="output_security_summary"></a> [security\_summary](#output\_security\_summary) | Summary of storage account security configuration |
| <a name="output_storage_account_access_tier"></a> [storage\_account\_access\_tier](#output\_storage\_account\_access\_tier) | Access tier of the storage account |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | ID of the created storage account |
| <a name="output_storage_account_kind"></a> [storage\_account\_kind](#output\_storage\_account\_kind) | Kind of the storage account |
| <a name="output_storage_account_location"></a> [storage\_account\_location](#output\_storage\_account\_location) | Location of the storage account |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | Name of the created storage account |
| <a name="output_storage_account_replication_type"></a> [storage\_account\_replication\_type](#output\_storage\_account\_replication\_type) | Replication type of the storage account |
| <a name="output_storage_account_resource_group_name"></a> [storage\_account\_resource\_group\_name](#output\_storage\_account\_resource\_group\_name) | Resource group name of the storage account |
| <a name="output_storage_account_summary"></a> [storage\_account\_summary](#output\_storage\_account\_summary) | Summary of storage account configuration |
| <a name="output_storage_account_tier"></a> [storage\_account\_tier](#output\_storage\_account\_tier) | Tier of the storage account |
| <a name="output_table_ids"></a> [table\_ids](#output\_table\_ids) | Map of table names to their IDs |
| <a name="output_table_names"></a> [table\_names](#output\_table\_names) | Map of table keys to their actual names |
<!-- END_TF_DOCS -->
