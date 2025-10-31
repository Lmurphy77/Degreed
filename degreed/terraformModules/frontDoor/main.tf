terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.49.0, < 5.0.0"
    }
  }
}

locals {
  origins = { for idx, h in var.app_hostnames : tostring(idx) => h }
}

resource "azurerm_cdn_frontdoor_profile" "this" {
  name                = "${var.name_prefix}-fdp"
  resource_group_name = var.resource_group_name
  sku_name            = "Standard_AzureFrontDoor"
  tags                = var.tags
}

resource "azurerm_cdn_frontdoor_endpoint" "this" {
  name                     = "${var.name_prefix}-fde"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id
  tags                     = var.tags
}

resource "azurerm_cdn_frontdoor_origin_group" "this" {
  name                     = "${var.name_prefix}-og"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id

  health_probe {
    protocol            = "Https"
    request_type        = "GET"
    path                = var.health_check_path
    interval_in_seconds = 30
  }

  load_balancing {
    sample_size                        = 4
    successful_samples_required        = 3
    additional_latency_in_milliseconds = 0
  }
}



resource "azurerm_cdn_frontdoor_origin" "app" {
  for_each                      = local.origins
  name                          = "${var.name_prefix}-origin-${each.key}"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.this.id

  host_name                      = each.value
  origin_host_header             = each.value
  https_port                     = 443
  enabled                        = true
  certificate_name_check_enabled = true
}

resource "azurerm_cdn_frontdoor_route" "this" {
  name                          = "${var.name_prefix}-route"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.this.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.this.id
  cdn_frontdoor_origin_ids      = values(azurerm_cdn_frontdoor_origin.app)[*].id

  supported_protocols    = ["Https"]
  https_redirect_enabled = true
  forwarding_protocol    = "HttpsOnly"
  patterns_to_match      = ["/*"]
  link_to_default_domain = true
  enabled                = true
}
