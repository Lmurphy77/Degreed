output "endpoint_hostname" {
  description = "Public hostname of the Front Door endpoint."
  value       = azurerm_cdn_frontdoor_endpoint.this.host_name
}

output "profile_id" {
  description = "Front Door profile resource ID."
  value       = azurerm_cdn_frontdoor_profile.this.id
}
