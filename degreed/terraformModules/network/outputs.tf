output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "subnet_ids" {
  value = { for k, s in azurerm_subnet.this : k => s.id }
}

output "vnet_name" {
  value = azurerm_virtual_network.this.name
}

output "nsg_ids" {
  value = { for k, n in azurerm_network_security_group.this : k => n.id }
}

output "nsg_associated_subnets" {
  value = { for k, _ in azurerm_subnet_network_security_group_association.this : k => azurerm_subnet.this[k].id }
}

