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