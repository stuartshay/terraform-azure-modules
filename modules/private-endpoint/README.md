# Private Endpoint Module

This module creates Azure Private Endpoints with optional DNS zone integration. It provides a reusable way to create private endpoints for various Azure services while following security best practices.

## Features

- **Flexible Configuration**: Support for various Azure services and subresources
- **DNS Integration**: Optional private DNS zone group configuration
- **IP Configuration**: Support for custom IP configurations
- **Security**: Automatic private connectivity without internet exposure
- **Naming Convention**: Consistent naming following project standards
- **Validation**: Input validation for required parameters

## Usage

### Basic Example

```hcl
module "storage_private_endpoint" {
  source = "../../modules/private-endpoint"

  name                           = "pe-mystorageaccount-blob"
  location                       = "East US"
  resource_group_name            = "rg-myproject-dev-eastus-001"
  subnet_id                      = "/subscriptions/.../subnets/snet-private-endpoints"
  private_connection_resource_id = azurerm_storage_account.main.id
  subresource_names              = ["blob"]

  tags = {
    Environment = "dev"
    Project     = "myproject"
  }
}
```

### Complete Example with DNS Integration

```hcl
module "servicebus_private_endpoint" {
  source = "../../modules/private-endpoint"

  name                           = "pe-myservicebus-namespace"
  location                       = "East US"
  resource_group_name            = "rg-myproject-prod-eastus-001"
  subnet_id                      = "/subscriptions/.../subnets/snet-private-endpoints"
  private_connection_resource_id = azurerm_servicebus_namespace.main.id
  subresource_names              = ["namespace"]

  # DNS Integration
  private_dns_zone_ids = [
    "/subscriptions/.../privateDnsZones/privatelink.servicebus.windows.net"
  ]

  # Custom naming
  private_service_connection_name = "psc-myservicebus-custom"
  private_dns_zone_group_name     = "pdzg-myservicebus-custom"

  tags = {
    Environment = "prod"
    Project     = "myproject"
    CostCenter  = "engineering"
  }
}
```

### Multiple Private Endpoints

```hcl
# Create multiple private endpoints for different subresources
module "storage_private_endpoints" {
  source = "../../modules/private-endpoint"

  for_each = {
    blob  = "blob"
    file  = "file"
    queue = "queue"
    table = "table"
  }

  name                           = "pe-mystorageaccount-${each.value}"
  location                       = "East US"
  resource_group_name            = "rg-myproject-dev-eastus-001"
  subnet_id                      = "/subscriptions/.../subnets/snet-private-endpoints"
  private_connection_resource_id = azurerm_storage_account.main.id
  subresource_names              = [each.value]

  private_dns_zone_ids = [
    "/subscriptions/.../privateDnsZones/privatelink.${each.value}.core.windows.net"
  ]

  tags = var.tags
}
```

## Supported Azure Services

This module supports private endpoints for various Azure services. Common subresource names include:

### Storage Account
- `blob`, `blob_secondary`
- `file`, `file_secondary`
- `queue`, `queue_secondary`
- `table`, `table_secondary`
- `web`, `web_secondary`
- `dfs`, `dfs_secondary`

### Service Bus
- `namespace`

### Key Vault
- `vault`

### SQL Database
- `sqlServer`

### Cosmos DB
- `sql`, `mongodb`, `cassandra`, `gremlin`, `table`

### App Service
- `sites`

### Function App
- `sites`

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5 |
| azurerm | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 4.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_private_endpoint.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the private endpoint | `string` | n/a | yes |
| location | Azure region for the private endpoint | `string` | n/a | yes |
| resource_group_name | Name of the resource group where the private endpoint will be created | `string` | n/a | yes |
| subnet_id | ID of the subnet where the private endpoint will be created | `string` | n/a | yes |
| private_connection_resource_id | Resource ID of the Azure service to connect to via private endpoint | `string` | n/a | yes |
| subresource_names | List of subresource names which the private endpoint is able to connect to | `list(string)` | n/a | yes |
| private_service_connection_name | Name of the private service connection. If not provided, will be generated based on private endpoint name | `string` | `null` | no |
| is_manual_connection | Whether the private endpoint connection requires manual approval | `bool` | `false` | no |
| request_message | Request message for manual private endpoint connection approval | `string` | `null` | no |
| private_dns_zone_ids | List of private DNS zone IDs to associate with the private endpoint | `list(string)` | `null` | no |
| private_dns_zone_group_name | Name of the private DNS zone group. If not provided, will be generated based on private endpoint name | `string` | `null` | no |
| ip_configurations | List of IP configurations for the private endpoint | `list(object({...}))` | `[]` | no |
| tags | Tags to apply to the private endpoint | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | ID of the private endpoint |
| name | Name of the private endpoint |
| location | Location of the private endpoint |
| resource_group_name | Resource group name of the private endpoint |
| subnet_id | Subnet ID where the private endpoint is deployed |
| private_service_connection | Private service connection details |
| private_dns_zone_group | Private DNS zone group details (if configured) |
| network_interface | Network interface details of the private endpoint |
| custom_dns_configs | Custom DNS configurations for the private endpoint |
| private_ip_address | Private IP address of the private endpoint |
| fqdn | FQDN of the private endpoint (if available) |

## Security Considerations

1. **Network Isolation**: Private endpoints provide secure connectivity without exposing services to the public internet
2. **DNS Resolution**: Use private DNS zones for proper name resolution within your virtual network
3. **Subnet Planning**: Ensure the subnet has sufficient IP addresses for private endpoints
4. **Network Security Groups**: Configure NSG rules to allow traffic to private endpoint subnets
5. **Monitoring**: Enable diagnostic settings and monitoring for private endpoint connections

## Best Practices

1. **Naming Convention**: Use consistent naming patterns for private endpoints and related resources
2. **DNS Integration**: Always configure private DNS zones for production environments
3. **Subnet Segregation**: Use dedicated subnets for private endpoints
4. **Resource Grouping**: Group related private endpoints in the same resource group
5. **Tagging**: Apply consistent tags for cost management and governance
6. **Documentation**: Document the purpose and configuration of each private endpoint

## Examples

See the [examples](./examples/) directory for complete usage examples:

- [Basic Example](./examples/basic/) - Simple private endpoint setup
- [Complete Example](./examples/complete/) - Advanced configuration with DNS integration

## Contributing

When contributing to this module, please ensure:

1. All variables have proper descriptions and validation
2. Examples are updated to reflect new features
3. Documentation is kept up to date
4. Tests are added for new functionality
5. Security best practices are followed

## License

This module is licensed under the MIT License. See [LICENSE](../../LICENSE) for details.

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

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_private_endpoint.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ip_configurations"></a> [ip\_configurations](#input\_ip\_configurations) | List of IP configurations for the private endpoint | <pre>list(object({<br/>    name               = string<br/>    private_ip_address = string<br/>    subresource_name   = string<br/>    member_name        = optional(string, null)<br/>  }))</pre> | `[]` | no |
| <a name="input_is_manual_connection"></a> [is\_manual\_connection](#input\_is\_manual\_connection) | Whether the private endpoint connection requires manual approval | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for the private endpoint | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the private endpoint | `string` | n/a | yes |
| <a name="input_private_connection_resource_id"></a> [private\_connection\_resource\_id](#input\_private\_connection\_resource\_id) | Resource ID of the Azure service to connect to via private endpoint | `string` | n/a | yes |
| <a name="input_private_dns_zone_group_name"></a> [private\_dns\_zone\_group\_name](#input\_private\_dns\_zone\_group\_name) | Name of the private DNS zone group. If not provided, will be generated based on private endpoint name | `string` | `null` | no |
| <a name="input_private_dns_zone_ids"></a> [private\_dns\_zone\_ids](#input\_private\_dns\_zone\_ids) | List of private DNS zone IDs to associate with the private endpoint | `list(string)` | `null` | no |
| <a name="input_private_service_connection_name"></a> [private\_service\_connection\_name](#input\_private\_service\_connection\_name) | Name of the private service connection. If not provided, will be generated based on private endpoint name | `string` | `null` | no |
| <a name="input_request_message"></a> [request\_message](#input\_request\_message) | Request message for manual private endpoint connection approval | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group where the private endpoint will be created | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | ID of the subnet where the private endpoint will be created | `string` | n/a | yes |
| <a name="input_subresource_names"></a> [subresource\_names](#input\_subresource\_names) | List of subresource names which the private endpoint is able to connect to | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the private endpoint | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_custom_dns_configs"></a> [custom\_dns\_configs](#output\_custom\_dns\_configs) | Custom DNS configurations for the private endpoint |
| <a name="output_fqdn"></a> [fqdn](#output\_fqdn) | FQDN of the private endpoint (if available) |
| <a name="output_id"></a> [id](#output\_id) | ID of the private endpoint |
| <a name="output_location"></a> [location](#output\_location) | Location of the private endpoint |
| <a name="output_name"></a> [name](#output\_name) | Name of the private endpoint |
| <a name="output_network_interface"></a> [network\_interface](#output\_network\_interface) | Network interface details of the private endpoint |
| <a name="output_private_dns_zone_group"></a> [private\_dns\_zone\_group](#output\_private\_dns\_zone\_group) | Private DNS zone group details (if configured) |
| <a name="output_private_ip_address"></a> [private\_ip\_address](#output\_private\_ip\_address) | Private IP address of the private endpoint |
| <a name="output_private_service_connection"></a> [private\_service\_connection](#output\_private\_service\_connection) | Private service connection details |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Resource group name of the private endpoint |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | Subnet ID where the private endpoint is deployed |
<!-- END_TF_DOCS -->
