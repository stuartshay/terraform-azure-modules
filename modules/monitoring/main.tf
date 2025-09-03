# Monitoring Module - Main Configuration
# This module creates Log Analytics Workspace, Application Insights, and Azure Monitor components

# Local values for consistent naming
locals {
  log_analytics_name = "log-${var.workload}-${var.environment}-${var.location_short}-001"
  app_insights_name  = "appi-${var.workload}-${var.environment}-${var.location_short}-001"
  action_group_name  = "ag-${var.workload}-${var.environment}-${var.location_short}-001"
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = local.log_analytics_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_retention_days

  # Cost optimization
  daily_quota_gb                     = var.daily_quota_gb
  cmk_for_query_forced               = false
  internet_ingestion_enabled         = true
  internet_query_enabled             = true
  local_authentication_enabled       = true
  reservation_capacity_in_gb_per_day = var.reservation_capacity_gb

  tags = var.tags
}

# Application Insights (Workspace-based)
resource "azurerm_application_insights" "main" {
  name                = local.app_insights_name
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "web"

  # Sampling configuration
  sampling_percentage = var.sampling_percentage

  # Disable IP masking for better debugging (can be enabled for production)
  disable_ip_masking = var.environment == "dev" ? true : false

  tags = var.tags
}

# Storage Account for monitoring data using centralized module (optional)
module "monitoring_storage" {
  count = var.enable_storage_monitoring ? 1 : 0

  source = "../storage-account"

  # Required variables
  resource_group_name = var.resource_group_name
  location            = var.location
  workload            = var.workload
  environment         = var.environment
  location_short      = var.location_short

  # Storage configuration with enhanced security
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
  min_tls_version          = "TLS1_2"

  # Security configurations
  shared_access_key_enabled     = false
  allow_blob_public_access      = false
  public_network_access_enabled = false
  enable_data_lake_gen2         = true

  # Enhanced blob properties with comprehensive logging
  enable_blob_properties          = true
  enable_blob_versioning          = var.enable_storage_versioning
  enable_change_feed              = var.enable_storage_change_feed
  blob_delete_retention_days      = var.storage_delete_retention_days
  container_delete_retention_days = var.storage_delete_retention_days

  # Comprehensive logging for all storage services
  enable_queue_properties      = var.enable_comprehensive_logging
  enable_queue_logging         = var.enable_comprehensive_logging
  queue_logging_read           = var.enable_comprehensive_logging
  queue_logging_write          = var.enable_comprehensive_logging
  queue_logging_delete         = var.enable_comprehensive_logging
  queue_logging_retention_days = var.storage_logging_retention_days

  # File share properties for comprehensive logging
  enable_share_properties = var.enable_comprehensive_logging
  share_retention_days    = var.storage_delete_retention_days

  # SAS policy
  sas_expiration_period = "01.00:00:00" # 1 day
  sas_expiration_action = "Log"

  # Diagnostic settings integration
  enable_diagnostic_settings = true
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  tags = var.tags
}

# Action Group for notifications
resource "azurerm_monitor_action_group" "main" {
  name                = local.action_group_name
  resource_group_name = var.resource_group_name
  short_name          = "mon-${var.environment}"

  # Email notifications
  dynamic "email_receiver" {
    for_each = var.notification_emails
    content {
      name          = "email-${email_receiver.key}"
      email_address = email_receiver.value
    }
  }

  # SMS notifications (optional)
  dynamic "sms_receiver" {
    for_each = var.notification_sms
    content {
      name         = "sms-${sms_receiver.key}"
      country_code = sms_receiver.value.country_code
      phone_number = sms_receiver.value.phone_number
    }
  }

  # Webhook notifications (optional)
  dynamic "webhook_receiver" {
    for_each = var.notification_webhooks
    content {
      name        = "webhook-${webhook_receiver.key}"
      service_uri = webhook_receiver.value
    }
  }

  tags = var.tags
}

# Data Collection Rule for VM Insights (if enabled)
resource "azurerm_monitor_data_collection_rule" "vm_insights" {
  count = var.enable_vm_insights ? 1 : 0

  name                = "dcr-vminsights-${var.workload}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.main.id
      name                  = "VMInsightsPerf-Logs-Dest"
    }
  }

  data_flow {
    streams      = ["Microsoft-VMInsights-Performance"]
    destinations = ["VMInsightsPerf-Logs-Dest"]
  }

  data_sources {
    performance_counter {
      streams                       = ["Microsoft-VMInsights-Performance"]
      sampling_frequency_in_seconds = 60
      counter_specifiers = [
        "\\VmInsights\\DetailedMetrics"
      ]
      name = "VMInsightsPerfCounters"
    }
  }

  tags = var.tags
}

# Diagnostic Settings for the Log Analytics Workspace itself
resource "azurerm_monitor_diagnostic_setting" "log_analytics" {
  count = var.enable_workspace_diagnostics ? 1 : 0

  name               = "diag-${local.log_analytics_name}"
  target_resource_id = azurerm_log_analytics_workspace.main.id
  storage_account_id = var.enable_storage_monitoring ? module.monitoring_storage[0].storage_account_id : null

  enabled_log {
    category = "Audit"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

# Private Endpoint for Log Analytics (if enabled)
resource "azurerm_private_endpoint" "log_analytics" {
  count = var.enable_private_endpoints ? 1 : 0

  name                = "pe-${local.log_analytics_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-${local.log_analytics_name}"
    private_connection_resource_id = azurerm_log_analytics_workspace.main.id
    subresource_names              = ["azuremonitor"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "pdz-group-${local.log_analytics_name}"
    private_dns_zone_ids = var.private_dns_zone_ids
  }

  tags = var.tags
}

# Solutions for Log Analytics Workspace
resource "azurerm_log_analytics_solution" "security_center" {
  count = var.enable_security_center ? 1 : 0

  solution_name         = "SecurityCenterFree"
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.main.id
  workspace_name        = azurerm_log_analytics_workspace.main.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/SecurityCenterFree"
  }

  tags = var.tags
}

resource "azurerm_log_analytics_solution" "updates" {
  count = var.enable_update_management ? 1 : 0

  solution_name         = "Updates"
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.main.id
  workspace_name        = azurerm_log_analytics_workspace.main.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Updates"
  }

  tags = var.tags
}

# Generate a unique GUID for the workbook name (only when enabled)
resource "random_uuid" "workbook" {
  count = var.enable_workbook ? 1 : 0
}

# Workbook for monitoring dashboard (optional)
resource "azurerm_application_insights_workbook" "main" {
  count = var.enable_workbook ? 1 : 0

  name                = random_uuid.workbook[0].result
  resource_group_name = var.resource_group_name
  location            = var.location
  display_name        = "Function Apps Monitor - ${var.environment} Environment"

  data_json = jsonencode({
    version = "Notebook/1.0"
    items = [
      {
        type = 1
        content = {
          json = "## ${var.workload} ${var.environment} Monitoring Dashboard\n\nThis dashboard provides an overview of application performance and health metrics."
        }
      },
      {
        type = 3
        content = {
          version = "KqlItem/1.0"
          query   = "requests | summarize count() by bin(timestamp, 5m) | render timechart"
          size    = 0
          title   = "Request Rate"
          timeContext = {
            durationMs = 3600000
          }
        }
      }
    ]
  })

  tags = var.tags
}

# App Service Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "app_service" {
  for_each = var.enable_app_service_monitoring ? var.monitored_app_services : {}

  name                       = "diag-${each.value.name}"
  target_resource_id         = each.value.resource_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  # Enable specified log categories
  dynamic "enabled_log" {
    for_each = var.app_service_log_categories
    content {
      category = enabled_log.value
    }
  }

  # Enable specified metric categories
  dynamic "enabled_metric" {
    for_each = var.app_service_metric_categories
    content {
      category = enabled_metric.value
    }
  }
}
