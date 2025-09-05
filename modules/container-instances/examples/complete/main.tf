# Terraform version and provider requirements
terraform {
  required_version = ">= 1.13.1"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
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
      # Use Azure Key Vault references for secrets (CKV_AZURE_235 compliant)
      secure_environment_variables = {
        # Example: "API_KEY" = "@Microsoft.KeyVault(SecretUri=https://myvault.vault.azure.net/secrets/api-key/123456)"
        "API_KEY"      = "@Microsoft.KeyVault(SecretUri=https://myvault.vault.azure.net/secrets/api-key/123456)"
        "DATABASE_URL" = "@Microsoft.KeyVault(SecretUri=https://myvault.vault.azure.net/secrets/database-url/abcdef)"
      }
      volume_mounts = [
        {
          name       = "data-volume"
          mount_path = "/data"
        },
        {
          name       = "git-volume"
          mount_path = "/src"
        },
        {
          name       = "secret-volume"
          mount_path = "/etc/secret"
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
      # Use Azure Key Vault references for secrets (CKV_AZURE_235 compliant)
      secure_environment_variables = {
        "JWT_SECRET"  = "@Microsoft.KeyVault(SecretUri=https://myvault.vault.azure.net/secrets/jwt-secret/654321)"
        "DB_PASSWORD" = "@Microsoft.KeyVault(SecretUri=https://myvault.vault.azure.net/secrets/db-password/abcdef)"
      }
      commands = ["/app/start.sh", "--config", "/etc/app/config.yaml"]
      volume_mounts = [
        {
          name       = "azurefile-volume"
          mount_path = "/mnt/storage"
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
      # No volume mounts for this container
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


  volumes = [
    {
      name      = "data-volume"
      empty_dir = true
    },
    {
      name = "git-volume"
      git_repo = {
        repository_url = "https://github.com/Azure-Samples/aci-helloworld.git"
        directory      = "/src"
        revision       = null
      }
    },
    {
      name = "secret-volume"
      secret = {
        files = {
          "appsettings.json" = "YmFzZTY0ZW5jb2RlZCBjb250ZW50Ig==" # base64encoded content
        }
      }
    },
    {
      name = "azurefile-volume"
      azure_file = {
        share_name           = "myshare"
        storage_account_name = "mystorageaccount"
        storage_account_key  = "..."
      }
    }
  ]

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
