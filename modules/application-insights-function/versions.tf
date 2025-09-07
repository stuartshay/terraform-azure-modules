# Application Insights Function Module - Provider Requirements
# This file defines the required providers and their versions

terraform {
  required_version = ">= 1.13.1"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.42.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}
