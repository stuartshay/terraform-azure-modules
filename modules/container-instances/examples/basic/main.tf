# Terraform version and provider requirements
terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.71, < 5.0.0"
    }
  }
}
# Basic Azure Container Instances Example
# This example demonstrates a simple container deployment with minimal configuration

# Resource Group (assumed to exist)
data "azurerm_resource_group" "example" {
  name = "rg-container-dev-001"
}

# Basic Container Instance deployment
module "container_instances" {
  source = "../../"

  # Required variables
  workload            = "webapp"
  environment         = "dev"
  resource_group_name = data.azurerm_resource_group.example.name
  location            = data.azurerm_resource_group.example.location

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
    Project     = "Container Demo"
    Owner       = "DevOps Team"
  }
}
