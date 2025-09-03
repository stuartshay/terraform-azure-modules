# Output validation tests for function-app module
# Tests that all outputs are correctly populated and formatted

# Mock the AzureRM provider to avoid authentication requirements
mock_provider "azurerm" {}

# Test all outputs are populated correctly with basic configuration
run "verify_all_outputs_basic" {
  command = plan

  variables {
    workload                                        = "out"
    environment                                     = "dev"
    resource_group_name                             = "rg-output-test-dev-001"
    location                                        = "East US"
    service_plan_id                                 = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-output-test-dev-001/providers/Microsoft.Web/serverFarms/asp-output-test-dev-001"
    os_type                                         = "Linux"
    runtime_name                                    = "python"
    runtime_version                                 = "3.11"
    functions_extension_version                     = "~4"
    enable_vnet_integration                         = false
    storage_account_tier                            = "Standard"
    storage_account_replication_type                = "LRS"
    storage_min_tls_version                         = "TLS1_2"
    storage_blob_delete_retention_days              = 7
    storage_container_delete_retention_days         = 0
    storage_sas_expiration_period                   = null
    storage_sas_expiration_action                   = "Log"
    enable_storage_network_rules                    = false
    storage_network_rules_default_action            = "Allow"
    storage_network_rules_bypass                    = ["AzureServices"]
    storage_network_rules_ip_rules                  = []
    storage_network_rules_subnet_ids                = []
    enable_application_insights                     = false
    application_insights_type                       = "web"
    application_insights_retention_days             = 90
    application_insights_sampling_percentage        = 100
    application_insights_disable_ip_masking         = false
    application_insights_local_auth_disabled        = true
    application_insights_internet_ingestion_enabled = true
    application_insights_internet_query_enabled     = true
    log_analytics_workspace_id                      = null
    https_only                                      = true
    client_certificate_enabled                      = false
    client_certificate_mode                         = "Required"
    public_network_access_enabled                   = false
    scm_minimum_tls_version                         = "1.2"
    always_on                                       = false
    pre_warmed_instance_count                       = 0
    elastic_instance_minimum                        = 0
    function_app_scale_limit                        = 200
    worker_count                                    = 1
    use_32_bit_worker                               = false
    deployment_slots                                = {}
    vnet_integration_subnet_id                      = null
    websockets_enabled                              = false
    remote_debugging_enabled                        = false
    remote_debugging_version                        = "VS2019"
    enable_cors                                     = false
    cors_allowed_origins                            = []
    cors_support_credentials                        = false
    use_dotnet_isolated_runtime                     = false
    enable_diagnostic_settings                      = false
    tags = {
      Environment = "Development"
      Project     = "Output Test"
    }
  }

  # Test that Function App outputs exist (basic structure validation)
  # Note: We can't test computed values during plan phase, so we focus on configuration outputs

  # Test Application Insights outputs (should be null when disabled)
  assert {
    condition     = output.application_insights_id == null
    error_message = "application_insights_id should be null when Application Insights is disabled"
  }

  assert {
    condition     = output.application_insights_name == null
    error_message = "application_insights_name should be null when Application Insights is disabled"
  }

  assert {
    condition     = output.application_insights_instrumentation_key == null
    error_message = "application_insights_instrumentation_key should be null when Application Insights is disabled"
  }

  assert {
    condition     = output.application_insights_connection_string == null
    error_message = "application_insights_connection_string should be null when Application Insights is disabled"
  }

  assert {
    condition     = output.application_insights_app_id == null
    error_message = "application_insights_app_id should be null when Application Insights is disabled"
  }

  # Test VNet integration outputs
  assert {
    condition     = output.vnet_integration_enabled == false
    error_message = "vnet_integration_enabled should be false when VNet integration is disabled"
  }

  assert {
    condition     = output.vnet_integration_subnet_id == null
    error_message = "vnet_integration_subnet_id should be null when VNet integration is disabled"
  }

  # Test deployment slots outputs
  assert {
    condition     = length(output.deployment_slot_names) == 0
    error_message = "deployment_slot_names should be empty when no slots are configured"
  }

  assert {
    condition     = output.deployment_slot_count == 0
    error_message = "deployment_slot_count should be 0 when no slots are configured"
  }

  # Test configuration outputs
  assert {
    condition     = output.runtime_configuration.os_type == "Linux"
    error_message = "runtime_configuration.os_type should match the input variable"
  }

  assert {
    condition     = output.runtime_configuration.runtime_name == "python"
    error_message = "runtime_configuration.runtime_name should match the input variable"
  }

  assert {
    condition     = output.runtime_configuration.runtime_version == "3.11"
    error_message = "runtime_configuration.runtime_version should match the input variable"
  }

  assert {
    condition     = output.runtime_configuration.functions_extension_version == "~4"
    error_message = "runtime_configuration.functions_extension_version should match the input variable"
  }

  assert {
    condition     = output.runtime_configuration.use_dotnet_isolated_runtime == false
    error_message = "runtime_configuration.use_dotnet_isolated_runtime should match the input variable"
  }

  # Test security configuration
  assert {
    condition     = output.security_configuration.https_only == true
    error_message = "security_configuration.https_only should match the input variable"
  }

  assert {
    condition     = output.security_configuration.public_network_access_enabled == false
    error_message = "security_configuration.public_network_access_enabled should match the input variable"
  }

  assert {
    condition     = output.security_configuration.client_certificate_enabled == false
    error_message = "security_configuration.client_certificate_enabled should match the input variable"
  }

  assert {
    condition     = output.security_configuration.client_certificate_mode == "Required"
    error_message = "security_configuration.client_certificate_mode should match the input variable"
  }

  assert {
    condition     = output.security_configuration.minimum_tls_version == "1.2"
    error_message = "security_configuration.minimum_tls_version should be 1.2"
  }

  assert {
    condition     = output.security_configuration.scm_minimum_tls_version == "1.2"
    error_message = "security_configuration.scm_minimum_tls_version should match the input variable"
  }

  assert {
    condition     = output.security_configuration.ftps_state == "Disabled"
    error_message = "security_configuration.ftps_state should be Disabled"
  }

  # Test performance configuration
  assert {
    condition     = output.performance_configuration.always_on == false
    error_message = "performance_configuration.always_on should match the input variable"
  }

  assert {
    condition     = output.performance_configuration.pre_warmed_instance_count == 0
    error_message = "performance_configuration.pre_warmed_instance_count should match the input variable"
  }

  assert {
    condition     = output.performance_configuration.elastic_instance_minimum == 0
    error_message = "performance_configuration.elastic_instance_minimum should match the input variable"
  }

  assert {
    condition     = output.performance_configuration.function_app_scale_limit == 200
    error_message = "performance_configuration.function_app_scale_limit should match the input variable"
  }

  assert {
    condition     = output.performance_configuration.worker_count == 1
    error_message = "performance_configuration.worker_count should match the input variable"
  }

  assert {
    condition     = output.performance_configuration.use_32_bit_worker == false
    error_message = "performance_configuration.use_32_bit_worker should match the input variable"
  }

  # Test network configuration
  assert {
    condition     = output.network_configuration.enable_vnet_integration == false
    error_message = "network_configuration.enable_vnet_integration should match the input variable"
  }

  assert {
    condition     = output.network_configuration.vnet_integration_subnet_id == null
    error_message = "network_configuration.vnet_integration_subnet_id should be null when VNet integration is disabled"
  }

  assert {
    condition     = output.network_configuration.websockets_enabled == false
    error_message = "network_configuration.websockets_enabled should match the input variable"
  }

  assert {
    condition     = output.network_configuration.remote_debugging_enabled == false
    error_message = "network_configuration.remote_debugging_enabled should match the input variable"
  }

  assert {
    condition     = output.network_configuration.remote_debugging_version == "VS2019"
    error_message = "network_configuration.remote_debugging_version should match the input variable"
  }

  assert {
    condition     = output.network_configuration.enable_cors == false
    error_message = "network_configuration.enable_cors should match the input variable"
  }

  assert {
    condition     = length(output.network_configuration.cors_allowed_origins) == 0
    error_message = "network_configuration.cors_allowed_origins should be empty when CORS is disabled"
  }

  assert {
    condition     = output.network_configuration.cors_support_credentials == false
    error_message = "network_configuration.cors_support_credentials should match the input variable"
  }

  # Test service plan and resource information
  assert {
    condition     = output.service_plan_id == "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-output-test-dev-001/providers/Microsoft.Web/serverFarms/asp-output-test-dev-001"
    error_message = "service_plan_id should match the input variable"
  }

  assert {
    condition     = output.resource_group_name == "rg-output-test-dev-001"
    error_message = "resource_group_name should match the input variable"
  }

  assert {
    condition     = output.location == "East US"
    error_message = "location should match the input variable"
  }

  assert {
    condition     = output.workload == "out"
    error_message = "workload should match the input variable"
  }

  assert {
    condition     = output.environment == "dev"
    error_message = "environment should match the input variable"
  }

  # Test diagnostic settings
  assert {
    condition     = output.diagnostic_settings_enabled == false
    error_message = "diagnostic_settings_enabled should match the input variable"
  }

  # Test tags
  assert {
    condition     = length(output.tags) == 2
    error_message = "tags should contain the provided tags"
  }

  assert {
    condition     = output.tags["Environment"] == "Development"
    error_message = "tags should contain the Environment tag"
  }

  assert {
    condition     = output.tags["Project"] == "Output Test"
    error_message = "tags should contain the Project tag"
  }

  # Test that outputs are properly structured
  # Note: We focus on configuration outputs that can be evaluated during plan phase
}

# Test outputs with Application Insights enabled
run "verify_outputs_with_application_insights" {
  command = apply

  variables {
    workload                                        = "appinsights-test"
    environment                                     = "prod"
    resource_group_name                             = "rg-appinsights-test-prod-001"
    location                                        = "West US 2"
    service_plan_id                                 = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-appinsights-test-prod-001/providers/Microsoft.Web/serverFarms/asp-appinsights-test-prod-001"
    os_type                                         = "Linux"
    runtime_name                                    = "node"
    runtime_version                                 = "18"
    functions_extension_version                     = "~4"
    enable_vnet_integration                         = true
    storage_account_tier                            = "Premium"
    storage_account_replication_type                = "GRS"
    storage_min_tls_version                         = "TLS1_2"
    storage_blob_delete_retention_days              = 30
    storage_container_delete_retention_days         = 7
    storage_sas_expiration_period                   = "7.00:00:00"
    storage_sas_expiration_action                   = "Log"
    enable_storage_network_rules                    = false
    storage_network_rules_default_action            = "Allow"
    storage_network_rules_bypass                    = ["AzureServices"]
    storage_network_rules_ip_rules                  = []
    storage_network_rules_subnet_ids                = []
    enable_application_insights                     = true
    application_insights_type                       = "web"
    application_insights_retention_days             = 365
    application_insights_sampling_percentage        = 75
    application_insights_disable_ip_masking         = true
    application_insights_local_auth_disabled        = true
    application_insights_internet_ingestion_enabled = false
    application_insights_internet_query_enabled     = false
    log_analytics_workspace_id                      = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-monitoring/providers/Microsoft.OperationalInsights/workspaces/law-appinsights"
    https_only                                      = true
    client_certificate_enabled                      = true
    client_certificate_mode                         = "Optional"
    public_network_access_enabled                   = false
    scm_minimum_tls_version                         = "1.2"
    always_on                                       = true
    pre_warmed_instance_count                       = 2
    elastic_instance_minimum                        = 1
    function_app_scale_limit                        = 100
    worker_count                                    = 2
    use_32_bit_worker                               = false
    deployment_slots = {
      staging = {
        name = "staging"
      }
      testing = {
        name = "testing"
      }
    }
    vnet_integration_subnet_id  = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-appinsights/subnets/subnet-functions"
    websockets_enabled          = true
    remote_debugging_enabled    = false
    remote_debugging_version    = "VS2022"
    enable_cors                 = true
    cors_allowed_origins        = ["https://example.com", "https://app.example.com"]
    cors_support_credentials    = true
    use_dotnet_isolated_runtime = false
    enable_diagnostic_settings  = true
    tags = {
      Environment = "Production"
      Project     = "Application Insights Test"
      CostCenter  = "IT"
    }
  }

  # Test Application Insights outputs are populated when enabled
  assert {
    condition     = output.application_insights_id != null
    error_message = "application_insights_id should not be null when Application Insights is enabled"
  }

  assert {
    condition     = output.application_insights_name != null
    error_message = "application_insights_name should not be null when Application Insights is enabled"
  }

  assert {
    condition     = output.application_insights_instrumentation_key != null
    error_message = "application_insights_instrumentation_key should not be null when Application Insights is enabled"
  }

  assert {
    condition     = output.application_insights_connection_string != null
    error_message = "application_insights_connection_string should not be null when Application Insights is enabled"
  }

  assert {
    condition     = output.application_insights_app_id != null
    error_message = "application_insights_app_id should not be null when Application Insights is enabled"
  }

  # Test VNet integration outputs when enabled
  assert {
    condition     = output.vnet_integration_enabled == true
    error_message = "vnet_integration_enabled should be true when VNet integration is enabled"
  }

  assert {
    condition     = output.vnet_integration_subnet_id == "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-appinsights/subnets/subnet-functions"
    error_message = "vnet_integration_subnet_id should match the input variable when VNet integration is enabled"
  }

  # Test deployment slots outputs
  assert {
    condition     = length(output.deployment_slot_names) == 2
    error_message = "deployment_slot_names should contain 2 slots when configured"
  }

  assert {
    condition     = output.deployment_slot_count == 2
    error_message = "deployment_slot_count should be 2 when 2 slots are configured"
  }

  assert {
    condition     = contains(output.deployment_slot_names, "staging")
    error_message = "deployment_slot_names should contain 'staging' slot"
  }

  assert {
    condition     = contains(output.deployment_slot_names, "testing")
    error_message = "deployment_slot_names should contain 'testing' slot"
  }

  # Test runtime configuration with Node.js
  assert {
    condition     = output.runtime_configuration.runtime_name == "node"
    error_message = "runtime_configuration.runtime_name should be 'node'"
  }

  assert {
    condition     = output.runtime_configuration.runtime_version == "18"
    error_message = "runtime_configuration.runtime_version should be '18'"
  }

  # Test performance configuration with custom values
  assert {
    condition     = output.performance_configuration.always_on == true
    error_message = "performance_configuration.always_on should be true when enabled"
  }

  assert {
    condition     = output.performance_configuration.pre_warmed_instance_count == 2
    error_message = "performance_configuration.pre_warmed_instance_count should be 2 when specified"
  }

  assert {
    condition     = output.performance_configuration.elastic_instance_minimum == 1
    error_message = "performance_configuration.elastic_instance_minimum should be 1 when specified"
  }

  assert {
    condition     = output.performance_configuration.function_app_scale_limit == 100
    error_message = "performance_configuration.function_app_scale_limit should be 100 when specified"
  }

  assert {
    condition     = output.performance_configuration.worker_count == 2
    error_message = "performance_configuration.worker_count should be 2 when specified"
  }

  # Test network configuration with CORS enabled
  assert {
    condition     = output.network_configuration.enable_cors == true
    error_message = "network_configuration.enable_cors should be true when enabled"
  }

  assert {
    condition     = length(output.network_configuration.cors_allowed_origins) == 2
    error_message = "network_configuration.cors_allowed_origins should contain 2 origins when specified"
  }

  assert {
    condition     = contains(output.network_configuration.cors_allowed_origins, "https://example.com")
    error_message = "network_configuration.cors_allowed_origins should contain 'https://example.com'"
  }

  assert {
    condition     = contains(output.network_configuration.cors_allowed_origins, "https://app.example.com")
    error_message = "network_configuration.cors_allowed_origins should contain 'https://app.example.com'"
  }

  assert {
    condition     = output.network_configuration.cors_support_credentials == true
    error_message = "network_configuration.cors_support_credentials should be true when enabled"
  }

  assert {
    condition     = output.network_configuration.websockets_enabled == true
    error_message = "network_configuration.websockets_enabled should be true when enabled"
  }

  # Test diagnostic settings
  assert {
    condition     = output.diagnostic_settings_enabled == true
    error_message = "diagnostic_settings_enabled should be true when enabled"
  }

  # Test tags with multiple values
  assert {
    condition     = length(output.tags) == 3
    error_message = "tags should contain 3 tags when provided"
  }

  assert {
    condition     = output.tags["Environment"] == "Production"
    error_message = "tags should contain the Environment tag with correct value"
  }

  assert {
    condition     = output.tags["Project"] == "Application Insights Test"
    error_message = "tags should contain the Project tag with correct value"
  }

  assert {
    condition     = output.tags["CostCenter"] == "IT"
    error_message = "tags should contain the CostCenter tag with correct value"
  }
}

# Test output format validation
run "verify_output_formats" {
  command = plan

  variables {
    workload                                        = "format-test"
    environment                                     = "test"
    resource_group_name                             = "rg-format-test-test-001"
    location                                        = "Central US"
    service_plan_id                                 = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-format-test-test-001/providers/Microsoft.Web/serverFarms/asp-format-test-test-001"
    os_type                                         = "Linux"
    runtime_name                                    = "dotnet"
    runtime_version                                 = "6.0"
    functions_extension_version                     = "~4"
    enable_vnet_integration                         = false
    storage_account_tier                            = "Standard"
    storage_account_replication_type                = "LRS"
    storage_min_tls_version                         = "TLS1_2"
    storage_blob_delete_retention_days              = 7
    storage_container_delete_retention_days         = 0
    storage_sas_expiration_period                   = null
    storage_sas_expiration_action                   = "Log"
    enable_storage_network_rules                    = false
    storage_network_rules_default_action            = "Allow"
    storage_network_rules_bypass                    = ["AzureServices"]
    storage_network_rules_ip_rules                  = []
    storage_network_rules_subnet_ids                = []
    enable_application_insights                     = false
    application_insights_type                       = "web"
    application_insights_retention_days             = 90
    application_insights_sampling_percentage        = 100
    application_insights_disable_ip_masking         = false
    application_insights_local_auth_disabled        = true
    application_insights_internet_ingestion_enabled = true
    application_insights_internet_query_enabled     = true
    log_analytics_workspace_id                      = null
    https_only                                      = true
    client_certificate_enabled                      = false
    client_certificate_mode                         = "Required"
    public_network_access_enabled                   = false
    scm_minimum_tls_version                         = "1.2"
    always_on                                       = false
    pre_warmed_instance_count                       = 0
    elastic_instance_minimum                        = 0
    function_app_scale_limit                        = 200
    worker_count                                    = 1
    use_32_bit_worker                               = false
    deployment_slots                                = {}
    vnet_integration_subnet_id                      = null
    websockets_enabled                              = false
    remote_debugging_enabled                        = false
    remote_debugging_version                        = "VS2019"
    enable_cors                                     = false
    cors_allowed_origins                            = []
    cors_support_credentials                        = false
    use_dotnet_isolated_runtime                     = true
    enable_diagnostic_settings                      = false
    tags                                            = {}
  }


  # NOTE: The following format assertions are commented out because the mock provider returns random strings for resource outputs.
  # These checks are only meaningful when running against real Azure resources.
  #
  # assert {
  #   condition     = can(regex("^func-format-test-test-centralus-001$", output.function_app_name))
  #   error_message = "function_app_name should follow the expected naming pattern"
  # }
  #
  # assert {
  #   condition     = can(regex("^/subscriptions/.*/resourceGroups/.*/providers/Microsoft.Web/sites/.*$", output.function_app_id))
  #   error_message = "function_app_id should follow the expected Azure resource ID format"
  # }
  #
  # assert {
  #   condition     = can(regex(".*\\.azurewebsites\\.net$", output.function_app_default_hostname))
  #   error_message = "function_app_default_hostname should end with .azurewebsites.net"
  # }
  #
  # assert {
  #   condition     = can(regex("^https://.*\\.table\\.core\\.windows\\.net/$", output.storage_account_primary_table_endpoint))
  #   error_message = "storage_account_primary_table_endpoint should follow the expected format"
  # }
  #
  # assert {
  #   condition     = can(regex("^https://.*\\.file\\.core\\.windows\\.net/$", output.storage_account_primary_file_endpoint))
  #   error_message = "storage_account_primary_file_endpoint should follow the expected format"
  # }

  # Test .NET isolated runtime configuration
  assert {
    condition     = output.runtime_configuration.use_dotnet_isolated_runtime == true
    error_message = "runtime_configuration.use_dotnet_isolated_runtime should be true when specified"
  }

  assert {
    condition     = output.runtime_configuration.runtime_name == "dotnet"
    error_message = "runtime_configuration.runtime_name should be 'dotnet'"
  }

  assert {
    condition     = output.runtime_configuration.runtime_version == "6.0"
    error_message = "runtime_configuration.runtime_version should be '6.0'"
  }
}
