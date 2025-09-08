# Basic Networking Example

This example demonstrates the minimal configuration required to create a virtual network with basic security settings using the networking module.

## What This Example Creates

- Resource Group for the example
- Virtual Network with a single address space
- One default subnet
- Network Security Group with default security rules
- NSG association with the subnet

## Features Demonstrated

- Basic VNet and subnet creation
- Default security rules (HTTPS allowed, HTTP denied)
- Minimal required configuration

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

This example uses hardcoded values for simplicity:

- **Resource Group**: `rg-networking-basic-example`
- **Location**: `East US`
- **Environment**: `dev`
- **VNet Address Space**: `10.0.0.0/16`
- **Subnet Address Prefix**: `10.0.1.0/24`

## Outputs

After deployment, you can view the created resources:

```bash
terraform output
```

Key outputs include:
- Virtual Network ID and name
- Subnet IDs and names
- Network Security Group IDs
- Networking summary
- Connectivity information

## Security

This basic example includes:
- HTTPS inbound traffic allowed (port 443)
- HTTP inbound traffic denied (port 80)
- HTTPS outbound traffic allowed (port 443)
- DNS outbound traffic allowed (port 53)

## Clean Up

To remove all resources created by this example:

```bash
terraform destroy
```

## Next Steps

After running this basic example, consider exploring:
- The [complete example](../complete/) for advanced features
- Adding custom subnets with service endpoints
- Enabling Network Watcher and flow logs
- Integrating with other Azure services

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5 |
| azurerm | ~> 4.40 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 4.40 |

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
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_connectivity_info"></a> [connectivity\_info](#output\_connectivity\_info) | Information for connecting other resources to the network |
| <a name="output_networking_summary"></a> [networking\_summary](#output\_networking\_summary) | Summary of networking configuration |
| <a name="output_nsg_ids"></a> [nsg\_ids](#output\_nsg\_ids) | Map of NSG names to their IDs |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | Map of subnet names to their IDs |
| <a name="output_subnet_names"></a> [subnet\_names](#output\_subnet\_names) | Map of subnet keys to their actual names |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | ID of the created virtual network |
| <a name="output_vnet_name"></a> [vnet\_name](#output\_vnet\_name) | Name of the created virtual network |
<!-- END_TF_DOCS -->
