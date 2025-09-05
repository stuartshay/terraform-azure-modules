# Azure Container Instances Module

This Terraform module creates Azure Container Instances with comprehensive features including multi-container support, VNet integration, volume mounting, health probes, registry authentication, and monitoring capabilities.

## Features

- **Multi-container Support**: Deploy multiple containers in a single container group
- **Cross-Platform**: Supports both Linux and Windows containers
- **Networking Options**: Public IP, private IP, or no IP with VNet integration
- **Volume Mounting**: Azure Files, secrets, empty directories, and Git repositories
- **Health Probes**: Liveness and readiness probes for container health monitoring
- **Registry Authentication**: Support for private container registries (ACR, Docker Hub, etc.)
- **Managed Identity**: System-assigned and user-assigned managed identities
- **Monitoring**: Comprehensive logging and monitoring with Log Analytics integration
- **Security**: Secure environment variables, network isolation, and identity-based access
- **High Availability**: Availability zone support and restart policies

## Quick Start

### Basic Single Container Deployment

```hcl
module "container_instances" {
  source = "path/to/modules/container-instances"

  # Required variables
  workload            = "webapp"
  environment         = "dev"
  resource_group_name = "rg-webapp-dev-001"
  location            = "East US"

  # Container configuration
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

  # Network configuration
  ip_address_type = "Public"
  exposed_ports = [
    {
      port     = 80
      protocol = "TCP"
    }
  ]

  tags = {
    Environment = "Development"
    Project     = "Web Application"
  }
}
```

### Multi-Container with All Features

```hcl
module "container_instances" {
  source = "path/to/modules/container-instances"

  # Required variables
  workload            = "microservices"
  environment         = "prod"
  resource_group_name = "rg-microservices-prod-001"
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
      environment_variables = {
        "NGINX_PORT" = "80"
        "ENVIRONMENT" = "production"
      }
      secure_environment_variables = {
        "API_KEY" = "super-secret-key"
      }
      volume_mounts = [
        {
          name       = "web-content"
          mount_path = "/usr/share/nginx/html"
          read_only  = true
        }
      ]
      liveness_probe = {
        http_get = {
          path = "/health"
          port = 80
        }
        initial_delay_seconds = 30
        period_seconds       = 10
      }
    },
    {
      name   = "api-backend"
      image  = "myregistry.azurecr.io/api:v1.0.0"
      cpu    = 2.0
      memory = 4.0
      ports = [
        { port = 8080, protocol = "TCP" }
      ]
      commands = ["/app/start.sh", "--config", "/etc/app/config.yaml"]
      volume_mounts = [
        {
          name       = "app-config"
          mount_path = "/etc/app"
          read_only  = true
        }
      ]
    }
  ]

  # Private networking with VNet integration
  ip_address_type = "Private"
  enable_vnet_integration = true
  subnet_ids = [data.azurerm_subnet.containers.id]

  # Volume configuration
  volumes = [
    {
      name = "web-content"
      type = "azure_file"
      azure_file = {
        share_name           = "web-content"
        storage_account_name = "stproddata001"
        storage_account_key  = data.azurerm_storage_account.main.primary_access_key
        read_only           = true
      }
    },
    {
      name = "app-config"
      type = "secret"
      secret = {
        "config.yaml" = base64encode(file("config.yaml"))
      }
    }
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
  identity_type = "SystemAssigned"

  # Monitoring
  enable_diagnostic_settings = true
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.main.id

  # High availability
  zones = ["1", "2"]

  tags = {
    Environment = "Production"
    Project     = "Microservices Platform"
  }
}
```


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

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_container_group.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_group) | resource |
| [azurerm_monitor_diagnostic_setting.container_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_containers"></a> [containers](#input\_containers) | List of containers to deploy in the container group | <pre>list(object({<br/>    name   = string<br/>    image  = string<br/>    cpu    = number<br/>    memory = number<br/>    ports = optional(list(object({<br/>      port     = number<br/>      protocol = optional(string, "TCP")<br/>    })), [])<br/>    environment_variables        = optional(map(string), {})<br/>    secure_environment_variables = optional(map(string), {})<br/>    commands                     = optional(list(string), [])<br/>    volume_mounts = optional(list(object({<br/>      name       = string<br/>      mount_path = string<br/>      read_only  = optional(bool, false)<br/>    })), [])<br/>    liveness_probe = optional(object({<br/>      exec = optional(list(string))<br/>      http_get = optional(object({<br/>        path   = optional(string)<br/>        port   = number<br/>        scheme = optional(string, "HTTP")<br/>      }))<br/>      initial_delay_seconds = optional(number, 0)<br/>      period_seconds        = optional(number, 10)<br/>      failure_threshold     = optional(number, 3)<br/>      success_threshold     = optional(number, 1)<br/>      timeout_seconds       = optional(number, 1)<br/>    }))<br/>    readiness_probe = optional(object({<br/>      exec = optional(list(string))<br/>      http_get = optional(object({<br/>        path   = optional(string)<br/>        port   = number<br/>        scheme = optional(string, "HTTP")<br/>      }))<br/>      initial_delay_seconds = optional(number, 0)<br/>      period_seconds        = optional(number, 10)<br/>      failure_threshold     = optional(number, 3)<br/>      success_threshold     = optional(number, 1)<br/>      timeout_seconds       = optional(number, 1)<br/>    }))<br/>  }))</pre> | n/a | yes |
| <a name="input_diagnostic_logs"></a> [diagnostic\_logs](#input\_diagnostic\_logs) | List of log categories to enable for diagnostic settings | `list(string)` | <pre>[<br/>  "ContainerInstanceLog"<br/>]</pre> | no |
| <a name="input_diagnostic_metrics"></a> [diagnostic\_metrics](#input\_diagnostic\_metrics) | List of metric categories to enable for diagnostic settings | `list(string)` | <pre>[<br/>  "AllMetrics"<br/>]</pre> | no |
| <a name="input_dns_name_label"></a> [dns\_name\_label](#input\_dns\_name\_label) | The DNS name label for the container group | `string` | `null` | no |
| <a name="input_dns_name_label_reuse_policy"></a> [dns\_name\_label\_reuse\_policy](#input\_dns\_name\_label\_reuse\_policy) | The DNS name label reuse policy (Unsecure, TenantReuse, SubscriptionReuse, ResourceGroupReuse, Noreuse) | `string` | `"Unsecure"` | no |
| <a name="input_enable_diagnostic_settings"></a> [enable\_diagnostic\_settings](#input\_enable\_diagnostic\_settings) | Enable diagnostic settings for the container group | `bool` | `false` | no |
| <a name="input_enable_public_ip"></a> [enable\_public\_ip](#input\_enable\_public\_ip) | Enable public IP address for the container group | `bool` | `true` | no |
| <a name="input_enable_vnet_integration"></a> [enable\_vnet\_integration](#input\_enable\_vnet\_integration) | Enable VNet integration for the container group | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name | `string` | n/a | yes |
| <a name="input_exposed_ports"></a> [exposed\_ports](#input\_exposed\_ports) | List of ports to expose on the container group | <pre>list(object({<br/>    port     = number<br/>    protocol = optional(string, "TCP")<br/>  }))</pre> | `[]` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | List of user assigned identity IDs | `list(string)` | `[]` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | The type of managed identity for the container group (SystemAssigned, UserAssigned, SystemAssigned,UserAssigned) | `string` | `null` | no |
| <a name="input_image_registry_credentials"></a> [image\_registry\_credentials](#input\_image\_registry\_credentials) | List of image registry credentials | <pre>list(object({<br/>    server   = string<br/>    username = string<br/>    password = string<br/>  }))</pre> | `[]` | no |
| <a name="input_ip_address_type"></a> [ip\_address\_type](#input\_ip\_address\_type) | The IP address type for the container group (Public, Private, None) | `string` | `"Public"` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region | `string` | n/a | yes |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Log Analytics workspace ID for diagnostic settings | `string` | `null` | no |
| <a name="input_os_type"></a> [os\_type](#input\_os\_type) | The operating system type for the container group (Linux or Windows) | `string` | `"Linux"` | no |
| <a name="input_priority"></a> [priority](#input\_priority) | The priority of the container group (Regular, Spot) | `string` | `"Regular"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group | `string` | n/a | yes |
| <a name="input_restart_policy"></a> [restart\_policy](#input\_restart\_policy) | The restart policy for the container group (Always, OnFailure, Never) | `string` | `"Always"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs for VNet integration | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to the resources | `map(string)` | `{}` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | The workload name | `string` | n/a | yes |
| <a name="input_zones"></a> [zones](#input\_zones) | List of availability zones for the container group | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_count"></a> [container\_count](#output\_container\_count) | Number of containers in the Container Group |
| <a name="output_container_group_id"></a> [container\_group\_id](#output\_container\_group\_id) | The ID of the Container Group |
| <a name="output_container_group_location"></a> [container\_group\_location](#output\_container\_group\_location) | The location of the Container Group |
| <a name="output_container_group_name"></a> [container\_group\_name](#output\_container\_group\_name) | The name of the Container Group |
| <a name="output_container_group_os_type"></a> [container\_group\_os\_type](#output\_container\_group\_os\_type) | The OS type of the Container Group |
| <a name="output_container_group_resource_group_name"></a> [container\_group\_resource\_group\_name](#output\_container\_group\_resource\_group\_name) | The resource group name of the Container Group |
| <a name="output_container_group_restart_policy"></a> [container\_group\_restart\_policy](#output\_container\_group\_restart\_policy) | The restart policy of the Container Group |
| <a name="output_container_group_summary"></a> [container\_group\_summary](#output\_container\_group\_summary) | Summary of the Container Group deployment |
| <a name="output_container_names"></a> [container\_names](#output\_container\_names) | List of container names in the Container Group |
| <a name="output_containers"></a> [containers](#output\_containers) | Information about the containers in the Container Group |
| <a name="output_diagnostic_settings_enabled"></a> [diagnostic\_settings\_enabled](#output\_diagnostic\_settings\_enabled) | Whether diagnostic settings are enabled |
| <a name="output_diagnostic_settings_id"></a> [diagnostic\_settings\_id](#output\_diagnostic\_settings\_id) | The ID of the diagnostic settings |
| <a name="output_dns_name_label"></a> [dns\_name\_label](#output\_dns\_name\_label) | The DNS name label of the Container Group |
| <a name="output_environment"></a> [environment](#output\_environment) | The environment name |
| <a name="output_exposed_ports"></a> [exposed\_ports](#output\_exposed\_ports) | The exposed ports of the Container Group |
| <a name="output_fqdn"></a> [fqdn](#output\_fqdn) | The FQDN of the Container Group |
| <a name="output_identity"></a> [identity](#output\_identity) | The managed identity of the Container Group |
| <a name="output_image_registry_credentials_count"></a> [image\_registry\_credentials\_count](#output\_image\_registry\_credentials\_count) | Number of image registry credentials configured |
| <a name="output_ip_address"></a> [ip\_address](#output\_ip\_address) | The IP address of the Container Group |
| <a name="output_ip_address_type"></a> [ip\_address\_type](#output\_ip\_address\_type) | The IP address type of the Container Group |
| <a name="output_location"></a> [location](#output\_location) | The Azure region where resources are deployed |
| <a name="output_monitoring_configuration"></a> [monitoring\_configuration](#output\_monitoring\_configuration) | Monitoring configuration of the Container Group |
| <a name="output_network_configuration"></a> [network\_configuration](#output\_network\_configuration) | Network configuration of the Container Group |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | The principal ID of the Container Group's managed identity |
| <a name="output_registry_servers"></a> [registry\_servers](#output\_registry\_servers) | List of registry servers configured |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group |
| <a name="output_runtime_configuration"></a> [runtime\_configuration](#output\_runtime\_configuration) | Runtime configuration of the Container Group |
| <a name="output_security_configuration"></a> [security\_configuration](#output\_security\_configuration) | Security configuration of the Container Group |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | The subnet IDs used for VNet integration |
| <a name="output_tags"></a> [tags](#output\_tags) | The tags applied to the resources |
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | The tenant ID of the Container Group's managed identity |
| <a name="output_vnet_integration_enabled"></a> [vnet\_integration\_enabled](#output\_vnet\_integration\_enabled) | Whether VNet integration is enabled |
| <a name="output_workload"></a> [workload](#output\_workload) | The workload name |
<!-- END_TF_DOCS -->



## Container Configuration

### Container Object Structure

```hcl
containers = [
  {
    name   = "container-name"
    image  = "nginx:latest"
    cpu    = 1.0    # CPU cores (0.1 to 4.0)
    memory = 2.0    # Memory in GB (0.1 to 16.0)
    
    # Optional: Port configuration
    ports = [
      {
        port     = 80
        protocol = "TCP"  # TCP or UDP
      }
    ]
    
    # Optional: Environment variables
    environment_variables = {
      "ENV_VAR" = "value"
    }
    
    # Optional: Secure environment variables
    secure_environment_variables = {
      "SECRET_VAR" = "secret-value"
    }
    
    # Optional: Custom commands
    commands = ["/app/start.sh", "--config", "/etc/config.yaml"]
    
    # Optional: Volume mounts
    volume_mounts = [
      {
        name       = "volume-name"
        mount_path = "/mnt/data"
        read_only  = false
      }
    ]
    
    # Optional: Health probes
    liveness_probe = {
      http_get = {
        path   = "/health"
        port   = 80
        scheme = "HTTP"
      }
      initial_delay_seconds = 30
      period_seconds       = 10
      failure_threshold    = 3
      success_threshold    = 1
      timeout_seconds      = 5
    }
    
    readiness_probe = {
      http_get = {
        path   = "/ready"
        port   = 80
        scheme = "HTTP"
      }
      initial_delay_seconds = 5
      period_seconds       = 5
      failure_threshold    = 3
      success_threshold    = 1
      timeout_seconds      = 3
    }
  }
]
```

## Volume Types

### Azure Files Volume

```hcl
volumes = [
  {
    name = "azure-files-volume"
    type = "azure_file"
    azure_file = {
      share_name           = "data-share"
      storage_account_name = "mystorageaccount"
      storage_account_key  = "storage-key"
      read_only           = false
    }
  }
]
```

### Secret Volume

```hcl
volumes = [
  {
    name = "secret-volume"
    type = "secret"
    secret = {
      "config.json" = base64encode(jsonencode({
        database = {
          host = "db.example.com"
          port = 5432
        }
      }))
    }
  }
]
```

### Empty Directory Volume

```hcl
volumes = [
  {
    name = "temp-volume"
    type = "empty_dir"
    empty_dir = {}
  }
]
```

### Git Repository Volume

```hcl
volumes = [
  {
    name = "git-volume"
    type = "git_repo"
    git_repo = {
      url       = "https://github.com/example/config.git"
      directory = "production"
      revision  = "main"
    }
  }
]
```

## Health Probes

### HTTP Health Probe

```hcl
liveness_probe = {
  http_get = {
    path   = "/health"
    port   = 80
    scheme = "HTTP"
  }
  initial_delay_seconds = 30
  period_seconds       = 10
  failure_threshold    = 3
  success_threshold    = 1
  timeout_seconds      = 5
}
```

### Exec Health Probe

```hcl
liveness_probe = {
  exec = ["cat", "/tmp/healthy"]
  initial_delay_seconds = 30
  period_seconds       = 10
  failure_threshold    = 3
  success_threshold    = 1
  timeout_seconds      = 5
}
```

## Networking

### Public IP with DNS

```hcl
ip_address_type = "Public"
dns_name_label  = "my-app-prod"
exposed_ports = [
  {
    port     = 80
    protocol = "TCP"
  }
]
```

### Private IP with VNet Integration

```hcl
ip_address_type = "Private"
enable_vnet_integration = true
subnet_ids = [
  "/subscriptions/.../subnets/container-subnet"
]
```

### No Public IP

```hcl
ip_address_type = "None"
```

## Security

### Managed Identity

```hcl
# System-assigned identity
identity_type = "SystemAssigned"

# User-assigned identity
identity_type = "UserAssigned"
identity_ids = [
  "/subscriptions/.../userAssignedIdentities/my-identity"
]

# Both system and user-assigned
identity_type = "SystemAssigned, UserAssigned"
identity_ids = [
  "/subscriptions/.../userAssignedIdentities/my-identity"
]
```

### Container Registry Authentication

```hcl
image_registry_credentials = [
  {
    server   = "myregistry.azurecr.io"
    username = "myregistry"
    password = var.acr_password
  },
  {
    server   = "docker.io"
    username = "dockerhub-user"
    password = var.dockerhub_password
  }
]
```

## Monitoring

### Diagnostic Settings

```hcl
enable_diagnostic_settings = true
log_analytics_workspace_id = "/subscriptions/.../workspaces/my-workspace"
diagnostic_logs = [
  "ContainerInstanceLog"
]
diagnostic_metrics = [
  "AllMetrics"
]
```

## High Availability

### Availability Zones

```hcl
zones = ["1", "2", "3"]
```

### Restart Policies

```hcl
restart_policy = "Always"    # Always restart containers
restart_policy = "OnFailure" # Restart only on failure
restart_policy = "Never"     # Never restart containers
```

### Spot Instances

```hcl
priority = "Spot"  # Use spot instances for cost savings
```

## Examples

- [Basic](examples/basic/) - Simple single container deployment
- [Complete](examples/complete/) - Full-featured multi-container deployment with all options

## Testing

This module includes comprehensive Terraform tests:

```bash
# Run all tests
terraform test

# Run specific test files
terraform test -filter=basic.tftest.hcl
terraform test -filter=validation.tftest.hcl
terraform test -filter=outputs.tftest.hcl
```

### Test Coverage

- **Basic Functionality**: Container group creation, multi-container deployments, volume mounting
- **Validation**: Input validation for all parameters and error handling
- **Outputs**: Verification that all outputs are populated correctly

## Use Cases

### Web Applications

Deploy web applications with load balancers, databases, and caching layers in a single container group.

### Batch Processing

Run batch jobs with automatic restart policies and resource limits.

### CI/CD Agents

Deploy build agents with VNet integration for secure access to internal resources.

### Microservices

Deploy microservices with service discovery, health checks, and monitoring.

### Development Environments

Create temporary development environments with easy cleanup.

## Best Practices

### Resource Allocation

- Start with smaller CPU/memory allocations and scale up as needed
- Use resource limits to prevent containers from consuming excessive resources
- Monitor resource usage and adjust allocations accordingly

### Security

- Use managed identities instead of service principals when possible
- Store sensitive data in Azure Key Vault and reference via secure environment variables
- Use private networking for production workloads
- Enable diagnostic logging for security monitoring

### Networking

- Use VNet integration for secure communication with other Azure resources
- Implement proper network security groups and firewall rules
- Use private endpoints for storage accounts and other dependencies

### Monitoring

- Enable diagnostic settings and send logs to Log Analytics
- Implement health probes for all containers
- Set up alerts for container failures and resource exhaustion
- Use Application Insights for application-level monitoring

### Cost Optimization

- Use spot instances for non-critical workloads
- Implement proper restart policies to avoid unnecessary restarts
- Right-size containers based on actual resource usage
- Use availability zones only when high availability is required

## Troubleshooting

### Common Issues

1. **Container fails to start**: Check container logs and ensure image is accessible
2. **Network connectivity issues**: Verify VNet configuration and security groups
3. **Volume mount failures**: Ensure storage account access and file share permissions
4. **Health probe failures**: Verify probe configuration and application endpoints

### Debugging Commands

```bash
# Check container group status
az container show --resource-group <rg-name> --name <container-group-name>

# View container logs
az container logs --resource-group <rg-name> --name <container-group-name> --container-name <container-name>

# Execute commands in container
az container exec --resource-group <rg-name> --name <container-group-name> --container-name <container-name> --exec-command "/bin/bash"

# Monitor container metrics
az monitor metrics list --resource <container-group-id> --metric "CpuUsage,MemoryUsage"
```

## Migration

### From Docker Compose

Convert Docker Compose files to container group configurations:

1. Map services to containers
2. Convert volumes to Azure Files or secrets
3. Update networking configuration
4. Add health checks and monitoring

### From Kubernetes

Migrate Kubernetes deployments:

1. Convert pods to container groups
2. Map persistent volumes to Azure Files
3. Update service discovery and networking
4. Implement health checks and monitoring

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Ensure all tests pass
5. Submit a pull request

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](../../LICENSE) file for details.
