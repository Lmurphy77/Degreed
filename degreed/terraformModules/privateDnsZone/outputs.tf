output "zone_ids" {
  value = { for name, z in azurerm_private_dns_zone.this : name => z.id }
}

output "link_ids" {
  value = { for k, l in azurerm_private_dns_zone_virtual_network_link.links : k => l.id }
}
