terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.49.0, < 5.0.0"
    }
  }
}


resource "azurerm_private_dns_zone" "this" {
  for_each            = toset(var.zone_names)
  name                = each.value
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "links" {
  for_each = {
    for pair in flatten([
      for zone_name, zone in azurerm_private_dns_zone.this : [
        for vnet in var.vnets : {
          key       = "${zone_name}::${vnet.name}"
          zone_name = zone.name
          vnet_id   = vnet.id
          vnet_name = vnet.name
        }
      ]
    ]) : pair.key => pair
  }

  name                  = "link-to-${each.value.vnet_name}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = each.value.zone_name
  virtual_network_id    = each.value.vnet_id
  registration_enabled  = var.registration_enabled
  tags                  = var.tags
}
