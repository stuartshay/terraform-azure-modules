# Azure Function App Module
# This module creates an Azure Function App with optional features like VNet integration,
# Application Insights, deployment slots, and comprehensive security configurations

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
  }

  location_short = local.location_short_map[var.location]

  # Function App naming
  function_app_name = "func-${var.workload}-${var.environment}-${local.location_short}-001"

  # Storage Account naming (must be globally unique and lowercase)
  storage_account_name = "stfunc${var.workload}${var.environment}${substr(local.location_short, 0, 6)}001"

  # Application Insights naming
  app_insights_name = "appi-${var.workload}-functions-${var.environment}-${local.location_short}-001"


  # Common app settings that are always included
  default_app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"                 = var.runtime_name
    "FUNCTIONS_EXTENSION_VERSION"              = var.functions_extension_version
    "WEBSITE_CONTENTAZUREFILECONNECTIONSTRING" = azurerm_storage_account.functions.primary_connection_string
    "WEBSITE_CONTENTSHARE"                     = "${local.function_app_name}-content"
    "WEBSITE_RUN_FROM_PACKAGE"                 = var.run_from_package ? "1" : "0"
    "WEBSITE_ENABLE_SYNC_UPDATE_SITE"          = "true"
    "WEBSITE_VNET_ROUTE_ALL"                   = var.enable_vnet_integration ? "1" : "0"
  }

  # Runtime-specific app settings
  runtime_app_settings = var.runtime_name == "python" ? {
    "PYTHON_ISOLATE_WORKER_DEPENDENCIES" = "1"
    } : var.runtime_name == "node" ? {
    "WEBSITE_NODE_DEFAULT_VERSION" = var.runtime_version
    } : var.runtime_name == "dotnet" ? {
    "FUNCTIONS_WORKER_RUNTIME" = "dotnet"
  } : {}

  # Application Insights settings (if enabled)
  app_insights_settings = var.enable_application_insights ? {
    "APPINSIGHTS_INSTRUMENTATIONKEY"        = azurerm_application_insights.functions[0].instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.functions[0].connection_string
  } : {}

  # Final merged app settings
  merged_app_settings = merge(
    local.default_app_settings,
    local.runtime_app_settings,
    local.app_insights_settings,
    var.app_settings
  )
}

# Storage Account for Function App
resource "azurerm_storage_account" "functions" {
  #checkov:skip=CKV2_AZURE_40:Shared access key is required for Function Apps
  name                     = local.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
  min_tls_version          = var.storage_min_tls_version

  # Security configurations
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = true # Required for Function Apps
  public_network_access_enabled   = false
  # Private endpoint for storage account is now defined at the top level

  # Blob properties for better security and lifecycle management
  blob_properties {
    delete_retention_policy {
      days = var.storage_blob_delete_retention_days
    }

    dynamic "container_delete_retention_policy" {
      for_each = var.storage_container_delete_retention_days > 0 ? [1] : []
      content {
        days = var.storage_container_delete_retention_days
      }
    }
  }

  # SAS expiration policy
  dynamic "sas_policy" {
    for_each = var.storage_sas_expiration_period != null ? [1] : []
    content {
      expiration_period = var.storage_sas_expiration_period
      expiration_action = var.storage_sas_expiration_action
    }
  }

  # Network rules for storage account
  dynamic "network_rules" {
    for_each = var.enable_storage_network_rules ? [1] : []
    content {
      default_action             = var.storage_network_rules_default_action
      bypass                     = var.storage_network_rules_bypass
      ip_rules                   = var.storage_network_rules_ip_rules
      virtual_network_subnet_ids = var.storage_network_rules_subnet_ids
    }
  }

  tags = var.tags
}

# Application Insights (optional)
resource "azurerm_application_insights" "functions" {
  count = var.enable_application_insights ? 1 : 0

  name                = local.app_insights_name
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = var.application_insights_type
  retention_in_days   = var.application_insights_retention_days

  # Sampling percentage for telemetry
  sampling_percentage = var.application_insights_sampling_percentage

  # Disable IP masking if specified
  disable_ip_masking = var.application_insights_disable_ip_masking

  # Local authentication disabled for better security
  local_authentication_disabled = var.application_insights_local_auth_disabled

  # Internet ingestion and query
  internet_ingestion_enabled = var.application_insights_internet_ingestion_enabled
  internet_query_enabled     = var.application_insights_internet_query_enabled

  # Workspace-based Application Insights
  workspace_id = var.log_analytics_workspace_id

  tags = var.tags
}

# Function App (Linux or Windows based on os_type)
resource "azurerm_linux_function_app" "main" {
  count = var.os_type == "Linux" ? 1 : 0

  name                = local.function_app_name
  resource_group_name = var.resource_group_name
  location            = var.location

  storage_account_name       = azurerm_storage_account.functions.name
  storage_account_access_key = azurerm_storage_account.functions.primary_access_key
  service_plan_id            = var.service_plan_id

  # Security configurations
  https_only                    = var.https_only
  public_network_access_enabled = false
  client_certificate_enabled    = var.client_certificate_enabled
  client_certificate_mode       = var.client_certificate_mode

  # Key Vault reference identity
  key_vault_reference_identity_id = var.key_vault_reference_identity_id

  # Site configuration
  site_config {
    # Always on (not applicable for Consumption plan)
    always_on = var.always_on

    # Runtime configuration
    application_stack {
      node_version                = var.runtime_name == "node" ? var.runtime_version : null
      dotnet_version              = var.runtime_name == "dotnet" ? var.runtime_version : null
      java_version                = var.runtime_name == "java" ? var.runtime_version : null
      powershell_core_version     = var.runtime_name == "powershell" ? var.runtime_version : null
      use_custom_runtime          = var.runtime_name == "custom" ? true : false
      use_dotnet_isolated_runtime = var.use_dotnet_isolated_runtime
    }

    # Pre-warmed instance count for Premium plans
    pre_warmed_instance_count = var.pre_warmed_instance_count

    # Elastic instance minimum for Premium plans
    elastic_instance_minimum = var.elastic_instance_minimum


    # VNet route all enabled
    vnet_route_all_enabled = var.enable_vnet_integration

    # FTPS state
    ftps_state = var.ftps_state

    # Minimum TLS version
    minimum_tls_version = var.minimum_tls_version

    # SCM settings
    scm_minimum_tls_version     = var.scm_minimum_tls_version
    scm_use_main_ip_restriction = var.scm_use_main_ip_restriction

    # Health check path
    health_check_path                 = var.health_check_path
    health_check_eviction_time_in_min = var.health_check_eviction_time_in_min

    # Worker configuration
    worker_count = var.worker_count

    # Use 32-bit worker process
    use_32_bit_worker = var.use_32_bit_worker

    # Websockets
    websockets_enabled = var.websockets_enabled

    # Remote debugging
    remote_debugging_enabled = var.remote_debugging_enabled
    remote_debugging_version = var.remote_debugging_version

    # CORS configuration
    dynamic "cors" {
      for_each = var.enable_cors ? [1] : []
      content {
        allowed_origins     = var.cors_allowed_origins
        support_credentials = var.cors_support_credentials
      }
    }

    # IP restrictions
    dynamic "ip_restriction" {
      for_each = var.ip_restrictions
      content {
        ip_address                = ip_restriction.value.ip_address
        service_tag               = ip_restriction.value.service_tag
        virtual_network_subnet_id = ip_restriction.value.virtual_network_subnet_id
        name                      = ip_restriction.value.name
        priority                  = ip_restriction.value.priority
        action                    = ip_restriction.value.action

        dynamic "headers" {
          for_each = ip_restriction.value.headers != null ? [ip_restriction.value.headers] : []
          content {
            x_azure_fdid      = headers.value.x_azure_fdid
            x_fd_health_probe = headers.value.x_fd_health_probe
            x_forwarded_for   = headers.value.x_forwarded_for
            x_forwarded_host  = headers.value.x_forwarded_host
          }
        }
      }
    }

    # SCM IP restrictions
    dynamic "scm_ip_restriction" {
      for_each = var.scm_ip_restrictions
      content {
        ip_address                = scm_ip_restriction.value.ip_address
        service_tag               = scm_ip_restriction.value.service_tag
        virtual_network_subnet_id = scm_ip_restriction.value.virtual_network_subnet_id
        name                      = scm_ip_restriction.value.name
        priority                  = scm_ip_restriction.value.priority
        action                    = scm_ip_restriction.value.action

        dynamic "headers" {
          for_each = scm_ip_restriction.value.headers != null ? [scm_ip_restriction.value.headers] : []
          content {
            x_azure_fdid      = headers.value.x_azure_fdid
            x_fd_health_probe = headers.value.x_fd_health_probe
            x_forwarded_for   = headers.value.x_forwarded_for
            x_forwarded_host  = headers.value.x_forwarded_host
          }
        }
      }
    }

    # Application Insights configuration
    application_insights_connection_string = var.enable_application_insights ? azurerm_application_insights.functions[0].connection_string : null
    application_insights_key               = var.enable_application_insights ? azurerm_application_insights.functions[0].instrumentation_key : null
  }

  # App settings
  app_settings = local.merged_app_settings

  # Sticky settings for deployment slots
  dynamic "sticky_settings" {
    for_each = length(var.deployment_slots) > 0 ? [1] : []
    content {
      app_setting_names       = var.sticky_app_setting_names
      connection_string_names = var.sticky_connection_string_names
    }
  }

  # Connection strings
  dynamic "connection_string" {
    for_each = var.connection_strings
    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  # Identity configuration
  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  # Authentication settings
  dynamic "auth_settings" {
    for_each = var.enable_auth_settings ? [1] : []
    content {
      enabled                        = true
      default_provider               = var.auth_settings_default_provider
      unauthenticated_client_action  = var.auth_settings_unauthenticated_client_action
      token_store_enabled            = var.auth_settings_token_store_enabled
      token_refresh_extension_hours  = var.auth_settings_token_refresh_extension_hours
      issuer                         = var.auth_settings_issuer
      runtime_version                = var.auth_settings_runtime_version
      additional_login_parameters    = var.auth_settings_additional_login_parameters
      allowed_external_redirect_urls = var.auth_settings_allowed_external_redirect_urls

      # Active Directory configuration
      dynamic "active_directory" {
        for_each = var.auth_settings_active_directory != null ? [var.auth_settings_active_directory] : []
        content {
          client_id         = active_directory.value.client_id
          client_secret     = active_directory.value.client_secret
          allowed_audiences = active_directory.value.allowed_audiences
        }
      }

      # Facebook configuration
      dynamic "facebook" {
        for_each = var.auth_settings_facebook != null ? [var.auth_settings_facebook] : []
        content {
          app_id       = facebook.value.app_id
          app_secret   = facebook.value.app_secret
          oauth_scopes = facebook.value.oauth_scopes
        }
      }

      # Google configuration
      dynamic "google" {
        for_each = var.auth_settings_google != null ? [var.auth_settings_google] : []
        content {
          client_id     = google.value.client_id
          client_secret = google.value.client_secret
          oauth_scopes  = google.value.oauth_scopes
        }
      }

      # Microsoft configuration
      dynamic "microsoft" {
        for_each = var.auth_settings_microsoft != null ? [var.auth_settings_microsoft] : []
        content {
          client_id     = microsoft.value.client_id
          client_secret = microsoft.value.client_secret
          oauth_scopes  = microsoft.value.oauth_scopes
        }
      }

      # Twitter configuration
      dynamic "twitter" {
        for_each = var.auth_settings_twitter != null ? [var.auth_settings_twitter] : []
        content {
          consumer_key    = twitter.value.consumer_key
          consumer_secret = twitter.value.consumer_secret
        }
      }
    }
  }

  # Backup configuration
  dynamic "backup" {
    for_each = var.enable_backup ? [1] : []
    content {
      name                = var.backup_name
      storage_account_url = var.backup_storage_account_url
      enabled             = true

      schedule {
        frequency_interval       = var.backup_schedule_frequency_interval
        frequency_unit           = var.backup_schedule_frequency_unit
        keep_at_least_one_backup = var.backup_schedule_keep_at_least_one_backup
        retention_period_days    = var.backup_schedule_retention_period_days
        start_time               = var.backup_schedule_start_time
      }
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_CONTENTSHARE"],
    ]
  }
}

# Windows Function App
resource "azurerm_windows_function_app" "main" {
  count = var.os_type == "Windows" ? 1 : 0

  name                = local.function_app_name
  resource_group_name = var.resource_group_name
  location            = var.location

  storage_account_name       = azurerm_storage_account.functions.name
  storage_account_access_key = azurerm_storage_account.functions.primary_access_key
  service_plan_id            = var.service_plan_id

  # Security configurations
  https_only                    = var.https_only
  public_network_access_enabled = false
  client_certificate_enabled    = var.client_certificate_enabled
  client_certificate_mode       = var.client_certificate_mode

  # Key Vault reference identity
  key_vault_reference_identity_id = var.key_vault_reference_identity_id

  # Site configuration
  site_config {
    # Always on (not applicable for Consumption plan)
    always_on = var.always_on

    # Runtime configuration
    application_stack {
      node_version                = var.runtime_name == "node" ? var.runtime_version : null
      dotnet_version              = var.runtime_name == "dotnet" ? var.runtime_version : null
      java_version                = var.runtime_name == "java" ? var.runtime_version : null
      powershell_core_version     = var.runtime_name == "powershell" ? var.runtime_version : null
      use_custom_runtime          = var.runtime_name == "custom" ? true : false
      use_dotnet_isolated_runtime = var.use_dotnet_isolated_runtime
    }

    # Pre-warmed instance count for Premium plans
    pre_warmed_instance_count = var.pre_warmed_instance_count

    # Elastic instance minimum for Premium plans
    elastic_instance_minimum = var.elastic_instance_minimum


    # VNet route all enabled
    vnet_route_all_enabled = var.enable_vnet_integration

    # FTPS state
    ftps_state = var.ftps_state

    # Minimum TLS version
    minimum_tls_version = var.minimum_tls_version

    # SCM settings
    scm_minimum_tls_version     = var.scm_minimum_tls_version
    scm_use_main_ip_restriction = var.scm_use_main_ip_restriction

    # Health check path
    health_check_path                 = var.health_check_path
    health_check_eviction_time_in_min = var.health_check_eviction_time_in_min

    # Worker configuration
    worker_count = var.worker_count

    # Use 32-bit worker process
    use_32_bit_worker = var.use_32_bit_worker

    # Websockets
    websockets_enabled = var.websockets_enabled

    # Remote debugging
    remote_debugging_enabled = var.remote_debugging_enabled
    remote_debugging_version = var.remote_debugging_version

    # CORS configuration
    dynamic "cors" {
      for_each = var.enable_cors ? [1] : []
      content {
        allowed_origins     = var.cors_allowed_origins
        support_credentials = var.cors_support_credentials
      }
    }

    # IP restrictions
    dynamic "ip_restriction" {
      for_each = var.ip_restrictions
      content {
        ip_address                = ip_restriction.value.ip_address
        service_tag               = ip_restriction.value.service_tag
        virtual_network_subnet_id = ip_restriction.value.virtual_network_subnet_id
        name                      = ip_restriction.value.name
        priority                  = ip_restriction.value.priority
        action                    = ip_restriction.value.action

        dynamic "headers" {
          for_each = ip_restriction.value.headers != null ? [ip_restriction.value.headers] : []
          content {
            x_azure_fdid      = headers.value.x_azure_fdid
            x_fd_health_probe = headers.value.x_fd_health_probe
            x_forwarded_for   = headers.value.x_forwarded_for
            x_forwarded_host  = headers.value.x_forwarded_host
          }
        }
      }
    }

    # SCM IP restrictions
    dynamic "scm_ip_restriction" {
      for_each = var.scm_ip_restrictions
      content {
        ip_address                = scm_ip_restriction.value.ip_address
        service_tag               = scm_ip_restriction.value.service_tag
        virtual_network_subnet_id = scm_ip_restriction.value.virtual_network_subnet_id
        name                      = scm_ip_restriction.value.name
        priority                  = scm_ip_restriction.value.priority
        action                    = scm_ip_restriction.value.action

        dynamic "headers" {
          for_each = scm_ip_restriction.value.headers != null ? [scm_ip_restriction.value.headers] : []
          content {
            x_azure_fdid      = headers.value.x_azure_fdid
            x_fd_health_probe = headers.value.x_fd_health_probe
            x_forwarded_for   = headers.value.x_forwarded_for
            x_forwarded_host  = headers.value.x_forwarded_host
          }
        }
      }
    }

    # Application Insights configuration
    application_insights_connection_string = var.enable_application_insights ? azurerm_application_insights.functions[0].connection_string : null
    application_insights_key               = var.enable_application_insights ? azurerm_application_insights.functions[0].instrumentation_key : null
  }

  # App settings
  app_settings = local.merged_app_settings

  # Sticky settings for deployment slots
  dynamic "sticky_settings" {
    for_each = length(var.deployment_slots) > 0 ? [1] : []
    content {
      app_setting_names       = var.sticky_app_setting_names
      connection_string_names = var.sticky_connection_string_names
    }
  }

  # Connection strings
  dynamic "connection_string" {
    for_each = var.connection_strings
    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  # Identity configuration
  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  # Authentication settings
  dynamic "auth_settings" {
    for_each = var.enable_auth_settings ? [1] : []
    content {
      enabled                        = true
      default_provider               = var.auth_settings_default_provider
      unauthenticated_client_action  = var.auth_settings_unauthenticated_client_action
      token_store_enabled            = var.auth_settings_token_store_enabled
      token_refresh_extension_hours  = var.auth_settings_token_refresh_extension_hours
      issuer                         = var.auth_settings_issuer
      runtime_version                = var.auth_settings_runtime_version
      additional_login_parameters    = var.auth_settings_additional_login_parameters
      allowed_external_redirect_urls = var.auth_settings_allowed_external_redirect_urls

      # Active Directory configuration
      dynamic "active_directory" {
        for_each = var.auth_settings_active_directory != null ? [var.auth_settings_active_directory] : []
        content {
          client_id         = active_directory.value.client_id
          client_secret     = active_directory.value.client_secret
          allowed_audiences = active_directory.value.allowed_audiences
        }
      }

      # Facebook configuration
      dynamic "facebook" {
        for_each = var.auth_settings_facebook != null ? [var.auth_settings_facebook] : []
        content {
          app_id       = facebook.value.app_id
          app_secret   = facebook.value.app_secret
          oauth_scopes = facebook.value.oauth_scopes
        }
      }

      # Google configuration
      dynamic "google" {
        for_each = var.auth_settings_google != null ? [var.auth_settings_google] : []
        content {
          client_id     = google.value.client_id
          client_secret = google.value.client_secret
          oauth_scopes  = google.value.oauth_scopes
        }
      }

      # Microsoft configuration
      dynamic "microsoft" {
        for_each = var.auth_settings_microsoft != null ? [var.auth_settings_microsoft] : []
        content {
          client_id     = microsoft.value.client_id
          client_secret = microsoft.value.client_secret
          oauth_scopes  = microsoft.value.oauth_scopes
        }
      }

      # Twitter configuration
      dynamic "twitter" {
        for_each = var.auth_settings_twitter != null ? [var.auth_settings_twitter] : []
        content {
          consumer_key    = twitter.value.consumer_key
          consumer_secret = twitter.value.consumer_secret
        }
      }
    }
  }

  # Backup configuration
  dynamic "backup" {
    for_each = var.enable_backup ? [1] : []
    content {
      name                = var.backup_name
      storage_account_url = var.backup_storage_account_url
      enabled             = true

      schedule {
        frequency_interval       = var.backup_schedule_frequency_interval
        frequency_unit           = var.backup_schedule_frequency_unit
        keep_at_least_one_backup = var.backup_schedule_keep_at_least_one_backup
        retention_period_days    = var.backup_schedule_retention_period_days
        start_time               = var.backup_schedule_start_time
      }
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_CONTENTSHARE"],
    ]
  }
}

# VNet Integration for Function App
resource "azurerm_app_service_virtual_network_swift_connection" "main" {
  count = var.enable_vnet_integration ? 1 : 0

  app_service_id = var.os_type == "Linux" ? azurerm_linux_function_app.main[0].id : azurerm_windows_function_app.main[0].id
  subnet_id      = var.vnet_integration_subnet_id
}

# Deployment Slots for Linux Function App
resource "azurerm_linux_function_app_slot" "main" {
  for_each = var.os_type == "Linux" ? var.deployment_slots : {}

  name            = each.key
  function_app_id = azurerm_linux_function_app.main[0].id

  storage_account_name       = azurerm_storage_account.functions.name
  storage_account_access_key = azurerm_storage_account.functions.primary_access_key

  # Security configurations
  https_only                    = var.https_only
  public_network_access_enabled = false
  client_certificate_enabled    = var.client_certificate_enabled
  client_certificate_mode       = var.client_certificate_mode

  # Key Vault reference identity
  key_vault_reference_identity_id = var.key_vault_reference_identity_id

  # Site configuration
  site_config {
    # Always on (not applicable for Consumption plan)
    always_on = var.always_on

    # Runtime configuration
    application_stack {
      node_version                = var.runtime_name == "node" ? var.runtime_version : null
      dotnet_version              = var.runtime_name == "dotnet" ? var.runtime_version : null
      java_version                = var.runtime_name == "java" ? var.runtime_version : null
      powershell_core_version     = var.runtime_name == "powershell" ? var.runtime_version : null
      use_custom_runtime          = var.runtime_name == "custom" ? true : false
      use_dotnet_isolated_runtime = var.use_dotnet_isolated_runtime
    }

    # Pre-warmed instance count for Premium plans
    pre_warmed_instance_count = var.pre_warmed_instance_count

    # Elastic instance minimum for Premium plans
    elastic_instance_minimum = var.elastic_instance_minimum


    # VNet route all enabled
    vnet_route_all_enabled = var.enable_vnet_integration

    # FTPS state
    ftps_state = var.ftps_state

    # Minimum TLS version
    minimum_tls_version = var.minimum_tls_version

    # SCM settings
    scm_minimum_tls_version     = var.scm_minimum_tls_version
    scm_use_main_ip_restriction = var.scm_use_main_ip_restriction

    # Health check path
    health_check_path                 = var.health_check_path
    health_check_eviction_time_in_min = var.health_check_eviction_time_in_min

    # Worker configuration
    worker_count = var.worker_count

    # Use 32-bit worker process
    use_32_bit_worker = var.use_32_bit_worker

    # Websockets
    websockets_enabled = var.websockets_enabled

    # Remote debugging
    remote_debugging_enabled = var.remote_debugging_enabled
    remote_debugging_version = var.remote_debugging_version

    # CORS configuration
    dynamic "cors" {
      for_each = var.enable_cors ? [1] : []
      content {
        allowed_origins     = var.cors_allowed_origins
        support_credentials = var.cors_support_credentials
      }
    }

    # IP restrictions
    dynamic "ip_restriction" {
      for_each = var.ip_restrictions
      content {
        ip_address                = ip_restriction.value.ip_address
        service_tag               = ip_restriction.value.service_tag
        virtual_network_subnet_id = ip_restriction.value.virtual_network_subnet_id
        name                      = ip_restriction.value.name
        priority                  = ip_restriction.value.priority
        action                    = ip_restriction.value.action

        dynamic "headers" {
          for_each = ip_restriction.value.headers != null ? [ip_restriction.value.headers] : []
          content {
            x_azure_fdid      = headers.value.x_azure_fdid
            x_fd_health_probe = headers.value.x_fd_health_probe
            x_forwarded_for   = headers.value.x_forwarded_for
            x_forwarded_host  = headers.value.x_forwarded_host
          }
        }
      }
    }

    # SCM IP restrictions
    dynamic "scm_ip_restriction" {
      for_each = var.scm_ip_restrictions
      content {
        ip_address                = scm_ip_restriction.value.ip_address
        service_tag               = scm_ip_restriction.value.service_tag
        virtual_network_subnet_id = scm_ip_restriction.value.virtual_network_subnet_id
        name                      = scm_ip_restriction.value.name
        priority                  = scm_ip_restriction.value.priority
        action                    = scm_ip_restriction.value.action

        dynamic "headers" {
          for_each = scm_ip_restriction.value.headers != null ? [scm_ip_restriction.value.headers] : []
          content {
            x_azure_fdid      = headers.value.x_azure_fdid
            x_fd_health_probe = headers.value.x_fd_health_probe
            x_forwarded_for   = headers.value.x_forwarded_for
            x_forwarded_host  = headers.value.x_forwarded_host
          }
        }
      }
    }

    # Application Insights configuration
    application_insights_connection_string = var.enable_application_insights ? azurerm_application_insights.functions[0].connection_string : null
    application_insights_key               = var.enable_application_insights ? azurerm_application_insights.functions[0].instrumentation_key : null
  }

  # App settings (can be different per slot)
  app_settings = merge(
    local.merged_app_settings,
    each.value.app_settings
  )

  # Connection strings
  dynamic "connection_string" {
    for_each = var.connection_strings
    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  # Identity configuration
  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  tags = var.tags
}

# Deployment Slots for Windows Function App
resource "azurerm_windows_function_app_slot" "main" {
  for_each = var.os_type == "Windows" ? var.deployment_slots : {}

  name            = each.key
  function_app_id = azurerm_windows_function_app.main[0].id

  storage_account_name       = azurerm_storage_account.functions.name
  storage_account_access_key = azurerm_storage_account.functions.primary_access_key

  # Security configurations
  https_only                    = var.https_only
  public_network_access_enabled = false
  client_certificate_enabled    = var.client_certificate_enabled
  client_certificate_mode       = var.client_certificate_mode

  # Key Vault reference identity
  key_vault_reference_identity_id = var.key_vault_reference_identity_id

  # Site configuration
  site_config {
    # Always on (not applicable for Consumption plan)
    always_on = var.always_on

    # Runtime configuration
    application_stack {
      node_version                = var.runtime_name == "node" ? var.runtime_version : null
      dotnet_version              = var.runtime_name == "dotnet" ? var.runtime_version : null
      java_version                = var.runtime_name == "java" ? var.runtime_version : null
      powershell_core_version     = var.runtime_name == "powershell" ? var.runtime_version : null
      use_custom_runtime          = var.runtime_name == "custom" ? true : false
      use_dotnet_isolated_runtime = var.use_dotnet_isolated_runtime
    }

    # Pre-warmed instance count for Premium plans
    pre_warmed_instance_count = var.pre_warmed_instance_count

    # Elastic instance minimum for Premium plans
    elastic_instance_minimum = var.elastic_instance_minimum


    # VNet route all enabled
    vnet_route_all_enabled = var.enable_vnet_integration

    # FTPS state
    ftps_state = var.ftps_state

    # Minimum TLS version
    minimum_tls_version = var.minimum_tls_version

    # SCM settings
    scm_minimum_tls_version     = var.scm_minimum_tls_version
    scm_use_main_ip_restriction = var.scm_use_main_ip_restriction

    # Health check path
    health_check_path                 = var.health_check_path
    health_check_eviction_time_in_min = var.health_check_eviction_time_in_min

    # Worker configuration
    worker_count = var.worker_count

    # Use 32-bit worker process
    use_32_bit_worker = var.use_32_bit_worker

    # Websockets
    websockets_enabled = var.websockets_enabled

    # Remote debugging
    remote_debugging_enabled = var.remote_debugging_enabled
    remote_debugging_version = var.remote_debugging_version

    # CORS configuration
    dynamic "cors" {
      for_each = var.enable_cors ? [1] : []
      content {
        allowed_origins     = var.cors_allowed_origins
        support_credentials = var.cors_support_credentials
      }
    }

    # IP restrictions
    dynamic "ip_restriction" {
      for_each = var.ip_restrictions
      content {
        ip_address                = ip_restriction.value.ip_address
        service_tag               = ip_restriction.value.service_tag
        virtual_network_subnet_id = ip_restriction.value.virtual_network_subnet_id
        name                      = ip_restriction.value.name
        priority                  = ip_restriction.value.priority
        action                    = ip_restriction.value.action

        dynamic "headers" {
          for_each = ip_restriction.value.headers != null ? [ip_restriction.value.headers] : []
          content {
            x_azure_fdid      = headers.value.x_azure_fdid
            x_fd_health_probe = headers.value.x_fd_health_probe
            x_forwarded_for   = headers.value.x_forwarded_for
            x_forwarded_host  = headers.value.x_forwarded_host
          }
        }
      }
    }

    # SCM IP restrictions
    dynamic "scm_ip_restriction" {
      for_each = var.scm_ip_restrictions
      content {
        ip_address                = scm_ip_restriction.value.ip_address
        service_tag               = scm_ip_restriction.value.service_tag
        virtual_network_subnet_id = scm_ip_restriction.value.virtual_network_subnet_id
        name                      = scm_ip_restriction.value.name
        priority                  = scm_ip_restriction.value.priority
        action                    = scm_ip_restriction.value.action

        dynamic "headers" {
          for_each = scm_ip_restriction.value.headers != null ? [scm_ip_restriction.value.headers] : []
          content {
            x_azure_fdid      = headers.value.x_azure_fdid
            x_fd_health_probe = headers.value.x_fd_health_probe
            x_forwarded_for   = headers.value.x_forwarded_for
            x_forwarded_host  = headers.value.x_forwarded_host
          }
        }
      }
    }

    # Application Insights configuration
    application_insights_connection_string = var.enable_application_insights ? azurerm_application_insights.functions[0].connection_string : null
    application_insights_key               = var.enable_application_insights ? azurerm_application_insights.functions[0].instrumentation_key : null
  }

  # App settings (can be different per slot)
  app_settings = merge(
    local.merged_app_settings,
    each.value.app_settings
  )

  # Connection strings
  dynamic "connection_string" {
    for_each = var.connection_strings
    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  # Identity configuration
  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  tags = var.tags
}

# Diagnostic Settings for Function App
resource "azurerm_monitor_diagnostic_setting" "function_app" {
  count = var.enable_diagnostic_settings ? 1 : 0

  name               = "diag-${local.function_app_name}"
  target_resource_id = var.os_type == "Linux" ? azurerm_linux_function_app.main[0].id : azurerm_windows_function_app.main[0].id

  log_analytics_workspace_id     = var.log_analytics_workspace_id
  storage_account_id             = var.diagnostic_storage_account_id
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  eventhub_name                  = var.eventhub_name

  # Function App logs
  enabled_log {
    category = "FunctionAppLogs"
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

# Diagnostic Settings for Storage Account
resource "azurerm_monitor_diagnostic_setting" "storage_account" {
  count = var.enable_diagnostic_settings ? 1 : 0

  name               = "diag-${local.storage_account_name}"
  target_resource_id = azurerm_storage_account.functions.id

  log_analytics_workspace_id     = var.log_analytics_workspace_id
  storage_account_id             = var.diagnostic_storage_account_id
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  eventhub_name                  = var.eventhub_name

  # Storage logs
  enabled_log {
    category = "StorageRead"
  }
  enabled_log {
    category = "StorageWrite"
  }
  enabled_log {
    category = "StorageDelete"
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
