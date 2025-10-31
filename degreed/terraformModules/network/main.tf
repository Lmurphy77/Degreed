resource "azurerm_virtual_network" "this" {
  name                = "${var.name_prefix}-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  tags                = var.tags
}

resource "azurerm_subnet" "this" {
  for_each             = var.subnets
  name                 = "${var.name_prefix}-snet-${each.key}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value.address_prefix]


  dynamic "delegation" {
    for_each = each.value.purpose == "integration" ? [1] : []
    content {
      name = "appservice-delegation"
      service_delegation {
        name    = "Microsoft.Web/serverFarms"
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
  }

  private_endpoint_network_policies = each.value.purpose == "private_endpoints" ? "Disabled" : null
}

resource "azurerm_network_security_group" "this" {
  for_each            = var.subnets
  name                = "${var.name_prefix}-nsg-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  dynamic "security_rule" {
    for_each = coalesce(each.value.nsg_rules, [])
    content {
      name                         = security_rule.value.name
      priority                     = security_rule.value.priority
      direction                    = security_rule.value.direction
      access                       = security_rule.value.access
      protocol                     = security_rule.value.protocol
      source_port_ranges           = coalesce(try(security_rule.value.source_port_ranges, null), [])
      destination_port_ranges      = coalesce(try(security_rule.value.destination_port_ranges, null), [])
      source_address_prefixes      = coalesce(try(security_rule.value.source_address_prefixes, null), [])
      destination_address_prefixes = coalesce(try(security_rule.value.destination_address_prefixes, null), [])
      source_address_prefix        = try(security_rule.value.source_address_prefix, null)
      destination_address_prefix   = try(security_rule.value.destination_address_prefix, null)
      description                  = try(security_rule.value.description, null)
    }
  }
}


resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = {
    for k, v in var.subnets : k => v
    if coalesce(v.associate_nsg, true)
  }

  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.this[each.key].id
}
