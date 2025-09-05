# Basic Storage Account Example

This example demonstrates the minimal configuration required to create an Azure Storage Account using the storage-account module.

## Features

- **Standard LRS Storage Account** with basic configuration
- **Single Blob Container** for document storage
- **Minimal security settings** suitable for development environments

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

- Resource Group: `rg-storage-basic-example`
- Storage Account: `stexampledeveastus001`
- Blob Container: `container-documents-dev`

## Configuration

This example uses the following configuration:

- **Account Tier**: Standard
- **Replication**: LRS (Locally Redundant Storage)
- **Account Kind**: StorageV2
- **Access Tier**: Hot
- **HTTPS Only**: Enabled (default)
- **Public Access**: Disabled (default)

## Outputs

After deployment, you'll get:

- Storage account name and ID
- Primary blob endpoint
- Container names
- Configuration summary

## Clean Up

To remove all resources created by this example:

```bash
terraform destroy
```

## Next Steps

For more advanced configurations, see the [complete example](../complete/).

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
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_blob_container_names"></a> [blob\_container\_names](#output\_blob\_container\_names) | Names of the created blob containers |
| <a name="output_primary_blob_endpoint"></a> [primary\_blob\_endpoint](#output\_primary\_blob\_endpoint) | Primary blob endpoint of the storage account |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | ID of the created storage account |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | Name of the created storage account |
| <a name="output_storage_account_summary"></a> [storage\_account\_summary](#output\_storage\_account\_summary) | Summary of storage account configuration |
<!-- END_TF_DOCS -->
