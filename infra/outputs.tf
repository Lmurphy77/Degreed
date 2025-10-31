output "resource_group_name"   { 
 value = module.rg.name 
}

output "vnet_id" { 
 value = module.network.vnet_id
}

output "subnet_ids" {
 value = module.network.subnet_ids 
}

output "private_dns_zone_ids"  { 
 value = module.private_dns.zone_ids
}

output "app_name"  {
 value = module.app.app_name 
}

output "app_default_hostname"  { 
 value = module.app.default_hostname 
}

output "app_principal_id" { 
 value = module.app.principal_id
}

output "app_private_ip"  { 
 value = module.app.private_endpoint_ip
}

output "sql_server_name" {
 value = module.sql_primary.server_name 
}

output "sql_server_fqdn" { 
 value = module.sql_primary.server_fqdn
}

output "sql_database_name"  { 
 value = module.sql_primary.database_name
}

output "sql_private_ip" {
 value = module.sql_primary.private_endpoint_ip 
}
