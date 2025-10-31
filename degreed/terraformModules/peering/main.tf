resource "azurerm_virtual_network_peering" "a_to_b" {
  name                      = var.peering_name_a_to_b
  resource_group_name       = var.resource_group_name_a
  virtual_network_name      = var.vnet_name_a
  remote_virtual_network_id = var.vnet_id_b

  allow_virtual_network_access = var.allow_virtual_network_access
  allow_forwarded_traffic      = var.allow_forwarded_traffic_a_to_b
  allow_gateway_transit        = var.allow_gateway_transit_a_to_b
  use_remote_gateways          = var.use_remote_gateways_a_to_b
}


resource "azurerm_virtual_network_peering" "b_to_a" {
  name                      = var.peering_name_b_to_a
  resource_group_name       = var.resource_group_name_b
  virtual_network_name      = var.vnet_name_b
  remote_virtual_network_id = var.vnet_id_a

  allow_virtual_network_access = var.allow_virtual_network_access
  allow_forwarded_traffic      = var.allow_forwarded_traffic_b_to_a
  allow_gateway_transit        = var.allow_gateway_transit_b_to_a
  use_remote_gateways          = var.use_remote_gateways_b_to_a
}
