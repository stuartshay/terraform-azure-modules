# Service Bus Module - Basic Test
# Tests basic functionality of the Service Bus module

mock_provider "azurerm" {}

run "basic_service_bus_test" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    location            = "East US"
    location_short      = "eastus"
    resource_group_name = "rg-test"
    sku                 = "Standard"
    tags = {
      Environment = "test"
      ManagedBy   = "terraform"
    }
  }

  # Test that the Service Bus namespace is created with correct naming
  assert {
    condition     = azurerm_servicebus_namespace.main.name == "sb-test-dev-eastus-001"
    error_message = "Service Bus namespace name should follow naming convention: sb-{workload}-{environment}-{location_short}-001"
  }

  # Test that the SKU is set correctly
  assert {
    condition     = azurerm_servicebus_namespace.main.sku == "Standard"
    error_message = "Service Bus namespace SKU should be Standard"
  }

  # Test that public network access is enabled by default
  assert {
    condition     = azurerm_servicebus_namespace.main.public_network_access_enabled == true
    error_message = "Public network access should be enabled by default"
  }

  # Test that minimum TLS version is set to 1.2 by default
  assert {
    condition     = azurerm_servicebus_namespace.main.minimum_tls_version == "1.2"
    error_message = "Minimum TLS version should be 1.2 by default"
  }

  # Test that local auth is enabled by default
  assert {
    condition     = azurerm_servicebus_namespace.main.local_auth_enabled == true
    error_message = "Local authentication should be enabled by default"
  }

  # Test that no queues are created by default
  assert {
    condition     = length(azurerm_servicebus_queue.main) == 0
    error_message = "No queues should be created by default"
  }

  # Test that no topics are created by default
  assert {
    condition     = length(azurerm_servicebus_topic.main) == 0
    error_message = "No topics should be created by default"
  }

  # Test that no private endpoint is created by default
  assert {
    condition     = length(module.private_endpoint) == 0
    error_message = "No private endpoint should be created by default"
  }
}

run "premium_sku_test" {
  command = plan

  variables {
    workload                     = "test"
    environment                  = "prod"
    location                     = "East US"
    location_short               = "eastus"
    resource_group_name          = "rg-test"
    sku                          = "Premium"
    premium_messaging_units      = 2
    premium_messaging_partitions = 2
    tags = {
      Environment = "test"
      ManagedBy   = "terraform"
    }
  }

  # Test that Premium SKU settings are applied
  assert {
    condition     = azurerm_servicebus_namespace.main.sku == "Premium"
    error_message = "Service Bus namespace SKU should be Premium"
  }

  assert {
    condition     = azurerm_servicebus_namespace.main.capacity == 2
    error_message = "Premium messaging units should be set to 2"
  }

  assert {
    condition     = azurerm_servicebus_namespace.main.premium_messaging_partitions == 2
    error_message = "Premium messaging partitions should be set to 2"
  }
}

run "queues_and_topics_test" {
  command = plan

  variables {
    workload            = "test"
    environment         = "dev"
    location            = "East US"
    location_short      = "eastus"
    resource_group_name = "rg-test"
    sku                 = "Standard"

    queues = {
      "test-queue" = {
        max_size_in_megabytes = 2048
        max_delivery_count    = 5
      }
    }

    topics = {
      "test-topic" = {
        max_size_in_megabytes = 1024
        support_ordering      = true
      }
    }

    topic_subscriptions = {
      "test-subscription" = {
        name       = "test-sub"
        topic_name = "test-topic"
      }
    }

    tags = {
      Environment = "test"
      ManagedBy   = "terraform"
    }
  }

  # Test that queue is created with correct name
  assert {
    condition     = azurerm_servicebus_queue.main["test-queue"].name == "test-queue-dev"
    error_message = "Queue name should follow naming convention: {queue-name}-{environment}"
  }

  # Test that topic is created with correct name
  assert {
    condition     = azurerm_servicebus_topic.main["test-topic"].name == "test-topic-dev"
    error_message = "Topic name should follow naming convention: {topic-name}-{environment}"
  }

  # Test that subscription is created with correct name
  assert {
    condition     = azurerm_servicebus_subscription.main["test-subscription"].name == "test-sub-dev"
    error_message = "Subscription name should follow naming convention: {subscription-name}-{environment}"
  }
}
