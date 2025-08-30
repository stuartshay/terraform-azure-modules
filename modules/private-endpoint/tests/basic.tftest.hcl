# Basic Private Endpoint Module Test
# This test validates the basic functionality of the private endpoint module

# Mock the AzureRM provider to avoid authentication requirements
mock_provider "azurerm" {}

run "basic_private_endpoint" {
  command = plan

  variables {
    name                           = "pe-test-storage-blob"
    location                       = "East US"
    resource_group_name            = "rg-test-eastus-001"
    subnet_id                      = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test-eastus-001/providers/Microsoft.Network/virtualNetworks/vnet-test-eastus-001/subnets/snet-private-endpoints"
    private_connection_resource_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test-eastus-001/providers/Microsoft.Storage/storageAccounts/sttest001"
    subresource_names              = ["blob"]

    tags = {
      Environment = "test"
      Module      = "private-endpoint"
    }
  }

  assert {
    condition     = azurerm_private_endpoint.main.name == "pe-test-storage-blob"
    error_message = "Private endpoint name should match the input variable"
  }

  assert {
    condition     = azurerm_private_endpoint.main.location == "East US"
    error_message = "Private endpoint location should match the input variable"
  }

  assert {
    condition     = length(azurerm_private_endpoint.main.private_service_connection) == 1
    error_message = "Should have exactly one private service connection"
  }

  assert {
    condition     = azurerm_private_endpoint.main.private_service_connection[0].subresource_names[0] == "blob"
    error_message = "Subresource name should be 'blob'"
  }

  assert {
    condition     = azurerm_private_endpoint.main.private_service_connection[0].is_manual_connection == false
    error_message = "Manual connection should be disabled by default"
  }
}

run "private_endpoint_with_dns" {
  command = plan

  variables {
    name                           = "pe-test-servicebus-namespace"
    location                       = "East US"
    resource_group_name            = "rg-test-eastus-001"
    subnet_id                      = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test-eastus-001/providers/Microsoft.Network/virtualNetworks/vnet-test-eastus-001/subnets/snet-private-endpoints"
    private_connection_resource_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test-eastus-001/providers/Microsoft.ServiceBus/namespaces/sb-test-001"
    subresource_names              = ["namespace"]

    private_dns_zone_ids = [
      "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test-eastus-001/providers/Microsoft.Network/privateDnsZones/privatelink.servicebus.windows.net"
    ]

    tags = {
      Environment = "test"
      Module      = "private-endpoint"
    }
  }

  assert {
    condition     = length(azurerm_private_endpoint.main.private_dns_zone_group) == 1
    error_message = "Should have exactly one DNS zone group when DNS zones are provided"
  }

  assert {
    condition     = length(azurerm_private_endpoint.main.private_dns_zone_group[0].private_dns_zone_ids) == 1
    error_message = "Should have exactly one DNS zone ID"
  }
}

run "private_endpoint_with_custom_naming" {
  command = plan

  variables {
    name                           = "pe-custom-storage-file"
    location                       = "East US"
    resource_group_name            = "rg-test-eastus-001"
    subnet_id                      = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test-eastus-001/providers/Microsoft.Network/virtualNetworks/vnet-test-eastus-001/subnets/snet-private-endpoints"
    private_connection_resource_id = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test-eastus-001/providers/Microsoft.Storage/storageAccounts/sttest001"
    subresource_names              = ["file"]

    private_service_connection_name = "psc-custom-storage-file"
    private_dns_zone_group_name     = "pdzg-custom-storage-file"

    private_dns_zone_ids = [
      "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-test-eastus-001/providers/Microsoft.Network/privateDnsZones/privatelink.file.core.windows.net"
    ]

    tags = {
      Environment = "test"
      Module      = "private-endpoint"
    }
  }

  assert {
    condition     = azurerm_private_endpoint.main.private_service_connection[0].name == "psc-custom-storage-file"
    error_message = "Private service connection name should match custom input"
  }

  assert {
    condition     = azurerm_private_endpoint.main.private_dns_zone_group[0].name == "pdzg-custom-storage-file"
    error_message = "DNS zone group name should match custom input"
  }
}
