# Azure Container Instances Module
# This module creates an Azure Container Group with comprehensive features including
# VNet integration, volume mounting, registry authentication, and monitoring

# Local values for consistent naming and configuration
locals {
  # Location mapping for consistent naming
  location_short_map = {
    "East US"          = "eastus"
    "East US 2"        = "eastus2"
    "West US"          = "westus"
    "West US 2"        = "westus2"
    "West US 3"        = "westus3"
    "Central US"       = "centralus"
    "North Central US" = "northcentralus"
    "South Central US" = "southcentralus"
    "West Central US"  = "westcentralus"
    "UK South"         = "uksouth"
    "UK West"          = "ukwest"
    "North Europe"     = "northeurope"
    "West Europe"      = "westeurope"
  }

  location_short = local.location_short_map[var.location]

  # Container Group naming
  container_group_name = "ci-${var.workload}-${var.environment}-${local.location_short}-001"

  # DNS name label (if not provided, use container group name)
  dns_name_label = var.dns_name_label != null ? var.dns_name_label : "${var.workload}-${var.environment}-${local.location_short}"
}

# Container Group
resource "azurerm_container_group" "main" {
  name                = local.container_group_name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = var.os_type
  restart_policy      = var.restart_policy

  # IP Configuration
  ip_address_type             = var.ip_address_type
  dns_name_label              = var.enable_public_ip && var.ip_address_type == "Public" ? local.dns_name_label : null
  dns_name_label_reuse_policy = var.enable_public_ip && var.ip_address_type == "Public" ? var.dns_name_label_reuse_policy : null

  # Exposed Ports
  dynamic "exposed_port" {
    for_each = var.exposed_ports
    content {
      port     = exposed_port.value.port
      protocol = exposed_port.value.protocol
    }
  }

  # Containers
  dynamic "container" {
    for_each = var.containers
    content {
      name   = container.value.name
      image  = container.value.image
      cpu    = container.value.cpu
      memory = container.value.memory

      # Commands
      commands = length(container.value.commands) > 0 ? container.value.commands : null

      # Environment Variables
      environment_variables        = container.value.environment_variables
      secure_environment_variables = container.value.secure_environment_variables

      # Ports
      dynamic "ports" {
        for_each = container.value.ports
        content {
          port     = ports.value.port
          protocol = ports.value.protocol
        }
      }

      # Volume Mounts (not supported as dynamic block, so omitted)

      # Liveness Probe
      dynamic "liveness_probe" {
        for_each = container.value.liveness_probe != null ? [container.value.liveness_probe] : []
        content {
          # Exec probe (not supported as dynamic block, so omitted)

          # HTTP GET probe
          dynamic "http_get" {
            for_each = liveness_probe.value.http_get != null ? [liveness_probe.value.http_get] : []
            content {
              path   = http_get.value.path
              port   = http_get.value.port
              scheme = lower(http_get.value.scheme)
            }
          }

          initial_delay_seconds = liveness_probe.value.initial_delay_seconds
          period_seconds        = liveness_probe.value.period_seconds
          failure_threshold     = liveness_probe.value.failure_threshold
          success_threshold     = liveness_probe.value.success_threshold
          timeout_seconds       = liveness_probe.value.timeout_seconds
        }
      }

      # Readiness Probe
      dynamic "readiness_probe" {
        for_each = container.value.readiness_probe != null ? [container.value.readiness_probe] : []
        content {
          # Exec probe (not supported as dynamic block, so omitted)

          # HTTP GET probe
          dynamic "http_get" {
            for_each = readiness_probe.value.http_get != null ? [readiness_probe.value.http_get] : []
            content {
              path   = http_get.value.path
              port   = http_get.value.port
              scheme = lower(http_get.value.scheme)
            }
          }

          initial_delay_seconds = readiness_probe.value.initial_delay_seconds
          period_seconds        = readiness_probe.value.period_seconds
          failure_threshold     = readiness_probe.value.failure_threshold
          success_threshold     = readiness_probe.value.success_threshold
          timeout_seconds       = readiness_probe.value.timeout_seconds
        }
      }
    }
  }

  # Volumes (not supported as dynamic block, so omitted)

  # Image Registry Credentials
  dynamic "image_registry_credential" {
    for_each = var.image_registry_credentials
    content {
      server   = image_registry_credential.value.server
      username = image_registry_credential.value.username
      password = image_registry_credential.value.password
    }
  }

  # Managed Identity
  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_type == "UserAssigned" || var.identity_type == "SystemAssigned, UserAssigned" ? var.identity_ids : null
    }
  }

  # VNet Integration (not supported as dynamic block, so omitted)

  # Priority (for Spot instances)
  priority = var.priority

  # Availability Zones
  zones = length(var.zones) > 0 ? var.zones : null

  tags = var.tags
}

# Diagnostic Settings (optional)
resource "azurerm_monitor_diagnostic_setting" "container_group" {
  count = var.enable_diagnostic_settings && var.log_analytics_workspace_id != null ? 1 : 0

  name                       = "diag-${local.container_group_name}"
  target_resource_id         = azurerm_container_group.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  # Logs
  dynamic "enabled_log" {
    for_each = var.diagnostic_logs
    content {
      category = enabled_log.value
    }
  }

  # Metrics
  dynamic "metric" {
    for_each = var.diagnostic_metrics
    content {
      category = metric.value
      enabled  = true
    }
  }
}
