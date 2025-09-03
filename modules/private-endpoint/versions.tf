# Private Endpoint Module - Provider Requirements
# This file defines the required Terraform and provider versions

terraform {
  required_version = ">= 1.13.1"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.42.0"
    }
  }
}
