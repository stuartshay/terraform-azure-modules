terraform {
  required_version = ">= 1.0"
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

module "monitoring" {
  source              = "../../"
  resource_group_name = "rg-test-monitoring"
  location            = "East US"
  workload            = "testapp"
  environment         = "dev"
  location_short      = "eastus"
  subscription_id     = "00000000-0000-0000-0000-000000000000"
  notification_emails = { admin = "admin@example.com" }
  tags                = { Environment = "dev", Project = "testapp" }
}

locals {
  log_analytics_workspace_id_check = module.monitoring.log_analytics_workspace_id != null
  application_insights_id_check    = module.monitoring.application_insights_id != null
  action_group_id_check            = module.monitoring.action_group_id != null
}

resource "null_resource" "assert_log_analytics_workspace_id" {
  triggers = {
    valid = local.log_analytics_workspace_id_check ? 1 : 0
  }
}

resource "null_resource" "assert_application_insights_id" {
  triggers = {
    valid = local.application_insights_id_check ? 1 : 0
  }
}

resource "null_resource" "assert_action_group_id" {
  triggers = {
    valid = local.action_group_id_check ? 1 : 0
  }
}
