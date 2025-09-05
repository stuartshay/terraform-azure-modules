# Terraform version and provider requirements
terraform {
  required_version = ">= 1.13.1"
  required_providers {
    azurerm = {
      version = ">= 4.42.0"
    }
  }
}
# Complete Azure Container Instances Example
# This example demonstrates a full-featured container deployment with all available options

# Resource Group (assumed to exist)
data "azurerm_resource_group" "example" {
  name = "rg-container-prod-001"
}

# VNet and Subnet (assumed to exist for VNet integration)
data "azurerm_virtual_network" "example" {
  name                = "vnet-container-prod-001"
  resource_group_name = data.azurerm_resource_group.example.name
}

data "azurerm_subnet" "container" {
  name                 = "subnet-container"
  virtual_network_name = data.azurerm_virtual_network.example.name
  resource_group_name  = data.azurerm_resource_group.example.name
}


# Log Analytics Workspace for diagnostics (assumed to exist)
data "azurerm_log_analytics_workspace" "example" {
  name                = "law-container-prod-001"
  resource_group_name = data.azurerm_resource_group.example.name
}

# User Assigned Managed Identity (assumed to exist)
data "azurerm_user_assigned_identity" "example" {
  name                = "id-container-prod-001"
  resource_group_name = data.azurerm_resource_group.example.name
}

# Complete Container Instance deployment with all features
module "container_instances" {
  source = "../../"

  # Required variables
  workload            = "microservices"
  environment         = "prod"
  resource_group_name = data.azurerm_resource_group.example.name
  location            = data.azurerm_resource_group.example.location

  # Container configuration - Multi-container setup
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
        },
        {
          port     = 443
          protocol = "TCP"
        }
      ]
      environment_variables = {
        "NGINX_PORT"  = "80"
        "NGINX_HOST"  = "0.0.0.0"
        "ENVIRONMENT" = "production"
      }
      secure_environment_variables = {
        "API_KEY"      = "super-secret-api-key"
        "DATABASE_URL" = "postgresql://user:pass@db:5432/app"
      }
      volume_mounts = [
        {
          name       = "web-content"
          mount_path = "/usr/share/nginx/html"
          read_only  = true
        },
        {
          name       = "nginx-config"
          mount_path = "/etc/nginx/conf.d"
          read_only  = true
        }
      ]
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
      readiness_probe = {
        http_get = {
          path   = "/ready"
          port   = 80
          scheme = "HTTP"
        }
        initial_delay_seconds = 5
        period_seconds        = 5
        failure_threshold     = 3
        success_threshold     = 1
        timeout_seconds       = 3
      }
    },
    {
      name   = "api-backend"
      image  = "myregistry.azurecr.io/api:v1.2.3"
      cpu    = 2.0
      memory = 4.0
      ports = [
        {
          port     = 8080
          protocol = "TCP"
        }
      ]
      environment_variables = {
        "PORT"            = "8080"
        "LOG_LEVEL"       = "info"
        "METRICS_ENABLED" = "true"
      }
      secure_environment_variables = {
        "JWT_SECRET"  = "jwt-signing-secret"
        "DB_PASSWORD" = "database-password"
      }
      commands = ["/app/start.sh", "--config", "/etc/app/config.yaml"]
      volume_mounts = [
        {
          name       = "app-config"
          mount_path = "/etc/app"
          read_only  = true
        },
        {
          name       = "app-data"
          mount_path = "/data"
          read_only  = false
        }
      ]
      liveness_probe = {
        http_get = {
          path   = "/api/health"
          port   = 8080
          scheme = "HTTP"
        }
        initial_delay_seconds = 60
        period_seconds        = 30
        failure_threshold     = 3
        success_threshold     = 1
        timeout_seconds       = 10
      }
      readiness_probe = {
        http_get = {
          path   = "/api/ready"
          port   = 8080
          scheme = "HTTP"
        }
        initial_delay_seconds = 10
        period_seconds        = 10
        failure_threshold     = 3
        success_threshold     = 1
        timeout_seconds       = 5
      }
    },
    {
      name   = "sidecar-logging"
      image  = "fluent/fluent-bit:latest"
      cpu    = 0.5
      memory = 1.0
      environment_variables = {
        "FLUENT_CONF" = "fluent-bit.conf"
        "LOG_LEVEL"   = "info"
      }
      volume_mounts = [
        {
          name       = "log-config"
          mount_path = "/fluent-bit/etc"
          read_only  = true
        },
        {
          name       = "app-logs"
          mount_path = "/var/log"
          read_only  = false
        }
      ]
    }
  ]

  # Advanced networking configuration
  ip_address_type         = "Private"
  enable_vnet_integration = true
  subnet_ids              = [data.azurerm_subnet.container.id]

  # Exposed ports for the container group
  exposed_ports = [
    {
      port     = 80
      protocol = "TCP"
    },
    {
      port     = 443
      protocol = "TCP"
    },
    {
      port     = 8080
      protocol = "TCP"
    }
  ]

  # DNS configuration
  dns_name_label              = "microservices-prod-eastus"
  dns_name_label_reuse_policy = "TenantReuse"

  # Volume configuration
  # Volumes are not supported as a direct argument in the module interface. If needed, add support in the module or remove this block.

  image_registry_credentials = [
    {
      server   = "myregistry.azurecr.io"
      username = "myregistry"
      password = var.acr_password
    }
  ]

  # Managed identity configuration
  identity_type = "SystemAssigned, UserAssigned"
  identity_ids  = [data.azurerm_user_assigned_identity.example.id]

  # Advanced configuration
  restart_policy = "Always"
  priority       = "Regular"
  zones          = ["1", "2"]

  # Monitoring and diagnostics
  enable_diagnostic_settings = true
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.example.id
  diagnostic_logs = [
    "ContainerInstanceLog"
  ]
  diagnostic_metrics = [
    "AllMetrics"
  ]

  tags = {
    Environment = "Production"
    Project     = "Microservices Platform"
    Owner       = "Platform Team"
    CostCenter  = "Engineering"
    Backup      = "Required"
    Monitoring  = "Enabled"
    Compliance  = "SOC2"
    DataClass   = "Internal"
  }
}
