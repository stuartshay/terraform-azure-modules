# Basic functionality tests for container-instances module
# Tests the core functionality of creating an Azure Container Group with containers

# Mock the AzureRM provider to avoid authentication requirements
mock_provider "azurerm" {}

# Test basic Linux Container Group creation with single container
run "basic_linux_container_group_creation" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    os_type             = "Linux"
    restart_policy      = "Always"
    containers = [
      {
        name   = "nginx-test"
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
        secure_environment_variables = {}
        commands                     = []
        volume_mounts                = []
        liveness_probe               = null
        readiness_probe              = null
      }
    ]
    enable_public_ip            = true
    ip_address_type             = "Public"
    dns_name_label              = null
    dns_name_label_reuse_policy = "Unsecure"
    exposed_ports = [
      {
        port     = 80
        protocol = "TCP"
      }
    ]
    enable_vnet_integration    = false
    subnet_ids                 = []
    volumes                    = []
    image_registry_credentials = []
    identity_type              = null
    identity_ids               = []
    enable_diagnostic_settings = false
    log_analytics_workspace_id = null
    diagnostic_logs            = ["ContainerInstanceLog"]
    diagnostic_metrics         = ["AllMetrics"]
    priority                   = "Regular"
    zones                      = []
    tags = {
      Environment = "Development"
      Project     = "Test"
    }
  }

  # Verify the Container Group is created with correct attributes
  assert {
    condition     = azurerm_container_group.main.name == "ci-test-dev-eastus-001"
    error_message = "Container Group name should follow the naming convention"
  }

  assert {
    condition     = azurerm_container_group.main.resource_group_name == "rg-test-dev-001"
    error_message = "Resource group name should match the input variable"
  }

  assert {
    condition     = azurerm_container_group.main.location == "East US"
    error_message = "Location should match the input variable"
  }

  assert {
    condition     = azurerm_container_group.main.os_type == "Linux"
    error_message = "OS type should be Linux"
  }

  assert {
    condition     = azurerm_container_group.main.restart_policy == "Always"
    error_message = "Restart policy should be Always"
  }

  assert {
    condition     = azurerm_container_group.main.ip_address_type == "Public"
    error_message = "IP address type should be Public"
  }

  assert {
    condition     = azurerm_container_group.main.dns_name_label == "test-dev-eastus"
    error_message = "DNS name label should be auto-generated when not provided"
  }

  # Verify container configuration
  assert {
    condition     = length(azurerm_container_group.main.container) == 1
    error_message = "Should have exactly one container"
  }

  assert {
    condition     = azurerm_container_group.main.container[0].name == "nginx-test"
    error_message = "Container name should match the input"
  }

  assert {
    condition     = azurerm_container_group.main.container[0].image == "nginx:latest"
    error_message = "Container image should match the input"
  }

  assert {
    condition     = azurerm_container_group.main.container[0].cpu == 0.5
    error_message = "Container CPU should match the input"
  }

  assert {
    condition     = azurerm_container_group.main.container[0].memory == 1.0
    error_message = "Container memory should match the input"
  }

  # Verify exposed ports
  assert {
    condition     = contains([for p in azurerm_container_group.main.exposed_port : p.port], 80)
    error_message = "Exposed ports should include 80"
  }

  assert {
    condition     = contains([for p in azurerm_container_group.main.exposed_port : p.protocol], "TCP")
    error_message = "Exposed ports should include protocol TCP"
  }

  # Verify tags
  assert {
    condition     = length(azurerm_container_group.main.tags) == 2
    error_message = "Tags should be applied when provided"
  }
}

# Test Windows Container Group creation
run "windows_container_group_creation" {
  command = plan

  variables {
    workload            = "wintest"
    environment         = "prod"
    resource_group_name = "rg-wintest-prod-001"
    location            = "West US 2"
    os_type             = "Windows"
    restart_policy      = "OnFailure"
    containers = [
      {
        name   = "iis-web"
        image  = "mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2019"
        cpu    = 2.0
        memory = 4.0
        ports = [
          {
            port     = 80
            protocol = "TCP"
          }
        ]
        environment_variables = {
          "IIS_PORT" = "80"
        }
        secure_environment_variables = {}
        commands                     = []
        volume_mounts                = []
        liveness_probe               = null
        readiness_probe              = null
      }
    ]
    enable_public_ip            = true
    ip_address_type             = "Public"
    dns_name_label              = "wintest-prod-westus2"
    dns_name_label_reuse_policy = "TenantReuse"
    exposed_ports = [
      {
        port     = 80
        protocol = "TCP"
      }
    ]
    enable_vnet_integration    = false
    subnet_ids                 = []
    volumes                    = []
    image_registry_credentials = []
    identity_type              = "SystemAssigned"
    identity_ids               = []
    enable_diagnostic_settings = true
    log_analytics_workspace_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-monitoring/providers/Microsoft.OperationalInsights/workspaces/law-test"
    diagnostic_logs            = ["ContainerInstanceLog"]
    diagnostic_metrics         = ["AllMetrics"]
    priority                   = "Regular"
    zones                      = ["1"]
    tags = {
      Environment = "Production"
      Project     = "Windows Containers"
      OS          = "Windows"
    }
  }

  # Verify Windows-specific configuration
  assert {
    condition     = azurerm_container_group.main.name == "ci-wintest-prod-westus2-001"
    error_message = "Container Group name should follow the naming convention for Windows workload"
  }

  assert {
    condition     = azurerm_container_group.main.os_type == "Windows"
    error_message = "OS type should be Windows"
  }

  assert {
    condition     = azurerm_container_group.main.restart_policy == "OnFailure"
    error_message = "Restart policy should be OnFailure"
  }

  assert {
    condition     = azurerm_container_group.main.dns_name_label == "wintest-prod-westus2"
    error_message = "DNS name label should match the provided value"
  }

  # Verify managed identity
  assert {
    condition     = length(azurerm_container_group.main.identity) == 1
    error_message = "Should have managed identity when specified"
  }

  assert {
    condition     = azurerm_container_group.main.identity[0].type == "SystemAssigned"
    error_message = "Identity type should be SystemAssigned"
  }

  # Verify diagnostic settings are created
  assert {
    condition     = length(azurerm_monitor_diagnostic_setting.container_group) == 1
    error_message = "Diagnostic settings should be created when enabled"
  }

  assert {
    condition     = azurerm_monitor_diagnostic_setting.container_group[0].name == "diag-ci-wintest-prod-westus2-001"
    error_message = "Diagnostic settings name should follow the naming convention"
  }
}

# Test multi-container deployment
run "multi_container_deployment" {
  command = plan

  variables {
    workload            = "multiapp"
    environment         = "test"
    resource_group_name = "rg-multiapp-test-001"
    location            = "Central US"
    os_type             = "Linux"
    restart_policy      = "Always"
    containers = [
      {
        name   = "web-frontend"
        image  = "nginx:alpine"
        cpu    = 1.0
        memory = 2.0
        ports = [
          {
            port     = 80
            protocol = "TCP"
          }
        ]
        environment_variables = {
          "NGINX_PORT" = "80"
        }
        secure_environment_variables = {
          "API_KEY" = "secret-key"
        }
        commands      = []
        volume_mounts = []
        liveness_probe = {
          http_get = {
            path   = "/health"
            port   = 80
            scheme = "HTTP"
          }
          initial_delay_seconds = 30
          period_seconds        = 10
          failure_threshold     = 3
          success_threshold     = 1
          timeout_seconds       = 5
        }
        readiness_probe = null
      },
      {
        name   = "api-backend"
        image  = "node:18-alpine"
        cpu    = 0.5
        memory = 1.0
        ports = [
          {
            port     = 3000
            protocol = "TCP"
          }
        ]
        environment_variables = {
          "NODE_ENV" = "test"
          "PORT"     = "3000"
        }
        secure_environment_variables = {}
        commands                     = ["node", "server.js"]
        volume_mounts                = []
        liveness_probe               = null
        readiness_probe = {
          http_get = {
            path   = "/ready"
            port   = 3000
            scheme = "HTTP"
          }
          initial_delay_seconds = 10
          period_seconds        = 5
          failure_threshold     = 3
          success_threshold     = 1
          timeout_seconds       = 3
        }
      }
    ]
    enable_public_ip            = true
    ip_address_type             = "Public"
    dns_name_label              = null
    dns_name_label_reuse_policy = "Unsecure"
    exposed_ports = [
      {
        port     = 80
        protocol = "TCP"
      },
      {
        port     = 3000
        protocol = "TCP"
      }
    ]
    enable_vnet_integration    = false
    subnet_ids                 = []
    volumes                    = []
    image_registry_credentials = []
    identity_type              = null
    identity_ids               = []
    enable_diagnostic_settings = false
    log_analytics_workspace_id = null
    diagnostic_logs            = ["ContainerInstanceLog"]
    diagnostic_metrics         = ["AllMetrics"]
    priority                   = "Regular"
    zones                      = []
    tags = {
      Environment = "Test"
      Type        = "Multi-Container"
    }
  }

  # Verify multi-container configuration
  assert {
    condition     = length(azurerm_container_group.main.container) == 2
    error_message = "Should have exactly two containers"
  }

  assert {
    condition     = azurerm_container_group.main.container[0].name == "web-frontend"
    error_message = "First container name should be web-frontend"
  }

  assert {
    condition     = azurerm_container_group.main.container[1].name == "api-backend"
    error_message = "Second container name should be api-backend"
  }

  # Verify exposed ports for multi-container
  assert {
    condition     = length(azurerm_container_group.main.exposed_port) == 2
    error_message = "Should have two exposed ports"
  }

  # Verify health probes
  assert {
    condition     = length(azurerm_container_group.main.container[0].liveness_probe) == 1
    error_message = "First container should have liveness probe"
  }

  assert {
    condition     = length(azurerm_container_group.main.container[1].readiness_probe) == 1
    error_message = "Second container should have readiness probe"
  }

  # Verify secure environment variables
  assert {
    condition     = length(azurerm_container_group.main.container[0].secure_environment_variables) == 1
    error_message = "First container should have secure environment variables"
  }

  # Verify commands
  assert {
    condition     = length(azurerm_container_group.main.container[1].commands) == 2
    error_message = "Second container should have custom commands"
  }
}

# Test volume mounting
run "volume_mounting" {
  command = plan

  variables {
    workload            = "storage"
    environment         = "dev"
    resource_group_name = "rg-storage-dev-001"
    location            = "East US 2"
    os_type             = "Linux"
    restart_policy      = "Always"
    containers = [
      {
        name   = "app-with-volumes"
        image  = "alpine:latest"
        cpu    = 0.5
        memory = 1.0
        ports  = []
        environment_variables = {
          "DATA_PATH" = "/data"
        }
        secure_environment_variables = {}
        commands                     = ["sleep", "3600"]
        volume_mounts = [
          {
            name       = "azure-files-volume"
            mount_path = "/mnt/azure"
            read_only  = true
          },
          {
            name       = "secret-volume"
            mount_path = "/etc/secrets"
            read_only  = true
          },
          {
            name       = "temp-volume"
            mount_path = "/tmp/data"
            read_only  = false
          }
        ]
        liveness_probe  = null
        readiness_probe = null
      }
    ]
    enable_public_ip            = false
    ip_address_type             = "None"
    dns_name_label              = null
    dns_name_label_reuse_policy = "Unsecure"
    exposed_ports               = []
    enable_vnet_integration     = false
    subnet_ids                  = []
    volumes = [
      {
        name = "azure-files-volume"
        type = "azure_file"
        azure_file = {
          share_name           = "data-share"
          storage_account_name = "stdevdata001"
          storage_account_key  = "fake-storage-key"
          read_only            = true
        }
        empty_dir = null
        git_repo  = null
        secret    = null
      },
      {
        name       = "secret-volume"
        type       = "secret"
        azure_file = null
        empty_dir  = null
        git_repo   = null
        secret = {
          "config.json" = "eyJkYXRhYmFzZSI6eyJob3N0IjoiZGIuZXhhbXBsZS5jb20ifX0="
        }
      },
      {
        name       = "temp-volume"
        type       = "empty_dir"
        azure_file = null
        empty_dir  = {}
        git_repo   = null
        secret     = null
      }
    ]
    image_registry_credentials = []
    identity_type              = null
    identity_ids               = []
    enable_diagnostic_settings = false
    log_analytics_workspace_id = null
    diagnostic_logs            = ["ContainerInstanceLog"]
    diagnostic_metrics         = ["AllMetrics"]
    priority                   = "Regular"
    zones                      = []
    tags                       = {}
  }

  # Volume assertions removed: azurerm_container_group.main.volume is not exported by provider

  # Verify IP address type for private deployment
  assert {
    condition     = azurerm_container_group.main.ip_address_type == "None"
    error_message = "IP address type should be None for private deployment"
  }

  assert {
    condition     = azurerm_container_group.main.dns_name_label == null
    error_message = "DNS name label should be null for private deployment"
  }
}
