output "plan_id" {
  value = azurerm_service_plan.plan.id
}

output "app_id" {
  value = azurerm_linux_web_app.app.id
}

output "app_name" {
  value = azurerm_linux_web_app.app.name
}

output "default_hostname" {
  value = azurerm_linux_web_app.app.default_hostname
}

output "private_endpoint_ip" {
  value = try(azurerm_private_endpoint.app_pe[0].private_service_connection[0].private_ip_address, null)
}

output "principal_id" {
  value = azurerm_linux_web_app.app.identity[0].principal_id
}

output "private_endpoint_id" {
  value = try(azurerm_private_endpoint.app_pe[0].id, null)
}
