# Validation tests for container-instances module
# Tests input validation and error handling

# Mock the AzureRM provider to avoid authentication requirements
mock_provider "azurerm" {}

# Test invalid OS type rejection
run "invalid_os_type" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    os_type             = "InvalidOS"
    containers = [
      {
        name   = "test-container"
        image  = "nginx:latest"
        cpu    = 0.5
        memory = 1.0
      }
    ]
  }

  expect_failures = [
    var.os_type,
  ]
}

# Test invalid restart policy rejection
run "invalid_restart_policy" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    restart_policy      = "InvalidPolicy"
    containers = [
      {
        name   = "test-container"
        image  = "nginx:latest"
        cpu    = 0.5
        memory = 1.0
      }
    ]
  }

  expect_failures = [
    var.restart_policy,
  ]
}

# Test invalid IP address type rejection
run "invalid_ip_address_type" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    ip_address_type     = "InvalidType"
    containers = [
      {
        name   = "test-container"
        image  = "nginx:latest"
        cpu    = 0.5
        memory = 1.0
      }
    ]
  }

  expect_failures = [
    var.ip_address_type,
  ]
}

# Test invalid DNS name label reuse policy rejection
run "invalid_dns_reuse_policy" {
  command = plan

  variables {
    workload                    = "test"
    environment                 = "dev"
    resource_group_name         = "rg-test-dev-001"
    location                    = "East US"
    dns_name_label_reuse_policy = "InvalidPolicy"
    containers = [
      {
        name   = "test-container"
        image  = "nginx:latest"
        cpu    = 0.5
        memory = 1.0
      }
    ]
  }

  expect_failures = [
    var.dns_name_label_reuse_policy,
  ]
}

# Test invalid identity type rejection
run "invalid_identity_type" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    identity_type       = "InvalidIdentity"
    containers = [
      {
        name   = "test-container"
        image  = "nginx:latest"
        cpu    = 0.5
        memory = 1.0
      }
    ]
  }

  expect_failures = [
    var.identity_type,
  ]
}

# Test invalid priority rejection
run "invalid_priority" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    priority            = "InvalidPriority"
    containers = [
      {
        name   = "test-container"
        image  = "nginx:latest"
        cpu    = 0.5
        memory = 1.0
      }
    ]
  }

  expect_failures = [
    var.priority,
  ]
}

# Test valid OS types acceptance
run "valid_os_types" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    os_type             = "Linux"
    containers = [
      {
        name   = "test-container"
        image  = "nginx:latest"
        cpu    = 0.5
        memory = 1.0
      }
    ]
    tags = {}
  }

  assert {
    condition     = azurerm_container_group.main.os_type == "Linux"
    error_message = "Linux OS type should be accepted"
  }
}

run "valid_windows_os_type" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    os_type             = "Windows"
    containers = [
      {
        name   = "test-container"
        image  = "mcr.microsoft.com/windows/nanoserver:ltsc2019"
        cpu    = 1.0
        memory = 2.0
      }
    ]
    tags = {}
  }

  assert {
    condition     = azurerm_container_group.main.os_type == "Windows"
    error_message = "Windows OS type should be accepted"
  }
}

# Test valid restart policies acceptance
run "valid_restart_policies" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    restart_policy      = "OnFailure"
    containers = [
      {
        name   = "test-container"
        image  = "nginx:latest"
        cpu    = 0.5
        memory = 1.0
      }
    ]
    tags = {}
  }

  assert {
    condition     = azurerm_container_group.main.restart_policy == "OnFailure"
    error_message = "OnFailure restart policy should be accepted"
  }
}

run "valid_never_restart_policy" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    restart_policy      = "Never"
    containers = [
      {
        name   = "test-container"
        image  = "nginx:latest"
        cpu    = 0.5
        memory = 1.0
      }
    ]
    tags = {}
  }

  assert {
    condition     = azurerm_container_group.main.restart_policy == "Never"
    error_message = "Never restart policy should be accepted"
  }
}

# Test valid IP address types acceptance
run "valid_ip_address_types" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    ip_address_type     = "Private"
    containers = [
      {
        name   = "test-container"
        image  = "nginx:latest"
        cpu    = 0.5
        memory = 1.0
      }
    ]
    tags = {}
  }

  assert {
    condition     = azurerm_container_group.main.ip_address_type == "Private"
    error_message = "Private IP address type should be accepted"
  }
}

run "valid_none_ip_address_type" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    ip_address_type     = "None"
    containers = [
      {
        name   = "test-container"
        image  = "nginx:latest"
        cpu    = 0.5
        memory = 1.0
      }
    ]
    tags = {}
  }

  assert {
    condition     = azurerm_container_group.main.ip_address_type == "None"
    error_message = "None IP address type should be accepted"
  }
}

# Test valid DNS reuse policies acceptance
run "valid_dns_reuse_policies" {
  command = plan

  variables {
    workload                    = "test"
    environment                 = "dev"
    resource_group_name         = "rg-test-dev-001"
    location                    = "East US"
    dns_name_label_reuse_policy = "TenantReuse"
    containers = [
      {
        name   = "test-container"
        image  = "nginx:latest"
        cpu    = 0.5
        memory = 1.0
      }
    ]
    tags = {}
  }

  assert {
    condition     = var.dns_name_label_reuse_policy == "TenantReuse"
    error_message = "TenantReuse DNS policy should be accepted"
  }
}

# Test valid identity types acceptance
run "valid_identity_types" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    identity_type       = "SystemAssigned"
    containers = [
      {
        name   = "test-container"
        image  = "nginx:latest"
        cpu    = 0.5
        memory = 1.0
      }
    ]
    tags = {}
  }

  assert {
    condition     = azurerm_container_group.main.identity[0].type == "SystemAssigned"
    error_message = "SystemAssigned identity type should be accepted"
  }
}

run "valid_user_assigned_identity" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    identity_type       = "UserAssigned"
    identity_ids        = ["/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/test-identity"]
    containers = [
      {
        name   = "test-container"
        image  = "nginx:latest"
        cpu    = 0.5
        memory = 1.0
      }
    ]
    tags = {}
  }

  assert {
    condition     = azurerm_container_group.main.identity[0].type == "UserAssigned"
    error_message = "UserAssigned identity type should be accepted"
  }

  assert {
    condition     = length(azurerm_container_group.main.identity[0].identity_ids) == 1
    error_message = "User assigned identity IDs should be configured"
  }
}

# Test valid priority types acceptance
run "valid_priority_types" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    priority            = "Spot"
    containers = [
      {
        name   = "test-container"
        image  = "nginx:latest"
        cpu    = 0.5
        memory = 1.0
      }
    ]
    tags = {}
  }

  assert {
    condition     = azurerm_container_group.main.priority == "Spot"
    error_message = "Spot priority should be accepted"
  }
}

# Test container configuration validation
run "container_resource_limits" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    containers = [
      {
        name   = "resource-test"
        image  = "nginx:latest"
        cpu    = 4.0
        memory = 16.0
        ports = [
          {
            port     = 80
            protocol = "TCP"
          },
          {
            port     = 443
            protocol = "UDP"
          }
        ]
        environment_variables = {
          "TEST_VAR1" = "value1"
          "TEST_VAR2" = "value2"
        }
        secure_environment_variables = {
          "SECRET_VAR" = "secret-value"
        }
        commands = ["nginx", "-g", "daemon off;"]
      }
    ]
    tags = {}
  }

  assert {
    condition     = azurerm_container_group.main.container[0].cpu == 4.0
    error_message = "High CPU allocation should be accepted"
  }

  assert {
    condition     = azurerm_container_group.main.container[0].memory == 16.0
    error_message = "High memory allocation should be accepted"
  }

  assert {
    condition     = length(azurerm_container_group.main.container[0].ports) == 2
    error_message = "Multiple ports should be supported"
  }

  assert {
    condition     = length(azurerm_container_group.main.container[0].environment_variables) == 2
    error_message = "Multiple environment variables should be supported"
  }

  assert {
    condition     = length(azurerm_container_group.main.container[0].secure_environment_variables) == 1
    error_message = "Secure environment variables should be supported"
  }

  assert {
    condition     = length(azurerm_container_group.main.container[0].commands) == 3
    error_message = "Custom commands should be supported"
  }
}

# Test empty containers list validation
run "empty_containers_list" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    containers          = []
    tags                = {}
  }

  expect_failures = [
    var.containers,
  ]
}

# Test zone configuration validation
run "availability_zones" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    resource_group_name = "rg-test-dev-001"
    location            = "East US"
    zones               = ["1", "2", "3"]
    containers = [
      {
        name   = "test-container"
        image  = "nginx:latest"
        cpu    = 0.5
        memory = 1.0
      }
    ]
    tags = {}
  }

  assert {
    condition     = length(azurerm_container_group.main.zones) == 3
    error_message = "Multiple availability zones should be supported"
  }

  assert {
    condition     = contains(azurerm_container_group.main.zones, "1")
    error_message = "Zone 1 should be included"
  }

  assert {
    condition     = contains(azurerm_container_group.main.zones, "2")
    error_message = "Zone 2 should be included"
  }

  assert {
    condition     = contains(azurerm_container_group.main.zones, "3")
    error_message = "Zone 3 should be included"
  }
}

# Test diagnostic settings validation
run "diagnostic_settings_validation" {
  command = plan

  variables {
    workload                   = "test"
    environment                = "dev"
    resource_group_name        = "rg-test-dev-001"
    location                   = "East US"
    enable_diagnostic_settings = true
    log_analytics_workspace_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-monitoring/providers/Microsoft.OperationalInsights/workspaces/law-test"
    diagnostic_logs            = ["ContainerInstanceLog"]
    diagnostic_metrics         = ["AllMetrics"]
    containers = [
      {
        name   = "test-container"
        image  = "nginx:latest"
        cpu    = 0.5
        memory = 1.0
      }
    ]
    tags = {}
  }

  assert {
    condition     = length(azurerm_monitor_diagnostic_setting.container_group) == 1
    error_message = "Diagnostic settings should be created when enabled"
  }

  assert {
    condition     = azurerm_monitor_diagnostic_setting.container_group[0].log_analytics_workspace_id == "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-monitoring/providers/Microsoft.OperationalInsights/workspaces/law-test"
    error_message = "Log Analytics workspace ID should be configured correctly"
  }
}

# Test diagnostic settings disabled
run "diagnostic_settings_disabled" {
  command = plan

  variables {
    workload                   = "test"
    environment                = "dev"
    resource_group_name        = "rg-test-dev-001"
    location                   = "East US"
    enable_diagnostic_settings = false
    containers = [
      {
        name   = "test-container"
        image  = "nginx:latest"
        cpu    = 0.5
        memory = 1.0
      }
    ]
    tags = {}
  }

  assert {
    condition     = length(azurerm_monitor_diagnostic_setting.container_group) == 0
    error_message = "Diagnostic settings should not be created when disabled"
  }
}
