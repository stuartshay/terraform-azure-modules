# Validation tests for function-app module
# Tests input validation rules and error conditions

# Mock the AzureRM provider to avoid authentication requirements
mock_provider "azurerm" {}

# Test invalid OS type validation
run "invalid_os_type" {
  command = plan

  variables {
    workload                                        = "test"
    environment                                     = "dev"
    resource_group_name                             = "rg-test-dev-001"
    location                                        = "East US"
    service_plan_id                                 = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test-dev-001/providers/Microsoft.Web/serverFarms/asp-test-dev-001"
    os_type                                         = "InvalidOS"
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
    tags                                            = {}
  }

  expect_failures = [
    var.os_type,
  ]

  # Verify that Function App outputs are null when OS type is invalid
  assert {
    condition     = output.function_app_id == null
    error_message = "function_app_id should be null when OS type is invalid"
  }

  assert {
    condition     = output.function_app_name == null
    error_message = "function_app_name should be null when OS type is invalid"
  }
}

# Test invalid storage account tier
run "invalid_storage_tier" {
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
    storage_account_tier                            = "InvalidTier"
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
    tags                                            = {}
  }

  expect_failures = [
    var.storage_account_tier,
  ]
}

# Test invalid storage replication type
run "invalid_storage_replication" {
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
    storage_account_replication_type                = "INVALID"
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
    tags                                            = {}
  }

  expect_failures = [
    var.storage_account_replication_type,
  ]
}

# Test invalid TLS version
run "invalid_tls_version" {
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
    storage_min_tls_version                         = "TLS1_INVALID"
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
    tags                                            = {}
  }

  expect_failures = [
    var.storage_min_tls_version,
  ]
}

# Test invalid SAS expiration action
run "invalid_sas_expiration_action" {
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
    storage_sas_expiration_action                   = "InvalidAction"
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

  expect_failures = [
    var.storage_sas_expiration_action,
  ]
}

# Test boundary condition - negative retention days
run "negative_blob_retention_days" {
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
    storage_blob_delete_retention_days              = -1
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
    tags                                            = {}
  }

  expect_failures = [
    var.storage_blob_delete_retention_days,
  ]
}

# Test boundary condition - excessive retention days
run "excessive_blob_retention_days" {
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
    storage_blob_delete_retention_days              = 400
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
    tags                                            = {}
  }

  expect_failures = [
    var.storage_blob_delete_retention_days,
  ]
}

# Test invalid Application Insights sampling percentage
run "invalid_sampling_percentage_below_zero" {
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
    enable_application_insights                     = true
    application_insights_type                       = "web"
    application_insights_retention_days             = 90
    application_insights_sampling_percentage        = -10
    application_insights_disable_ip_masking         = false
    application_insights_local_auth_disabled        = true
    application_insights_internet_ingestion_enabled = true
    application_insights_internet_query_enabled     = true
    log_analytics_workspace_id                      = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-monitoring/providers/Microsoft.OperationalInsights/workspaces/law-test"
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

  expect_failures = [
    var.application_insights_sampling_percentage,
  ]
}

# Test invalid Application Insights sampling percentage above 100
run "invalid_sampling_percentage_above_100" {
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
    enable_application_insights                     = true
    application_insights_type                       = "web"
    application_insights_retention_days             = 90
    application_insights_sampling_percentage        = 150
    application_insights_disable_ip_masking         = false
    application_insights_local_auth_disabled        = true
    application_insights_internet_ingestion_enabled = true
    application_insights_internet_query_enabled     = true
    log_analytics_workspace_id                      = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-monitoring/providers/Microsoft.OperationalInsights/workspaces/law-test"
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

  expect_failures = [
    var.application_insights_sampling_percentage,
  ]
}

# Test valid parameter values - all supported storage tiers
run "valid_storage_tiers" {
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
    storage_account_tier                            = "Premium"
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
    tags                                            = {}
  }

  assert {
    condition     = contains(["Standard", "Premium"], azurerm_storage_account.functions.account_tier)
    error_message = "Valid storage tier should be accepted"
  }
}

# Test valid replication types
run "valid_replication_types" {
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
    storage_account_replication_type                = "RAGRS"
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
    tags                                            = {}
  }

  assert {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], azurerm_storage_account.functions.account_replication_type)
    error_message = "Valid replication type should be accepted"
  }
}

# Test valid client certificate modes
run "valid_client_certificate_modes" {
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
    client_certificate_enabled                      = true
    client_certificate_mode                         = "Optional"
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

  assert {
    condition     = contains(["Required", "Optional"], azurerm_linux_function_app.main[0].client_certificate_mode)
    error_message = "Valid client certificate mode should be accepted"
  }
}
