# Complete Service Bus Example
# This example creates a comprehensive Service Bus setup with queues, topics, private endpoint, and Key Vault integration

# Configure the Azure Provider
terraform {
  required_version = ">= 1.13.1"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.42.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

# Get current client configuration
data "azurerm_client_config" "current" {}

# Create a resource group for this example
resource "azurerm_resource_group" "example" {
  name     = "rg-servicebus-complete-example"
  location = "East US"
}

# Create a virtual network for private endpoint
resource "azurerm_virtual_network" "example" {
  #checkov:skip=CKV2_AZURE_18:NSG association not required for example
  name                = "vnet-servicebus-example"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  tags = {
    Environment = "dev"
    Purpose     = "example"
  }
}

# Create a subnet for private endpoints
resource "azurerm_subnet" "private_endpoints" {
  name                 = "snet-private-endpoints"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a private DNS zone for Service Bus
resource "azurerm_private_dns_zone" "servicebus" {
  name                = "privatelink.servicebus.windows.net"
  resource_group_name = azurerm_resource_group.example.name

  tags = {
    Environment = "dev"
    Purpose     = "example"
  }
}

# Link the private DNS zone to the virtual network
resource "azurerm_private_dns_zone_virtual_network_link" "servicebus" {
  name                  = "servicebus-dns-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.servicebus.name
  virtual_network_id    = azurerm_virtual_network.example.id
  registration_enabled  = false

  tags = {
    Environment = "dev"
    Purpose     = "example"
  }
}

# Create a Key Vault for storing connection strings
resource "azurerm_key_vault" "example" {
  #checkov:skip=CKV_AZURE_109:Network ACLs not required for example
  #checkov:skip=CKV2_AZURE_32:Private endpoint not required for example Key Vault
  name                = "kv-sb-example-${random_string.suffix.result}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  # Enable soft delete and purge protection
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  # Access policy for current user
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Recover",
      "Backup",
      "Restore",
      "Purge"
    ]
  }

  tags = {
    Environment = "dev"
    Purpose     = "example"
  }
}

# Random string for unique naming
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Log Analytics Workspace for diagnostic settings
resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-servicebus-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    Environment = "dev"
    Purpose     = "example"
  }
}

# Complete Service Bus setup with all features
module "service_bus" {
  source = "../../"

  # Required variables
  workload            = "example"
  environment         = "dev"
  location            = azurerm_resource_group.example.location
  location_short      = "eastus"
  resource_group_name = azurerm_resource_group.example.name

  # Service Bus configuration
  sku                     = "Premium"
  premium_messaging_units = 1

  # Network and security settings
  public_network_access_enabled = false
  minimum_tls_version           = "1.2"
  local_auth_enabled            = true

  # Identity configuration
  identity_type = "SystemAssigned"

  # Queues configuration
  queues = {
    "policy-compliance" = {
      max_size_in_megabytes                   = 2048
      default_message_ttl                     = "P7D"
      duplicate_detection_history_time_window = "PT30M"
      enable_partitioning                     = true
      requires_duplicate_detection            = true
      max_delivery_count                      = 5
    }
    "policy-remediation" = {
      max_size_in_megabytes = 1024
      default_message_ttl   = "P3D"
      max_delivery_count    = 3
      requires_session      = true
    }
  }

  # Topics configuration
  topics = {
    "policy-events" = {
      max_size_in_megabytes                   = 4096
      default_message_ttl                     = "P14D"
      duplicate_detection_history_time_window = "PT1H"
      enable_partitioning                     = true
      requires_duplicate_detection            = true
      support_ordering                        = true
    }
    "compliance-reports" = {
      max_size_in_megabytes = 2048
      default_message_ttl   = "P7D"
      support_ordering      = false
    }
  }

  # Topic subscriptions
  topic_subscriptions = {
    "policy-events-all" = {
      name                                      = "all-events"
      topic_name                                = "policy-events"
      max_delivery_count                        = 10
      default_message_ttl                       = "P7D"
      dead_lettering_on_filter_evaluation_error = true
      dead_lettering_on_message_expiration      = true
    }
    "compliance-reports-audit" = {
      name                = "audit-reports"
      topic_name          = "compliance-reports"
      max_delivery_count  = 5
      default_message_ttl = "P3D"
      requires_session    = false
    }
  }

  # Authorization rules
  authorization_rules = {
    "function-app-access" = {
      listen = true
      send   = true
      manage = false
    }
    "read-only-access" = {
      listen = true
      send   = false
      manage = false
    }
    "admin-access" = {
      listen = true
      send   = true
      manage = true
    }
  }

  # Queue authorization rules
  queue_authorization_rules = {
    "compliance-queue-sender" = {
      name       = "sender-access"
      queue_name = "policy-compliance"
      listen     = false
      send       = true
      manage     = false
    }
  }

  # Topic authorization rules
  topic_authorization_rules = {
    "events-topic-publisher" = {
      name       = "publisher-access"
      topic_name = "policy-events"
      listen     = false
      send       = true
      manage     = false
    }
  }

  # Private endpoint configuration
  enable_private_endpoint    = true
  private_endpoint_subnet_id = azurerm_subnet.private_endpoints.id
  private_dns_zone_ids       = [azurerm_private_dns_zone.servicebus.id]

  # Key Vault integration
  enable_key_vault_integration = true
  key_vault_id                 = azurerm_key_vault.example.id
  key_vault_secrets = {
    "function-app-connection" = {
      secret_name    = "servicebus-function-app-connection-string"
      auth_rule_name = "function-app-access"
      auth_rule_type = "namespace"
    }
    "read-only-connection" = {
      secret_name    = "servicebus-read-only-connection-string"
      auth_rule_name = "read-only-access"
      auth_rule_type = "namespace"
    }
  }

  # Diagnostic settings
  enable_diagnostic_settings = true
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  # Tags
  tags = {
    Environment = "dev"
    Purpose     = "example"
    ManagedBy   = "terraform"
    Project     = "service-bus-module"
  }

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.servicebus
  ]
}
