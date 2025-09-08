# Terraform Azure Modules

[![Pre-commit](https://github.com/stuartshay/terraform-azure-modules/actions/workflows/pre-commit.yml/badge.svg)](https://github.com/stuartshay/terraform-azure-modules/actions/workflows/pre-commit.yml)

[![Deploy to Terraform Cloud](https://github.com/stuartshay/terraform-azure-modules/actions/workflows/terraform-cloud-deploy.yml/badge.svg)](https://github.com/stuartshay/terraform-azure-modules/actions/workflows/terraform-cloud-deploy.yml)

A comprehensive collection of enterprise-grade Terraform modules for Azure infrastructure components with automated CI/CD workflows and Terraform Cloud integration. This repository provides production-ready, security-focused modules designed for scalable Azure deployments with built-in best practices, standardized naming conventions, and automated publishing to Terraform Cloud's private registry.

## Key Features

🏗️ **Production-Ready Modules** - Enterprise-grade modules with security best practices and performance optimization  
🔒 **Security-First Design** - HTTPS-only, VNET integration, restricted SKUs, and compliance-ready configurations  
🚀 **Automated CI/CD** - GitHub Actions workflows for validation, testing, and automated publishing  
☁️ **Terraform Cloud Integration** - Seamless deployment to Terraform Cloud private registry with versioning  
📋 **Comprehensive Documentation** - Detailed usage examples, Quick Start guides, and API documentation  
🏷️ **Semantic Versioning** - Automated version management with branch-specific release strategies  
🔍 **Quality Assurance** - Pre-commit hooks, Checkov security scanning, and automated validation

## Available Modules

### App Service Plan Module - Function

[![Terraform Registry](https://img.shields.io/badge/Terraform-Registry-623CE4?style=for-the-badge&logo=terraform&logoColor=white)](https://app.terraform.io/app/azure-policy-cloud/registry/modules/private/azure-policy-cloud/app-service-plan-function/azurerm/)

Azure Function App resources including Storage Account, App Service Plan, and Function App with VNET integration and restricted SKU options.

- **Path**: `modules/app-service-plan-function`
- **Provider**: `azurerm`
- **Version**: `>= 4.42`

#### Features

- **Restricted SKUs**: Only EP1, EP2, and EP3 (Elastic Premium) SKUs allowed for consistent performance and security
- **VNET Integration**: App Service Plan deployed with VNET integration for network isolation
- **Performance**: Configurable scaling with always-ready instances for Elastic Premium
- Resource tagging support

#### Quick Start

```hcl
module "app-service-plan-function" {
  source  = "app.terraform.io/azure-policy-cloud/app-service-plan-function/azurerm"
  version = "1.1.82"

  resource_group_name = "rg-example"
  location           = "East US"
  environment        = "dev"
  workload           = "myapp"

  # SKU must be EP1, EP2, or EP3
  sku_name = "EP1"

  tags = {
    Environment = "dev"
    Project     = "example"
  }
}
```

### Function App Module

[![Terraform Registry](https://img.shields.io/badge/Terraform-Registry-623CE4?style=for-the-badge&logo=terraform&logoColor=white)](https://app.terraform.io/app/azure-policy-cloud/registry/modules/private/azure-policy-cloud/function-app/azurerm/)

Azure Function App with comprehensive features including cross-platform support, VNet integration, Application Insights, deployment slots, and advanced security configurations. Decoupled from App Service Plans for flexible deployments.

- **Path**: `modules/function-app`
- **Provider**: `azurerm`
- **Version**: `>= 4.42`

#### Features

- **Cross-Platform Support**: Both Linux and Windows Function Apps with multiple runtime support
- **Runtime Support**: Python, Node.js, .NET, Java, PowerShell, and custom runtimes
- **Deployment Slots**: Staging and production deployment slots for safe deployments
- **VNet Integration**: Optional VNet integration for secure network connectivity
- **Security Features**: HTTPS enforcement, client certificates, managed identity, and IP restrictions
- **Storage Account**: Dedicated storage account with security best practices and retention policies
- **Application Insights**: Built-in monitoring and telemetry with workspace integration
- **Flexible Configuration**: Extensive customization options for all Function App aspects

#### Quick Start

```hcl
module "function_app" {
  source  = "app.terraform.io/azure-policy-cloud/function-app/azurerm"
  version = "1.0.0"

  # Required variables
  workload            = "myapp"
  environment         = "dev"
  resource_group_name = "rg-example"
  location           = "East US"
  service_plan_id    = module.app_service_plan.app_service_plan_id

  # Runtime configuration
  runtime_name    = "python"
  runtime_version = "3.11"

  # VNet integration
  enable_vnet_integration    = true
  vnet_integration_subnet_id = data.azurerm_subnet.functions.id

  # Application Insights
  enable_application_insights = true
  log_analytics_workspace_id  = data.azurerm_log_analytics_workspace.main.id

  tags = {
    Environment = "dev"
    Project     = "example"
  }
}
```

### App Service Plan Module - Web

[![Terraform Registry](https://img.shields.io/badge/Terraform-Registry-623CE4?style=for-the-badge&logo=terraform&logoColor=white)](https://app.terraform.io/app/azure-policy-cloud/registry/modules/private/azure-policy-cloud/app-service-plan-web/azurerm/)

Azure App Service resources including App Service Plan and Web App with VNET integration and restricted SKU options.

- **Path**: `modules/app-service-plan-web`
- **Provider**: `azurerm`
- **Version**: `>= 4.42

#### Features

- **Restricted SKUs**: Only S1 and S2 SKUs allowed for enhanced security and performance
- **VNET Integration**: App Service deployed with VNET integration for network isolation
- **Security**: HTTPS-only, FTP disabled, HTTP/2 enabled
- **Performance**: Always-on enabled for better performance
- Linux Web App with Python runtime
- Configurable app settings
- Resource tagging support

#### Quick Start

```hcl
module "app_service" {
  source  = "app.terraform.io/azure-policy-cloud/app-service-plan-web/azurerm"
  version = "1.0.0"

  resource_group_name = "rg-example"
  location           = "East US"
  environment        = "dev"
  workload           = "myapp"
  subnet_id          = "/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/subnet-app-service"

  # SKU must be S1 or S2
  sku_name = "S1"

  tags = {
    Environment = "dev"
    Project     = "example"
  }
}
```

### Container-Instances Module

[![Terraform Registry](https://img.shields.io/badge/Terraform-Registry-623CE4?style=for-the-badge&logo=terraform&logoColor=white)](https://app.terraform.io/app/azure-policy-cloud/registry/modules/private/azure-policy-cloud/container-instances/azurerm/)


Enterprise-grade Azure Container Instances (ACI) module supporting multi-container groups, secure networking, managed identities, diagnostics, and advanced configuration for production workloads.

- **Path**: `modules/container-instances`
- **Provider**: `azurerm`
- **Version**: `>= 4.42`

#### Features

- **Multi-Container Support**: Deploy multiple containers in a single group with custom resource allocation
- **VNet Integration**: Private IP, subnet selection, and secure network isolation
- **Managed Identity**: SystemAssigned and UserAssigned identity support
- **Environment Variables**: Secure and plain environment variable injection
- **Volume Mounts**: Azure Files and emptyDir support for persistent and ephemeral storage
- **Probes**: Liveness and readiness probes for health monitoring
- **Diagnostics**: Log Analytics, diagnostic logs, and metrics integration
- **Tagging**: Full Azure tagging support

#### Quick Start

```hcl
module "container_instances" {
  source  = "app.terraform.io/azure-policy-cloud/container-instances/azurerm"
  version = "1.1.83"

  resource_group_name = "rg-example"
  location           = "East US"
  environment        = "dev"
  workload           = "myapp"

  containers = [
    {
      name   = "web"
      image  = "nginx:alpine"
      cpu    = 1.0
      memory = 2.0
      ports = [{ port = 80, protocol = "TCP" }]
      environment_variables = { ENV = "dev" }
      secure_environment_variables = { SECRET = "supersecret" }
      volume_mounts = [{ name = "web-content", mount_path = "/usr/share/nginx/html", read_only = true }]
      liveness_probe = {
        http_get = { path = "/health", port = 80, scheme = "HTTP" }
        initial_delay_seconds = 30
        period_seconds        = 10
        failure_threshold     = 3
        success_threshold     = 1
        timeout_seconds       = 5
      }
    }
  ]

  ip_address_type         = "Private"
  enable_vnet_integration = true
  subnet_ids              = [data.azurerm_subnet.container.id]
  exposed_ports           = [{ port = 80, protocol = "TCP" }]
  identity_type           = "SystemAssigned, UserAssigned"
  identity_ids            = [data.azurerm_user_assigned_identity.example.id]
  enable_diagnostic_settings = true
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.example.id
  tags = {
    Environment = "dev"
    Project     = "example"
  }
}
```

---

### Networking Module

[![Terraform Registry](https://img.shields.io/badge/Terraform-Registry-623CE4?style=for-the-badge&logo=terraform&logoColor=white)](https://app.terraform.io/app/azure-policy-cloud/registry/modules/private/azure-policy-cloud/networking/azurerm/)


Azure networking resources including Virtual Network (VNet), subnets, Network Security Groups (NSGs), and optional monitoring components.

- **Path**: `modules/networking`
- **Provider**: `azurerm`
- **Version**: `>= 4.40`

#### Features

- **Virtual Network** with configurable address space
- **Subnets** with flexible configuration (address prefixes, service endpoints, delegations)
- **Network Security Groups** with default security rules
- **Security Rules** including HTTPS, DNS, and service-specific rules
- **Route Tables** (optional) for custom routing
- **Network Watcher** (optional) for monitoring and diagnostics
- **VNet Flow Logs** (replacing deprecated NSG flow logs)
- **Storage Account** for flow logs with security configurations
- **Traffic Analytics** integration (optional)
- **App Service and Function App** specific NSG rules
- **Network isolation** through NSG associations

#### Quick Start

```hcl
module "networking" {
  source  = "app.terraform.io/azure-policy-cloud/networking/azurerm"
  version = "1.0.0"

  # Required variables
  resource_group_name = "rg-example"
  location           = "East US"
  environment        = "dev"
  workload           = "myapp"
  location_short     = "eastus"

  # Network configuration
  vnet_address_space = ["10.0.0.0/16"]
  subnet_config = {
    appservice = {
      address_prefixes  = ["10.0.1.0/24"]
      service_endpoints = ["Microsoft.Web"]
      delegation = {
        name = "app-service-delegation"
        service_delegation = {
          name    = "Microsoft.Web/serverFarms"
          actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
        }
      }
    }
  }

  tags = {
    Environment = "dev"
    Project     = "example"
  }
}
```

### Private Endpoint Module


[![Terraform Registry](https://img.shields.io/badge/Terraform-Registry-623CE4?style=for-the-badge&logo=terraform&logoColor=white)](https://app.terraform.io/app/azure-policy-cloud/registry/modules/private/azure-policy-cloud/private-endpoint/azurerm/)

Azure Private Endpoint module for secure, private connectivity to Azure resources such as Storage Accounts, Key Vaults, and Service Bus. This module automates the creation of private endpoints, network interface associations, DNS zone integrations, and resource-specific configurations for enterprise-grade security and compliance.

- **Path**: `modules/private-endpoint`
- **Provider**: `azurerm`
- **Version**: `>= 4.42`

#### Features

- **Secure Private Connectivity**: Establishes private endpoints for supported Azure resources, eliminating public exposure
- **DNS Zone Integration**: Automates private DNS zone creation and record management for seamless name resolution
- **Network Interface Management**: Handles NIC associations and subnet selection for network isolation
- **Resource Support**: Works with Storage Accounts, Key Vaults, Service Bus, and other supported services
- **Tagging and Compliance**: Supports resource tagging and adheres to security best practices

#### Quick Start

```hcl
module "private_endpoint" {
  source  = "app.terraform.io/azure-policy-cloud/private-endpoint/azurerm"
  version = "1.0.0"

  resource_group_name = "rg-example"
  location            = "East US"
  environment         = "dev"
  workload            = "myapp"

  # Target resource ID (e.g., Storage Account, Key Vault, Service Bus)
  private_service_resource_id = azurerm_storage_account.example.id

  # Subnet for the private endpoint
  subnet_id = data.azurerm_subnet.private_endpoints.id

  # Optional DNS zone integration
  private_dns_zone_name = "privatelink.blob.core.windows.net"

  tags = {
    Environment = "dev"
    Project     = "example"
  }
}
```



### Storage Account Module

[![Terraform Registry](https://img.shields.io/badge/Terraform-Registry-623CE4?style=for-the-badge&logo=terraform&logoColor=white)](https://app.terraform.io/app/azure-policy-cloud/registry/modules/private/azure-policy-cloud/storage-account/azurerm/)

Azure Storage Account with comprehensive features including blob containers, file shares, queues, tables, private endpoints, and advanced security configurations.

- **Path**: `modules/storage-account`
- **Provider**: `azurerm`
- **Version**: `>= 4.40`

#### Features

- **Storage Account** with configurable performance tiers and replication types
- **Blob Containers** with access control and metadata
- **File Shares** with quota management and SMB/NFS protocols
- **Queues** and **Tables** for messaging and NoSQL storage
- **Private Endpoints** for secure network access
- **Static Website** hosting capability
- **Data Lake Gen2** support for big data analytics
- **Lifecycle Management** for automated data tiering and cleanup
- **Advanced Security** with encryption, network rules, and access controls
- **Monitoring Integration** with diagnostic settings and Log Analytics
- **Compliance Features** including immutability policies and audit trails

> **Logging Requirement:**
> For Blob, Queue, File, and Table services, logging is **required** for all **READ, WRITE, and DELETE** actions. This ensures full auditability and compliance for all storage operations.

#### Quick Start

```hcl
module "storage_account" {
  source  = "app.terraform.io/azure-policy-cloud/storage-account/azurerm"
  version = "1.0.0"

  # Required variables
  resource_group_name = "rg-example"
  location           = "East US"
  environment        = "dev"
  workload           = "myapp"
  location_short     = "eastus"

  # Basic configuration
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  access_tier              = "Hot"

  # Create blob containers
  blob_containers = {
    documents = {
      access_type = "private"
    }
    backups = {
      access_type = "private"
    }
  }

  tags = {
    Environment = "dev"
    Project     = "example"
  }
}
```

### Service Bus Module

[![Terraform Registry](https://img.shields.io/badge/Terraform-Registry-623CE4?style=for-the-badge&logo=terraform&logoColor=white)](https://app.terraform.io/app/azure-policy-cloud/registry/modules/private/azure-policy-cloud/service-bus/azurerm/)

Azure Service Bus namespace with comprehensive messaging capabilities including queues, topics, subscriptions, authorization rules, private endpoints, and Key Vault integration for enterprise messaging solutions.

- **Path**: `modules/service-bus`
- **Provider**: `azurerm`
- **Version**: `>= 4.42`

#### Features

- **Service Bus Namespace**: Support for Basic, Standard, and Premium SKUs with proper validation
- **Queues and Topics**: Configurable queues and topics with all Azure Service Bus features
- **Topic Subscriptions**: Support for topic subscriptions with advanced configuration options
- **Authorization Rules**: Namespace, queue, and topic-level authorization rules for granular access control
- **Private Endpoint**: Optional private endpoint integration for secure network connectivity
- **Key Vault Integration**: Secure storage of connection strings in Azure Key Vault
- **Security Features**: TLS 1.2 enforcement, managed identity support, and network access controls
- **Monitoring Integration**: Diagnostic settings with Log Analytics, Storage, and Event Hub support
- **Naming Convention**: Enforced naming convention: `sb-{workload}-{environment}-{location_short}-001`

#### Quick Start

```hcl
module "service_bus" {
  source  = "app.terraform.io/azure-policy-cloud/service-bus/azurerm"
  version = "1.0.0"

  # Required variables
  workload            = "myapp"
  environment         = "dev"
  location            = "East US"
  location_short      = "eastus"
  resource_group_name = "rg-example"

  # Basic configuration
  sku = "Standard"

  # Create queues
  queues = {
    "notifications" = {
      max_size_in_megabytes = 1024
      default_message_ttl   = "P3D"
      max_delivery_count    = 5
    }
  }

  # Authorization rules
  authorization_rules = {
    "app-access" = {
      listen = true
      send   = true
      manage = false
    }
  }

  tags = {
    Environment = "dev"
    Project     = "example"
  }
}
```


### Monitoring Module

[![Terraform Registry](https://img.shields.io/badge/Terraform-Registry-623CE4?style=for-the-badge&logo=terraform&logoColor=white)](https://app.terraform.io/app/azure-policy-cloud/registry/modules/private/azure-policy-cloud/monitoring/azurerm/)

Comprehensive Azure monitoring solution including Log Analytics Workspace, Application Insights, alerts, and monitoring configurations.

- **Path**: `modules/monitoring`
- **Provider**: `azurerm`
- **Version**: `>= 4.42`

#### Features

- Log Analytics Workspace with configurable retention and quotas
- Application Insights with workspace-based configuration
- Action Groups for notifications (email, SMS, webhooks)
- Comprehensive alerting for performance, availability, and errors
- Optional private endpoints for secure connectivity
- VM Insights and data collection rules
- Storage monitoring capabilities
- Security Center and Update Management solutions
- Custom workbooks for dashboards

#### Quick Start

```hcl
module "monitoring" {
  source  = "app.terraform.io/azure-policy-cloud/monitoring/azurerm"
  version = "1.0.0"

  # Required variables
  resource_group_name = "rg-example"
  location           = "East US"
  workload           = "myapp"
  environment        = "dev"
  location_short     = "eastus"
  subscription_id    = "your-subscription-id"

  # Notification configuration
  notification_emails = {
    admin = "admin@example.com"
  }

  tags = {
    Environment = "dev"
    Project     = "example"
  }
}
```

### Application Insights Module

[![Terraform Registry](https://img.shields.io/badge/Terraform-Registry-623CE4?style=for-the-badge&logo=terraform&logoColor=white)](https://app.terraform.io/app/azure-policy-cloud/registry/modules/private/azure-policy-cloud/application-insights/azurerm/)

Azure Application Insights module for advanced monitoring, analytics, and diagnostics. Supports workspace-based and classic modes, custom retention, and integration with Log Analytics.

- **Path**: `modules/application-insights`
- **Provider**: `azurerm`
- **Version**: `>= 4.42`

#### Features

- **Workspace-Based or Classic**: Choose between workspace-based or classic Application Insights
- **Custom Retention**: Set data retention period for logs and analytics
- **Log Analytics Integration**: Seamless integration with Log Analytics Workspace
- **Multiple Instances**: Deploy multiple Application Insights resources with unique settings
- **Tagging**: Full Azure tagging support

#### Quick Start

```hcl
module "application_insights" {
  source  = "app.terraform.io/azure-policy-cloud/application-insights/azurerm"
  version = "1.0.0"

  resource_group_name = "rg-example"
  location           = "East US"
  environment        = "dev"
  workload           = "myapp"
  application_type   = "web"
  workspace_id       = data.azurerm_log_analytics_workspace.main.id
  retention_in_days  = 30
  tags = {
    Environment = "dev"
    Project     = "example"
  }
}
```

### Application Insights Billing Module

[![Terraform Registry](https://img.shields.io/badge/Terraform-Registry-623CE4?style=for-the-badge&logo=terraform&logoColor=white)](https://app.terraform.io/app/azure-policy-cloud/registry/modules/private/azure-policy-cloud/application-insights-billing/azurerm/)

Comprehensive billing monitoring, budgets, and cost alerts for Azure resources within a Resource Group. Provides budget tracking, cost anomaly detection, and detailed billing dashboards to help manage and optimize Azure spending.

- **Path**: `modules/application-insights-billing`
- **Provider**: `azurerm`
- **Version**: `>= 4.42`

#### Features

- **Budget Management**: Monthly, quarterly, and annual budgets with configurable alert thresholds
- **Cost Alerts**: Daily spending threshold alerts and cost anomaly detection
- **Billing Dashboard**: Interactive cost visualization with trends and breakdowns
- **Flexible Configuration**: All thresholds and settings are configurable with optional features
- **Log Analytics Integration**: Advanced cost queries and anomaly detection
- **Cost Filtering**: Monitor specific resource types and tags

#### Quick Start

```hcl
module "app_insights_billing" {
  source  = "app.terraform.io/azure-policy-cloud/application-insights-billing/azurerm"
  version = "1.0.0"

  # Required variables
  resource_group_name       = "rg-myapp-prod-eus-001"
  location                 = "East US"
  application_insights_name = "appi-myapp-prod-eus-001"

  # Budget configuration
  monthly_budget_amount   = 500
  quarterly_budget_amount = 1500
  annual_budget_amount    = 6000

  # Notification emails for budget alerts
  budget_notification_emails = [
    "admin@company.com",
    "finance@company.com"
  ]

  workload    = "myapp"
  environment = "prod"

  tags = {
    Environment = "Production"
    Project     = "MyApp"
    CostCenter  = "Engineering"
  }
}
```

### Application Insights Function Module

[![Terraform Registry](https://img.shields.io/badge/Terraform-Registry-623CE4?style=for-the-badge&logo=terraform&logoColor=white)](https://app.terraform.io/app/azure-policy-cloud/registry/modules/private/azure-policy-cloud/application-insights-function/azurerm/)

Comprehensive monitoring, alerting, and dashboards for Azure Function Apps and App Service Plans within a Resource Group. Provides performance monitoring, failure detection, and operational insights specifically tailored for serverless function workloads.

- **Path**: `modules/application-insights-function`
- **Provider**: `azurerm`
- **Version**: `>= 4.42`

#### Features

- **Function App Monitoring**: Execution duration tracking, failure rate monitoring, and invocation count alerts
- **App Service Plan Monitoring**: CPU and memory usage alerts with resource utilization tracking
- **Advanced Analytics**: Cold start detection, dependency performance tracking, and exception analysis
- **Interactive Dashboard**: Function invocation trends, execution duration visualization, and real-time metrics
- **Flexible Configuration**: Configurable alert thresholds and selective monitoring of specific Function Apps

#### Quick Start

```hcl
module "app_insights_function" {
  source  = "app.terraform.io/azure-policy-cloud/application-insights-function/azurerm"
  version = "1.0.0"

  # Required variables
  resource_group_name       = "rg-myapp-prod-eus-001"
  location                 = "East US"
  application_insights_name = "appi-myapp-prod-eus-001"

  # Function Apps to monitor
  function_app_names = [
    "func-myapp-api-prod-eus-001",
    "func-myapp-worker-prod-eus-001"
  ]

  # App Service Plans to monitor
  app_service_plan_names = [
    "asp-myapp-functions-prod-001"
  ]

  workload    = "myapp"
  environment = "prod"

  tags = {
    Environment = "Production"
    Project     = "MyApp"
    Team        = "Platform"
  }
}
```




### Application Insights Network Module

[![Terraform Registry](https://img.shields.io/badge/Terraform-Registry-623CE4?style=for-the-badge&logo=terraform&logoColor=white)](https://app.terraform.io/app/azure-policy-cloud/registry/modules/private/azure-policy-cloud/application-insights-network/azurerm/)

Azure Application Insights monitoring and alerting module that creates comprehensive alert rules and dashboards for Application Insights instances. Provides basic alerting capabilities and sample dashboards for monitoring application performance and health.

- **Path**: `modules/application-insights-network`
- **Provider**: `azurerm`
- **Version**: `>= 3.0`

#### Features

- **Configurable Alert Rules**: 5 different alert types with customizable thresholds and severities
  - Response time alerts (default: >5000ms)
  - Failed request rate alerts (default: >5%)
  - Exception rate alerts (default: >10 per 5 minutes)
  - Availability alerts (default: <99%)
  - Server error alerts (default: >10 per 5 minutes)
- **Sample Dashboard**: Basic monitoring workbook with essential performance metrics
- **Flexible Configuration**: All alert thresholds and severities are configurable with sensible defaults
- **No Notifications**: Alert rules created without action groups (can be added separately)
- **Log Analytics Integration**: Optional integration with Log Analytics Workspace for advanced queries

#### Quick Start

```hcl
module "app_insights_monitoring" {
  source  = "app.terraform.io/azure-policy-cloud/application-insights-network/azurerm"
  version = "1.0.0"

  # Required variables
  resource_group_name       = "rg-myapp-prod-eus-001"
  location                 = "East US"
  application_insights_name = "appi-myapp-prod-eus-001"

  # Optional naming
  workload       = "myapp"
  environment    = "prod"
  location_short = "eus"

  # Custom alert thresholds
  response_time_threshold_ms     = 3000  # 3 seconds
  failed_request_rate_threshold  = 2     # 2%
  availability_threshold_percent = 99.5  # 99.5%

  # Enable dashboard
  enable_dashboard       = true
  dashboard_display_name = "MyApp Production Monitoring"

  tags = {
    Environment = "Production"
    Project     = "MyApp"
  }
}
```

#### Integration with Application Insights Module

This module is designed to work seamlessly with the Application Insights module:

```hcl
# Create Application Insights with workspace and Key Vault integration
module "app_insights" {
  source = "./modules/application-insights"

  resource_group_name = "rg-myapp-prod-eus-001"
  location           = "East US"
  workload           = "myapp"
  environment        = "prod"

  # Creates workspace-based Application Insights
  create_workspace = true
  
  # Stores connection string in Key Vault
  key_vault_id = "https://<key-vault-name>.vault.azure.net/"
}

# Add monitoring and alerting
module "app_insights_monitoring" {
  source = "./modules/application-insights-network"

  resource_group_name       = module.app_insights.resource_group_name
  location                 = module.app_insights.location
  application_insights_name = module.app_insights.name

  # Reference the created workspace
  log_analytics_workspace_name = module.app_insights.log_analytics_workspace_name

  depends_on = [module.app_insights]
}
```



## Usage

### Module Reference

To use a module from this repository, reference it using the Terraform Cloud private registry:

```hcl
module "module_name" {
  source  = "app.terraform.io/azure-policy-cloud/MODULE_NAME/azurerm"
  version = "VERSION"

  # Module configuration
}
```

**Alternative GitHub Source** (for development or direct repository access):

```hcl
module "module_name" {
  source = "github.com/stuartshay/terraform-azure-modules//modules/MODULE_NAME?ref=VERSION"

  # Module configuration
}
```

### Examples

Each module includes comprehensive examples:

- **Basic**: Minimal configuration for getting started
- **Complete**: Full configuration with all features enabled

See the `examples/` directory in each module for detailed usage examples.

## Requirements

- Terraform >= 1.13.1
- Azure Provider >= 4.42
- Appropriate Azure permissions for resource creation
## Terraform Cloud Deployment


This repository includes automated deployment to Terraform Cloud private registry via GitHub Actions.

### Features

- **Manual deployment** via workflow dispatch
- **Module selection** (app-service-plan-web, app-service-plan-function, networking, storage-account, or monitoring)
- **Version management** with semantic versioning
- **Dry run mode** for validation without publishing
- **Automated validation** and packaging

### Required GitHub Secrets

To enable Terraform Cloud deployment, configure these repository secrets:

- `TF_API_TOKEN`: Terraform Cloud API token
- `TF_CLOUD_ORGANIZATION`: Terraform Cloud organization name

### Usage

1. Go to **Actions** → **Deploy to Terraform Cloud**
2. Click **Run workflow**
3. Select module (app-service-plan-web, app-service-plan-function, or monitoring)
4. Optionally adjust major/minor version (defaults to 1.0)
5. Choose dry run for testing or uncheck to publish

**Auto-Versioning**: Versions are automatically generated based on the branch:
- **Master/Main branch**: `{major}.{minor}.{github_run_id}` (e.g., `1.1.5`)
- **Other branches**: `{major}.{minor}.{github_run_id}-beta` (e.g., `1.1.5-beta`)

This ensures unique versions every time while clearly distinguishing production releases from development/beta versions.

For detailed instructions, see [Terraform Cloud Deployment Guide](docs/TERRAFORM_CLOUD_DEPLOYMENT.md).

### Published Modules

Once deployed, modules are available at:

```hcl
module "app_service" {
  source  = "app.terraform.io/azure-policy-cloud/app-service-web/azurerm"
  version = "1.0.0"
  # configuration...
}

module "function_app" {
  source  = "app.terraform.io/azure-policy-cloud/app-service-plan-function/azurerm"
  version = "1.1.82"
  # configuration...
}

module "monitoring" {
  source  = "app.terraform.io/azure-policy-cloud/monitoring/azurerm"
  version = "1.0.0"
  # configuration...
}
```

## CI/CD: Required Azure Secrets for Validation

To enable Terraform validation in GitHub Actions, the following repository secrets must be set:

- `AZURE_CLIENT_ID`: Service principal client ID
- `AZURE_TENANT_ID`: Azure tenant ID
- `AZURE_SUBSCRIPTION_ID`: Azure subscription ID
- `AZURE_CLIENT_SECRET`: Service principal client secret

These are used by the workflow to authenticate with Azure using the `azure/login` action. Without these, validation of modules and examples that require provider authentication will fail.

For more information, see the [Azure/login GitHub Action documentation](https://github.com/Azure/login#configure-a-service-principal-with-a-secret).

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Ensure all tests pass
5. Submit a pull request

## Versioning

This repository uses semantic versioning with branch-specific formatting to distinguish between production and development releases.

### Version Format

- **Production (master/main branch)**: `MAJOR.MINOR.PATCH` (e.g., `1.1.5`)
- **Development (other branches)**: `MAJOR.MINOR.PATCH-beta` (e.g., `1.1.5-beta`)

### How It Works

1. **Major/Minor versions** are manually specified when running the deployment workflow (defaults to 1.1)
2. **Patch version** is automatically generated using the GitHub run number, ensuring uniqueness
3. **Branch detection** automatically applies the appropriate format:
   - Master/main branches produce stable versions for production use
   - All other branches (develop, feature branches, etc.) produce beta versions

### Git Tags

Each successful deployment creates a Git tag in the format: `{module-name}-v{version}`

Examples:
- `app-service-plan-web-v1.1.5` (production release from master)
- `monitoring-v1.1.5-beta` (beta release from develop branch)

### Usage Examples

**Production version (from master branch):**
```hcl
module "app_service" {
  source  = "app.terraform.io/your-org/app-service-plan-web/azurerm"
  version = "1.1.5"  # Stable production release
}
```

**Beta version (from develop branch):**
```hcl
module "app_service" {
  source  = "app.terraform.io/your-org/app-service-plan-web/azurerm"
  version = "1.1.5-beta"  # Pre-release for testing
}
```

This approach ensures clear separation between stable production releases and development versions while maintaining semantic versioning compliance.

## Development

### GitHub Copilot Environment

The repository includes a dedicated GitHub Copilot setup workflow that configures the complete development environment before firewall restrictions are enabled.

See [Copilot Setup Guide](docs/COPILOT_SETUP.md) for detailed information on:
- Required repository secrets (Terraform Cloud, Azure credentials)
- Automated tool installation (Terraform, TFLint, Checkov, etc.)
- Pre-commit hook configuration
- Environment validation and testing

### Local Development

1. **Environment Setup**: Run `./install.sh` to install all necessary tools
2. **Authentication**: Configure Terraform Cloud and Azure credentials
3. **Pre-commit Hooks**: Install with `pre-commit install`
4. **Validation**: Run `make validate-all` to check all modules

For comprehensive development documentation, see:
- [Installation Guide](INSTALL.md)
- [Pre-commit Testing](docs/PRE_COMMIT_TESTING.md)
- [Terraform Testing Guide](docs/TERRAFORM_TESTING.md)

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Support

For issues and questions:

1. Check the module documentation
2. Review the examples
3. Open an issue in this repository

---

**Note**: These modules are designed for Azure infrastructure and require appropriate Azure subscriptions and permissions.
