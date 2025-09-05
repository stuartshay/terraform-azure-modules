# Complete Azure Container Instances Example

This example demonstrates a full-featured Azure Container Instances deployment with all available options including multi-container setup, VNet integration, volume mounting, health probes, and comprehensive monitoring.

## Features

- **Multi-container deployment** with 3 containers (web frontend, API backend, logging sidecar)
- **Private networking** with VNet integration
- **Volume mounting** (Azure Files, secrets, empty directories, Git repositories)
- **Health probes** (liveness and readiness checks)
- **Container registry authentication** for private registries
- **Managed identity** (both system-assigned and user-assigned)
- **Comprehensive monitoring** with Log Analytics integration
- **Advanced configuration** including availability zones and restart policies

## Architecture

```
Container Group: ci-microservices-prod-eastus-001
├── web-frontend (nginx:alpine)
│   ├── Ports: 80, 443
│   ├── Volumes: web-content, nginx-config
│   └── Health Probes: /health, /ready
├── api-backend (myregistry.azurecr.io/api:v1.2.3)
│   ├── Ports: 8080
│   ├── Volumes: app-config, app-data
│   └── Health Probes: /api/health, /api/ready
└── sidecar-logging (fluent/fluent-bit:latest)
    └── Volumes: log-config, app-logs
```

## Prerequisites

Before deploying this example, ensure you have:

1. **Resource Group**: `rg-container-prod-001`
2. **Virtual Network**: `vnet-container-prod-001` with subnet `subnet-container`
3. **Storage Account**: `stcontainerprod001` with file shares:
   - `web-content` (for static web content)
   - `nginx-config` (for NGINX configuration)
4. **Log Analytics Workspace**: `law-container-prod-001`
5. **User Assigned Identity**: `id-container-prod-001`
6. **Azure Container Registry**: `myregistry.azurecr.io` with API image

## Usage

```hcl
module "container_instances" {
  source = "../../"

  workload            = "microservices"
  environment         = "prod"
  resource_group_name = "rg-container-prod-001"
  location            = "East US"

  # Multi-container configuration
  containers = [
    {
      name   = "web-frontend"
      image  = "nginx:alpine"
      cpu    = 1.0
      memory = 2.0
      ports = [
        { port = 80, protocol = "TCP" },
        { port = 443, protocol = "TCP" }
      ]
      # ... additional configuration
    },
    {
      name   = "api-backend"
      image  = "myregistry.azurecr.io/api:v1.2.3"
      cpu    = 2.0
      memory = 4.0
      # ... additional configuration
    },
    {
      name   = "sidecar-logging"
      image  = "fluent/fluent-bit:latest"
      cpu    = 0.5
      memory = 1.0
      # ... additional configuration
    }
  ]

  # Private networking
  ip_address_type = "Private"
  enable_vnet_integration = true
  subnet_ids = [data.azurerm_subnet.container.id]

  # Volume configuration
  volumes = [
    {
      name = "web-content"
      type = "azure_file"
      azure_file = {
        share_name           = "web-content"
        storage_account_name = "stcontainerprod001"
        storage_account_key  = "..."
      }
    }
    # ... additional volumes
  ]

  # Registry authentication
  image_registry_credentials = [
    {
      server   = "myregistry.azurecr.io"
      username = "myregistry"
      password = var.acr_password
    }
  ]

  # Managed identity
  identity_type = "SystemAssigned, UserAssigned"
  identity_ids  = [data.azurerm_user_assigned_identity.example.id]

  # Monitoring
  enable_diagnostic_settings = true
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.example.id
}
```

## Variables

| Name | Description | Type | Required |
|------|-------------|------|----------|
| `acr_password` | Password for Azure Container Registry authentication | `string` | Yes |

## Outputs

- `container_group_id` - The ID of the Container Group
- `ip_address` - The private IP address
- `containers` - Information about all containers
- `volumes` - Information about all volumes
- `identity` - Managed identity information
- `runtime_configuration` - Runtime settings
- `network_configuration` - Network settings
- `security_configuration` - Security settings
- `monitoring_configuration` - Monitoring settings

## Volume Types Demonstrated

1. **Azure Files**: Persistent storage for web content and configuration
2. **Secrets**: Base64-encoded configuration files
3. **Empty Directory**: Temporary storage shared between containers
4. **Git Repository**: Configuration pulled from Git at runtime

## Health Probes

The example includes both liveness and readiness probes:

- **Liveness Probes**: Determine if containers are running properly
- **Readiness Probes**: Determine if containers are ready to receive traffic

## Security Features

- **Private networking** with VNet integration
- **Secure environment variables** for sensitive data
- **Managed identity** for Azure resource authentication
- **Container registry authentication** for private images

## Monitoring

- **Diagnostic settings** enabled for comprehensive logging
- **Log Analytics integration** for centralized monitoring
- **Sidecar logging container** for application log collection

## Deployment

1. Set the required variables:
   ```bash
   export TF_VAR_acr_password="your-acr-password"
   ```

2. Initialize and apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Testing

After deployment, you can test the containers:

1. **Check container status**:
   ```bash
   az container show --resource-group rg-container-prod-001 --name ci-microservices-prod-eastus-001
   ```

2. **View logs**:
   ```bash
   az container logs --resource-group rg-container-prod-001 --name ci-microservices-prod-eastus-001 --container-name web-frontend
   ```

3. **Access applications** (if accessible from your network):
   - Web frontend: `http://<private-ip>`
   - API backend: `http://<private-ip>:8080/api`

## Cost Optimization

This example uses:
- **Regular priority** containers (use `Spot` for cost savings in non-production)
- **Availability zones** for high availability
- **Resource limits** to control costs

## Cleanup

```bash
terraform destroy
```

This will remove all container instances and associated resources created by this example.

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
| [azurerm_log_analytics_workspace.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/log_analytics_workspace) | data source |
| [azurerm_resource_group.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subnet.container](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |
| [azurerm_user_assigned_identity.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/user_assigned_identity) | data source |
| [azurerm_virtual_network.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acr_password"></a> [acr\_password](#input\_acr\_password) | Password for Azure Container Registry authentication | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_group_id"></a> [container\_group\_id](#output\_container\_group\_id) | The ID of the Container Group |
| <a name="output_container_group_name"></a> [container\_group\_name](#output\_container\_group\_name) | The name of the Container Group |
| <a name="output_container_group_summary"></a> [container\_group\_summary](#output\_container\_group\_summary) | Complete summary of the Container Group deployment |
| <a name="output_container_volume_mounts"></a> [container\_volume\_mounts](#output\_container\_volume\_mounts) | A map of container names to their volume mounts (input variable, for reference) |
| <a name="output_containers"></a> [containers](#output\_containers) | Information about all containers in the group |
| <a name="output_fqdn"></a> [fqdn](#output\_fqdn) | The FQDN of the Container Group |
| <a name="output_identity"></a> [identity](#output\_identity) | The managed identity information |
| <a name="output_ip_address"></a> [ip\_address](#output\_ip\_address) | The private IP address of the Container Group |
| <a name="output_monitoring_configuration"></a> [monitoring\_configuration](#output\_monitoring\_configuration) | Monitoring configuration of the Container Group |
| <a name="output_network_configuration"></a> [network\_configuration](#output\_network\_configuration) | Network configuration of the Container Group |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | The principal ID of the managed identity |
| <a name="output_runtime_configuration"></a> [runtime\_configuration](#output\_runtime\_configuration) | Runtime configuration of the Container Group |
| <a name="output_security_configuration"></a> [security\_configuration](#output\_security\_configuration) | Security configuration of the Container Group |
| <a name="output_volumes"></a> [volumes](#output\_volumes) | The list of volumes attached to the container group (input variable, for reference) |
<!-- END_TF_DOCS -->
