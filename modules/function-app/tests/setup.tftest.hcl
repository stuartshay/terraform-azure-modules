# Setup and Documentation for function-app module tests
# This file provides documentation about the test structure and execution guidelines

# Mock the AzureRM provider to avoid authentication requirements
mock_provider "azurerm" {}

# This is a documentation-only test file that explains the test structure
# and provides guidance for running and maintaining the tests.

# Test Structure Overview:
#
# 1. basic.tftest.hcl - Basic functionality tests
#    - Tests core Function App creation with Linux OS
#    - Tests Windows Function App configuration (storage and Application Insights)
#    - Tests different runtime configurations (Python, Node.js, .NET)
#    - Tests storage account creation and configuration
#    - Tests Application Insights integration
#    - Tests naming conventions and default security settings
#
# 2. validation.tftest.hcl - Input validation tests
#    - Tests invalid parameter values (OS type, storage tier, replication type)
#    - Tests boundary conditions (negative values, excessive values)
#    - Tests TLS version validation
#    - Tests client certificate mode validation
#    - Tests Application Insights sampling percentage validation
#    - Tests valid parameter acceptance
#
# 3. outputs.tftest.hcl - Output validation tests
#    - Tests all Function App outputs are correctly populated
#    - Tests Storage Account outputs
#    - Tests Application Insights outputs (enabled and disabled states)
#    - Tests VNet integration outputs
#    - Tests deployment slots outputs
#    - Tests configuration summary outputs
#    - Tests output format validation
#
# 4. setup.tftest.hcl - This documentation file
#    - Provides test structure overview
#    - Documents test execution guidelines
#    - Explains provider mocking approach

# Provider Mocking:
# All test files use `mock_provider "azurerm" {}` to avoid requiring
# actual Azure authentication during test execution. This allows tests
# to run in CI/CD pipelines and local development environments without
# Azure credentials.

# Test Execution:
#
# Run all tests for the function-app module:
#   make terraform-test-module MODULE=function-app
#
# Or from the module directory:
#   cd modules/function-app
#   terraform test
#
# Run specific test files:
#   terraform test -filter=basic.tftest.hcl
#   terraform test -filter=validation.tftest.hcl
#   terraform test -filter=outputs.tftest.hcl

# Test Coverage:
#
# Basic Functionality Tests:
# ✅ Linux Function App creation with default values
# ✅ Windows Function App configuration testing
# ✅ Storage account creation and security configuration
# ✅ Application Insights integration (enabled/disabled)
# ✅ Different runtime configurations (Python, Node.js, .NET)
# ✅ Naming convention compliance
# ✅ Tag application and validation
# ✅ Storage blob properties and SAS policies
#
# Validation Tests:
# ✅ Invalid OS type rejection
# ✅ Invalid storage account tier rejection
# ✅ Invalid storage replication type rejection
# ✅ Invalid TLS version rejection
# ✅ Invalid client certificate mode rejection
# ✅ Boundary condition testing (retention days)
# ✅ Application Insights sampling percentage validation
# ✅ Valid parameter acceptance verification
#
# Output Tests:
# ✅ All Function App outputs populated correctly
# ✅ Storage Account outputs validation
# ✅ Application Insights outputs (conditional)
# ✅ VNet integration outputs
# ✅ Deployment slots outputs
# ✅ Configuration summary outputs
# ✅ Output format validation (naming patterns, URLs)
# ✅ Non-null/non-empty verification

# Module-Specific Test Considerations:
#
# 1. Conditional Resources:
#    The module creates either Linux or Windows Function Apps based on os_type.
#    Currently, the main.tf only implements Linux Function Apps, so Windows
#    tests focus on storage and Application Insights components.
#
# 2. Application Insights:
#    Tests cover both enabled and disabled states, ensuring outputs are
#    properly null when disabled and populated when enabled.
#
# 3. VNet Integration:
#    Tests validate both enabled and disabled VNet integration scenarios.
#
# 4. Storage Account:
#    Comprehensive testing of storage account configuration including
#    security settings, blob properties, SAS policies, and network rules.
#
# 5. Naming Conventions:
#    All tests validate that resource names follow the established
#    naming patterns defined in the locals block.

# Maintenance Guidelines:
#
# 1. When adding new variables to the module:
#    - Add validation tests in validation.tftest.hcl
#    - Add output tests in outputs.tftest.hcl if new outputs are added
#    - Add basic functionality tests in basic.tftest.hcl for new features
#
# 2. When modifying existing functionality:
#    - Update relevant assertions in all test files
#    - Ensure test data remains realistic and consistent
#
# 3. When adding new resources:
#    - Add comprehensive tests for the new resource
#    - Test both enabled and disabled states if conditional
#    - Validate all outputs for the new resource
#
# 4. Test Data Consistency:
#    - Use consistent naming patterns across all tests
#    - Use realistic Azure resource IDs and configurations
#    - Maintain consistent tag structures

# Documentation test to verify the test structure is valid
run "documentation_test" {
  command = plan

  variables {
    workload                                        = "docs"
    environment                                     = "test"
    resource_group_name                             = "rg-docs-test-001"
    location                                        = "East US"
    service_plan_id                                 = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-docs-test-001/providers/Microsoft.Web/serverFarms/asp-docs-test-001"
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
      Purpose  = "Documentation"
      TestFile = "setup.tftest.hcl"
    }
  }

  # Verify that the module can be planned with minimal configuration
  assert {
    condition     = azurerm_storage_account.functions.name == "stfuncdocsteseastus001"
    error_message = "Documentation test should create storage account with expected name"
  }

  # Verify tags are applied correctly
  assert {
    condition     = azurerm_storage_account.functions.tags["Purpose"] == "Documentation"
    error_message = "Documentation test tags should be applied correctly"
  }

  assert {
    condition     = azurerm_storage_account.functions.tags["TestFile"] == "setup.tftest.hcl"
    error_message = "Documentation test should include TestFile tag"
  }
}
