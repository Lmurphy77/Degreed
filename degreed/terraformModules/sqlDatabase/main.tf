terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.49.0"
    }
  }
}

data "azurerm_client_config" "current" {}

########################################
# SQL Server
########################################
resource "azurerm_mssql_server" "this" {
  name                          = "${var.name_prefix}-sql-pri"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = "12.0"
  minimum_tls_version           = "1.2"
  public_network_access_enabled = var.public_network_access_enabled

  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_login_password

  identity { type = "SystemAssigned" }

  dynamic "azuread_administrator" {
    for_each = var.enable_aad_admin ? [1] : []
    content {
      login_username              = var.aad_admin_login_name
      object_id                   = var.aad_admin_object_id
      tenant_id                   = data.azurerm_client_config.current.tenant_id
      azuread_authentication_only = true
    }
  }

  tags = var.tags
}

########################################
# SQL Database
########################################
resource "azurerm_mssql_database" "db" {
  name           = var.db_name
  server_id      = azurerm_mssql_server.this.id
  sku_name       = var.db_sku_name
  zone_redundant = var.db_zone_redundant

  create_mode                         = var.create_mode
  creation_source_database_id         = var.create_mode == "Secondary" ? var.source_database_id : null
  transparent_data_encryption_enabled = true

  short_term_retention_policy {
    retention_days = var.backup_short_term_retention_days
  }

  tags = var.tags
}

resource "azurerm_private_endpoint" "pep" {
  name                = "${var.name_prefix}-sql-pep"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "sql-pep-connection"
    private_connection_resource_id = azurerm_mssql_server.this.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  tags = var.tags

  private_dns_zone_group {
    name                 = "sql-pep-dnsgrp"
    private_dns_zone_ids = [var.private_dns_zone_id_database]
  }
}
