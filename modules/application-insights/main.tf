# Application Insights Module - Main Configuration
# This module creates Application Insights resources with optional workspace integration

# Local values for consistent naming
locals {
  app_insights_name = var.name != null ? var.name : "appi-${var.workload}-${var.environment}-${var.location_short}-001"
}

# Application Insights (supports both workspace-based and classic modes)
resource "azurerm_application_insights" "main" {
  name                = local.app_insights_name
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = var.workspace_id
  application_type    = var.application_type

  # Sampling configuration
  sampling_percentage = var.sampling_percentage

  # IP masking configuration (disable for dev environments for better debugging)
  disable_ip_masking = var.disable_ip_masking

  # Daily data cap configuration
  daily_data_cap_in_gb                  = var.daily_data_cap_gb
  daily_data_cap_notifications_disabled = var.daily_data_cap_notifications_disabled

  # Retention configuration (only for classic mode)
  retention_in_days = var.workspace_id == null ? var.retention_in_days : null

  # Force customer storage for logs (only for classic mode)
  force_customer_storage_for_profiler = var.workspace_id == null ? var.force_customer_storage_for_profiler : null

  # Internet configuration
  internet_ingestion_enabled = var.internet_ingestion_enabled
  internet_query_enabled     = var.internet_query_enabled

  # Local authentication
  local_authentication_disabled = var.local_authentication_disabled

  tags = var.tags
}

# Smart Detection Rules (built-in Application Insights features)
resource "azurerm_application_insights_smart_detection_rule" "failure_anomalies" {
  count = var.enable_smart_detection ? 1 : 0

  name                    = "Slow server response time"
  application_insights_id = azurerm_application_insights.main.id
  enabled                 = var.smart_detection_failure_anomalies_enabled

  # Send email notifications to additional recipients
  additional_email_recipients = var.smart_detection_emails
}

resource "azurerm_application_insights_smart_detection_rule" "performance_anomalies" {
  count = var.enable_smart_detection ? 1 : 0

  name                    = "Slow page load time"
  application_insights_id = azurerm_application_insights.main.id
  enabled                 = var.smart_detection_performance_anomalies_enabled

  # Send email notifications to additional recipients
  additional_email_recipients = var.smart_detection_emails
}

resource "azurerm_application_insights_smart_detection_rule" "trace_severity" {
  count = var.enable_smart_detection ? 1 : 0

  name                    = "Degradation in trace severity ratio"
  application_insights_id = azurerm_application_insights.main.id
  enabled                 = var.smart_detection_trace_severity_enabled

  # Send email notifications to additional recipients
  additional_email_recipients = var.smart_detection_emails
}

resource "azurerm_application_insights_smart_detection_rule" "exception_volume" {
  count = var.enable_smart_detection ? 1 : 0

  name                    = "Abnormal rise in exception volume"
  application_insights_id = azurerm_application_insights.main.id
  enabled                 = var.smart_detection_exception_volume_enabled

  # Send email notifications to additional recipients
  additional_email_recipients = var.smart_detection_emails
}

resource "azurerm_application_insights_smart_detection_rule" "memory_leak" {
  count = var.enable_smart_detection ? 1 : 0

  name                    = "Potential memory leak detected"
  application_insights_id = azurerm_application_insights.main.id
  enabled                 = var.smart_detection_memory_leak_enabled

  # Send email notifications to additional recipients
  additional_email_recipients = var.smart_detection_emails
}

resource "azurerm_application_insights_smart_detection_rule" "security_detection" {
  count = var.enable_smart_detection ? 1 : 0

  name                    = "Potential security issue detected"
  application_insights_id = azurerm_application_insights.main.id
  enabled                 = var.smart_detection_security_detection_enabled

  # Send email notifications to additional recipients
  additional_email_recipients = var.smart_detection_emails
}

# Generate a unique GUID for the workbook name (only when enabled)
resource "random_uuid" "workbook" {
  count = var.enable_workbook ? 1 : 0
}

# Optional Workbook for Application Insights dashboard
resource "azurerm_application_insights_workbook" "main" {
  count = var.enable_workbook ? 1 : 0

  name                = random_uuid.workbook[0].result
  resource_group_name = var.resource_group_name
  location            = var.location
  display_name        = var.workbook_display_name != null ? var.workbook_display_name : "${local.app_insights_name} Dashboard"

  data_json = var.workbook_data_json != null ? var.workbook_data_json : jsonencode({
    version = "Notebook/1.0"
    items = [
      {
        type = 1
        content = {
          json = "## ${local.app_insights_name} Dashboard\n\nThis dashboard provides an overview of application performance and health metrics."
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
      },
      {
        type = 3
        content = {
          version = "KqlItem/1.0"
          query   = "requests | summarize avg(duration) by bin(timestamp, 5m) | render timechart"
          size    = 0
          title   = "Average Response Time"
          timeContext = {
            durationMs = 3600000
          }
        }
      },
      {
        type = 3
        content = {
          version = "KqlItem/1.0"
          query   = "requests | where success == false | summarize count() by bin(timestamp, 5m) | render timechart"
          size    = 0
          title   = "Failed Requests"
          timeContext = {
            durationMs = 3600000
          }
        }
      },
      {
        type = 3
        content = {
          version = "KqlItem/1.0"
          query   = "exceptions | summarize count() by bin(timestamp, 5m) | render timechart"
          size    = 0
          title   = "Exceptions"
          timeContext = {
            durationMs = 3600000
          }
        }
      }
    ]
  })

  tags = var.tags
}

# API Key for programmatic access (optional)
resource "azurerm_application_insights_api_key" "main" {
  count = var.create_api_key ? 1 : 0

  name                    = "${local.app_insights_name}-api-key"
  application_insights_id = azurerm_application_insights.main.id
  read_permissions        = var.api_key_read_permissions
  write_permissions       = var.api_key_write_permissions
}

# Web Test for availability monitoring (optional)
resource "azurerm_application_insights_standard_web_test" "main" {
  for_each = var.web_tests

  name                    = "${local.app_insights_name}-webtest-${each.key}"
  resource_group_name     = var.resource_group_name
  location                = var.location
  application_insights_id = azurerm_application_insights.main.id

  geo_locations = each.value.geo_locations
  frequency     = each.value.frequency
  timeout       = each.value.timeout
  enabled       = each.value.enabled
  retry_enabled = each.value.retry_enabled

  request {
    url                              = each.value.url
    http_verb                        = each.value.http_verb
    parse_dependent_requests_enabled = each.value.parse_dependent_requests_enabled
    follow_redirects_enabled         = each.value.follow_redirects_enabled

    dynamic "header" {
      for_each = each.value.headers
      content {
        name  = header.key
        value = header.value
      }
    }

    body = each.value.body
  }

  dynamic "validation_rules" {
    for_each = each.value.validation_rules != null ? [each.value.validation_rules] : []
    content {
      expected_status_code        = validation_rules.value.expected_status_code
      ssl_check_enabled           = validation_rules.value.ssl_check_enabled
      ssl_cert_remaining_lifetime = validation_rules.value.ssl_cert_remaining_lifetime

      dynamic "content" {
        for_each = validation_rules.value.content_validation != null ? [validation_rules.value.content_validation] : []
        content {
          content_match      = content.value.content_match
          ignore_case        = content.value.ignore_case
          pass_if_text_found = content.value.pass_if_text_found
        }
      }
    }
  }

  tags = var.tags
}
