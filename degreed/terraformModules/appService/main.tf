locals {
  pna_enabled = coalesce(var.public_network_access_enabled, !var.enable_private_endpoint)
}

########################################
# App Service Plan 
########################################
resource "azurerm_service_plan" "plan" {
  name                   = "${var.name_prefix}-plan"
  location               = var.location
  resource_group_name    = var.resource_group_name
  os_type                = "Linux"
  sku_name               = var.plan_sku_name
  zone_balancing_enabled = var.plan_zone_balancing_enabled
  worker_count           = 1
  tags                   = var.tags
}

########################################
# Linux Web App 
########################################
resource "azurerm_linux_web_app" "app" {
  name                          = "${var.name_prefix}-app"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  service_plan_id               = azurerm_service_plan.plan.id
  https_only                    = true
  public_network_access_enabled = local.pna_enabled

  identity { type = "SystemAssigned" }

  site_config {
    minimum_tls_version               = "1.2"
    ftps_state                        = "Disabled"
    always_on                         = true
    health_check_path                 = var.health_check_path
    health_check_eviction_time_in_min = var.health_check_eviction_time_in_min
    vnet_route_all_enabled            = var.vnet_route_all_enabled


    dynamic "ip_restriction" {
      for_each = local.pna_enabled ? [1] : []
      content {
        name        = "allow-frontdoor"
        priority    = 100
        action      = "Allow"
        service_tag = "AzureFrontDoor.Backend"
      }
    }

    dynamic "ip_restriction" {
      for_each = local.pna_enabled ? [1] : []
      content {
        name     = "deny-all"
        priority = 65000
        action   = "Deny"
      }
    }
  }

  app_settings = merge(
    {
      "WEBSITE_HEALTHCHECK_PATH" = var.health_check_path
      "ConnectionStrings__Mode"  = "ManagedIdentity"
    },
    var.extra_app_settings
  )

  tags = var.tags

  lifecycle {
    ignore_changes = [
      tags,
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
    ]
  }
}

########################################
# Regional VNet Integration 
########################################
resource "azurerm_app_service_virtual_network_swift_connection" "integration" {
  app_service_id = azurerm_linux_web_app.app.id
  subnet_id      = var.subnet_integration_id
}

########################################
# Private Endpoint  + Private DNS
########################################
resource "azurerm_private_endpoint" "app_pe" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "${var.name_prefix}-app-pep"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "app-pep-connection"
    private_connection_resource_id = azurerm_linux_web_app.app.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  tags = var.tags


  private_dns_zone_group {
    name                 = "app-pep-dnsgrp"
    private_dns_zone_ids = [var.private_dns_zone_id_azurewebsites]
  }

}

