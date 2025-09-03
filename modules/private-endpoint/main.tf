# Private Endpoint Module - Main Configuration
# This module creates Azure Private Endpoints with optional DNS zone integration

# Local values for consistent naming
locals {
  # Generate private service connection name if not provided
  private_service_connection_name = var.private_service_connection_name != null ? var.private_service_connection_name : "psc-${var.name}"

  # Generate private DNS zone group name if DNS zones are provided
  private_dns_zone_group_name = var.private_dns_zone_group_name != null ? var.private_dns_zone_group_name : "pdzg-${var.name}"
}

# Private Endpoint
resource "azurerm_private_endpoint" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = local.private_service_connection_name
    private_connection_resource_id = var.private_connection_resource_id
    subresource_names              = var.subresource_names
    is_manual_connection           = var.is_manual_connection
    request_message                = var.request_message
  }

  # Private DNS Zone Group (optional)
  dynamic "private_dns_zone_group" {
    for_each = var.private_dns_zone_ids != null && length(var.private_dns_zone_ids) > 0 ? [1] : []
    content {
      name                 = local.private_dns_zone_group_name
      private_dns_zone_ids = var.private_dns_zone_ids
    }
  }

  # IP Configuration (optional)
  dynamic "ip_configuration" {
    for_each = var.ip_configurations
    content {
      name               = ip_configuration.value.name
      private_ip_address = ip_configuration.value.private_ip_address
      subresource_name   = ip_configuration.value.subresource_name
      member_name        = ip_configuration.value.member_name
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      tags["CreatedDate"],
    ]
  }
}
