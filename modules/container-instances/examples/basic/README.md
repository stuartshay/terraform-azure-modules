# Basic Azure Container Instances Example

This example demonstrates a simple Azure Container Instances deployment with minimal configuration.

## Features

- Single NGINX container
- Public IP address
- Basic port exposure
- Simple environment variables

## Usage

```hcl
module "container_instances" {
  source = "../../"

  workload            = "webapp"
  environment         = "dev"
  resource_group_name = "rg-container-dev-001"
  location            = "East US"

  containers = [
    {
      name   = "nginx-web"
      image  = "nginx:latest"
      cpu    = 0.5
      memory = 1.0
      ports = [
        {
          port     = 80
          protocol = "TCP"
        }
      ]
      environment_variables = {
        "NGINX_PORT" = "80"
      }
    }
  ]

  ip_address_type = "Public"
  exposed_ports = [
    {
      port     = 80
      protocol = "TCP"
    }
  ]

  tags = {
    Environment = "Development"
    Project     = "Container Demo"
  }
}
```

## Requirements

- Existing resource group
- Azure Container Instances service available in the region

## Outputs

- `container_group_id` - The ID of the Container Group
- `ip_address` - The public IP address
- `fqdn` - The fully qualified domain name
- `container_group_summary` - Summary of the deployment

## Testing

After deployment, you can test the NGINX container by accessing the public IP address or FQDN on port 80.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.13.1 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.42.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.42.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_container_instances"></a> [container\_instances](#module\_container\_instances) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_group_id"></a> [container\_group\_id](#output\_container\_group\_id) | The ID of the Container Group |
| <a name="output_container_group_name"></a> [container\_group\_name](#output\_container\_group\_name) | The name of the Container Group |
| <a name="output_container_group_summary"></a> [container\_group\_summary](#output\_container\_group\_summary) | Summary of the Container Group deployment |
| <a name="output_fqdn"></a> [fqdn](#output\_fqdn) | The FQDN of the Container Group |
| <a name="output_ip_address"></a> [ip\_address](#output\_ip\_address) | The public IP address of the Container Group |
<!-- END_TF_DOCS -->
