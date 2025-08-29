# Basic functionality tests for function-app module
# Tests the core functionality of creating an Azure Function App with storage and optional Application Insights

# Mock the AzureRM provider to avoid authentication requirements
mock_provider "azurerm" {}

# Test basic Linux Function App creation with default values
run "basic_linux_function_app_creation" {
  command = plan

  variables {
    workload                                        = "test"
    environment                                     = "dev"
    resource_group_name                             = "rg-test-dev-001"
    location                                        = "East US"
    service_plan_id                                 = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test-dev-001/providers/Microsoft.Web/serverFarms/asp-test-dev-001"
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
      Project     = "Test"
    }
  }

  # Verify the Function App is created with correct attributes
  assert {
    condition     = azurerm_linux_function_app.main[0].name == "func-test-dev-eastus-001"
    error_message = "Function App name should follow the naming convention"
  }

  assert {
    condition     = azurerm_linux_function_app.main[0].resource_group_name == "rg-test-dev-001"
    error_message = "Resource group name should match the input variable"
  }

  assert {
    condition     = azurerm_linux_function_app.main[0].location == "East US"
    error_message = "Location should match the input variable"
  }

  assert {
    condition     = azurerm_linux_function_app.main[0].https_only == true
    error_message = "HTTPS only should be enabled by default"
  }

  assert {
    condition     = azurerm_linux_function_app.main[0].public_network_access_enabled == false
    error_message = "Public network access should be disabled by default"
  }

  # Verify storage account creation
  assert {
    condition     = azurerm_storage_account.functions.name == "stfunctestdeveastus001"
    error_message = "Storage account name should follow the naming convention"
  }

  assert {
    condition     = azurerm_storage_account.functions.account_tier == "Standard"
    error_message = "Storage account tier should match the input variable"
  }

  assert {
    condition     = azurerm_storage_account.functions.account_replication_type == "LRS"
    error_message = "Storage account replication type should match the input variable"
  }

  assert {
    condition     = azurerm_storage_account.functions.min_tls_version == "TLS1_2"
    error_message = "Storage account should enforce minimum TLS 1.2"
  }

  assert {
    condition     = azurerm_storage_account.functions.allow_nested_items_to_be_public == false
    error_message = "Storage account should not allow public nested items"
  }

  assert {
    condition     = azurerm_storage_account.functions.shared_access_key_enabled == true
    error_message = "Storage account should have shared access key enabled for Function Apps"
  }

  assert {
    condition     = azurerm_storage_account.functions.public_network_access_enabled == false
    error_message = "Storage account should have public network access disabled"
  }
}

# Test Windows Function App creation
run "windows_function_app_creation" {
  command = plan

  variables {
    workload                                        = "wintest"
    environment                                     = "prod"
    resource_group_name                             = "rg-wintest-prod-001"
    location                                        = "West US 2"
    service_plan_id                                 = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-wintest-prod-001/providers/Microsoft.Web/serverFarms/asp-wintest-prod-001"
    os_type                                         = "Windows"
    runtime_name                                    = "dotnet"
    runtime_version                                 = "6.0"
    functions_extension_version                     = "~4"
    enable_vnet_integration                         = false
    storage_account_tier                            = "Premium"
    storage_account_replication_type                = "GRS"
    storage_min_tls_version                         = "TLS1_2"
    storage_blob_delete_retention_days              = 30
    storage_container_delete_retention_days         = 7
    storage_sas_expiration_period                   = "1.00:00:00"
    storage_sas_expiration_action                   = "Log"
    enable_storage_network_rules                    = true
    storage_network_rules_default_action            = "Deny"
    storage_network_rules_bypass                    = ["AzureServices", "Logging"]
    storage_network_rules_ip_rules                  = ["203.0.113.0/24"]
    storage_network_rules_subnet_ids                = ["/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet-functions"]
    enable_application_insights                     = true
    application_insights_type                       = "web"
    application_insights_retention_days             = 365
    application_insights_sampling_percentage        = 50
    application_insights_disable_ip_masking         = true
    application_insights_local_auth_disabled        = true
    application_insights_internet_ingestion_enabled = false
    application_insights_internet_query_enabled     = false
    log_analytics_workspace_id                      = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-monitoring/providers/Microsoft.OperationalInsights/workspaces/law-test"
    https_only                                      = true
    client_certificate_enabled                      = true
    client_certificate_mode                         = "Required"
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
    }
    vnet_integration_subnet_id  = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet-integration"
    websockets_enabled          = true
    remote_debugging_enabled    = false
    remote_debugging_version    = "VS2022"
    enable_cors                 = true
    cors_allowed_origins        = ["https://example.com", "https://app.example.com"]
    cors_support_credentials    = true
    use_dotnet_isolated_runtime = true
    enable_diagnostic_settings  = true
    tags = {
      Environment = "Production"
      Project     = "Windows Functions"
      CostCenter  = "IT"
    }
  }

  # Note: This test validates Windows configuration but the module only creates Linux Function Apps
  # The test verifies that the storage account and Application Insights are created correctly

  # Verify storage account with premium configuration
  assert {
    condition     = azurerm_storage_account.functions.name == "stfuncwintesprowestus001"
    error_message = "Storage account name should follow the naming convention for Windows workload"
  }

  assert {
    condition     = azurerm_storage_account.functions.account_tier == "Premium"
    error_message = "Storage account tier should be Premium when specified"
  }

  assert {
    condition     = azurerm_storage_account.functions.account_replication_type == "GRS"
    error_message = "Storage account replication type should be GRS when specified"
  }

  # Verify Application Insights is created when enabled
  assert {
    condition     = azurerm_application_insights.functions[0].name == "appi-wintest-functions-prod-westus2-001"
    error_message = "Application Insights name should follow the naming convention"
  }

  assert {
    condition     = azurerm_application_insights.functions[0].application_type == "web"
    error_message = "Application Insights type should match the input variable"
  }

  assert {
    condition     = azurerm_application_insights.functions[0].retention_in_days == 365
    error_message = "Application Insights retention should match the input variable"
  }

  assert {
    condition     = azurerm_application_insights.functions[0].sampling_percentage == 50
    error_message = "Application Insights sampling percentage should match the input variable"
  }

  assert {
    condition     = azurerm_application_insights.functions[0].disable_ip_masking == true
    error_message = "Application Insights IP masking should be disabled when specified"
  }

  assert {
    condition     = azurerm_application_insights.functions[0].local_authentication_disabled == true
    error_message = "Application Insights local auth should be disabled for security"
  }

  assert {
    condition     = length(azurerm_storage_account.functions.tags) == 3
    error_message = "Tags should be applied when provided"
  }
}

# Test with Node.js runtime
run "nodejs_function_app" {
  command = plan

  variables {
    workload                                        = "nodeapp"
    environment                                     = "test"
    resource_group_name                             = "rg-nodeapp-test-001"
    location                                        = "Central US"
    service_plan_id                                 = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-nodeapp-test-001/providers/Microsoft.Web/serverFarms/asp-nodeapp-test-001"
    os_type                                         = "Linux"
    runtime_name                                    = "node"
    runtime_version                                 = "18"
    functions_extension_version                     = "~4"
    enable_vnet_integration                         = true
    storage_account_tier                            = "Standard"
    storage_account_replication_type                = "ZRS"
    storage_min_tls_version                         = "TLS1_2"
    storage_blob_delete_retention_days              = 14
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
    application_insights_retention_days             = 180
    application_insights_sampling_percentage        = 75
    application_insights_disable_ip_masking         = false
    application_insights_local_auth_disabled        = true
    application_insights_internet_ingestion_enabled = true
    application_insights_internet_query_enabled     = true
    log_analytics_workspace_id                      = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-monitoring/providers/Microsoft.OperationalInsights/workspaces/law-nodeapp"
    https_only                                      = true
    client_certificate_enabled                      = false
    client_certificate_mode                         = "Optional"
    public_network_access_enabled                   = false
    scm_minimum_tls_version                         = "1.2"
    always_on                                       = false
    pre_warmed_instance_count                       = 1
    elastic_instance_minimum                        = 0
    function_app_scale_limit                        = 50
    worker_count                                    = 1
    use_32_bit_worker                               = false
    deployment_slots                                = {}
    vnet_integration_subnet_id                      = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-nodeapp/subnets/subnet-functions"
    websockets_enabled                              = false
    remote_debugging_enabled                        = true
    remote_debugging_version                        = "VS2019"
    enable_cors                                     = false
    cors_allowed_origins                            = []
    cors_support_credentials                        = false
    use_dotnet_isolated_runtime                     = false
    enable_diagnostic_settings                      = false
    tags = {
      Environment = "Test"
      Runtime     = "Node.js"
    }
  }

  # Verify Function App with Node.js configuration
  assert {
    condition     = azurerm_linux_function_app.main[0].name == "func-nodeapp-test-centralus-001"
    error_message = "Function App name should follow the naming convention for Node.js app"
  }

  # Verify storage account with ZRS replication
  assert {
    condition     = azurerm_storage_account.functions.account_replication_type == "ZRS"
    error_message = "Storage account should use ZRS replication when specified"
  }

  # Verify Application Insights configuration
  assert {
    condition     = azurerm_application_insights.functions[0].retention_in_days == 180
    error_message = "Application Insights retention should be 180 days when specified"
  }

  assert {
    condition     = azurerm_application_insights.functions[0].sampling_percentage == 75
    error_message = "Application Insights sampling should be 75% when specified"
  }
}

# Test storage account blob properties
run "storage_blob_properties" {
  command = plan

  variables {
    workload                                        = "storage"
    environment                                     = "dev"
    resource_group_name                             = "rg-storage-dev-001"
    location                                        = "East US 2"
    service_plan_id                                 = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-storage-dev-001/providers/Microsoft.Web/serverFarms/asp-storage-dev-001"
    os_type                                         = "Linux"
    runtime_name                                    = "python"
    runtime_version                                 = "3.9"
    functions_extension_version                     = "~4"
    enable_vnet_integration                         = false
    storage_account_tier                            = "Standard"
    storage_account_replication_type                = "LRS"
    storage_min_tls_version                         = "TLS1_2"
    storage_blob_delete_retention_days              = 30
    storage_container_delete_retention_days         = 14
    storage_sas_expiration_period                   = "30.00:00:00"
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
    tags                                            = {}
  }

  # Verify blob retention policies
  assert {
    condition     = azurerm_storage_account.functions.blob_properties[0].delete_retention_policy[0].days == 30
    error_message = "Blob delete retention should be 30 days when specified"
  }

  assert {
    condition     = azurerm_storage_account.functions.blob_properties[0].container_delete_retention_policy[0].days == 14
    error_message = "Container delete retention should be 14 days when specified"
  }

  # Verify SAS policy
  assert {
    condition     = azurerm_storage_account.functions.sas_policy[0].expiration_period == "30.00:00:00"
    error_message = "SAS expiration period should be 30 days when specified"
  }

  assert {
    condition     = azurerm_storage_account.functions.sas_policy[0].expiration_action == "Log"
    error_message = "SAS expiration action should be Log when specified"
  }
}
