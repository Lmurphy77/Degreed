output "server_id" {
  value = azurerm_mssql_server.this.id
}

output "server_name" {
  value = azurerm_mssql_server.this.name
}

output "server_fqdn" {
  value = azurerm_mssql_server.this.fully_qualified_domain_name
}

output "database_id" {
  value = azurerm_mssql_database.db.id
}

output "database_name" {
  value = azurerm_mssql_database.db.name
}

output "private_endpoint_ip" {
  value = try(azurerm_private_endpoint.pep.private_service_connection[0].private_ip_address, null)
}

