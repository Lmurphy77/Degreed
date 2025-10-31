############################
# Resource Group
############################
module "rg" {
  source      = "../degreed/terraformModules/resourceGroup"
  name        = "${var.name_prefix}-rg"
  location    = "westus"
  environment = var.environment
  owner       = var.owner
}

############################
# Network 
############################
module "network" {
  source              = "../degreed/terraformModules/network"
  name_prefix         = var.name_prefix
  location            = var.location
  resource_group_name = module.rg.name

  address_space = var.vnet_address_space
  subnets       = var.subnets
  tags          = var.tags
}

module "network_secondary" {
  source              = "../degreed/terraformModules/network"
  name_prefix         = "${var.name_prefix}-2"
  location            = var.secondary_location
  resource_group_name = module.rg.name

  address_space = var.secondary_vnet_address_space
  subnets       = var.secondary_subnets
  tags          = var.tags
}

############################
# vNet peering
############################
module "vnet_peering" {
  source = "../degreed/terraformModules/peering"

  vnet_name_a           = module.network.vnet_name
  resource_group_name_a = module.rg.name

  vnet_name_b           = module.network_secondary.vnet_name
  resource_group_name_b = module.rg.name

  vnet_id_a = module.network.vnet_id
  vnet_id_b = module.network_secondary.vnet_id

  peering_name_a_to_b = var.peering_name_a_to_b
  peering_name_b_to_a = var.peering_name_b_to_a

  allow_virtual_network_access   = true
  allow_forwarded_traffic_a_to_b = false
  allow_forwarded_traffic_b_to_a = false
  allow_gateway_transit_a_to_b   = false
  allow_gateway_transit_b_to_a   = false
  use_remote_gateways_a_to_b     = false
  use_remote_gateways_b_to_a     = false
}

############################
# Private DNS zones
############################
module "private_dns" {
  source              = "../degreed/terraformModules/privateDnsZone"
  resource_group_name = module.rg.name
  zone_names          = var.private_dns_zones
  vnets = [
    { id = module.network.vnet_id, name = "${var.name_prefix}-westus-vnet" },
    { id = module.network_secondary.vnet_id, name = "${var.name_prefix}-eastus-vnet" }
  ]
  registration_enabled = false
  tags                 = var.tags
}

############################
# SQL Server + DB
############################
module "sql_primary" {
  source              = "../degreed/terraformModules/sqlDatabase"
  name_prefix         = var.name_prefix
  location            = var.location
  resource_group_name = module.rg.name
  db_name             = var.db_name

  public_network_access_enabled = false

  enable_aad_admin     = true
  aad_admin_login_name = var.aad_admin_login_name
  aad_admin_object_id  = var.aad_admin_object_id

  db_sku_name                      = var.sql_db_sku_name
  db_zone_redundant                = var.sql_db_zone_redundant
  backup_short_term_retention_days = var.sql_backup_pitr_days

  private_endpoint_subnet_id   = module.network.subnet_ids["pep"]
  private_dns_zone_id_database = module.private_dns.zone_ids["privatelink.database.windows.net"]

  tags = var.tags
}

############################
# 5) SQL — Secondary (East)
############################
module "sql_secondary" {
  source              = "../degreed/terraformModules/sqlDatabase"
  name_prefix         = "${var.name_prefix}-sec"
  location            = var.secondary_location
  resource_group_name = module.rg.name
  db_name             = var.db_name

  public_network_access_enabled = false

  enable_aad_admin     = true
  aad_admin_login_name = var.aad_admin_login_name
  aad_admin_object_id  = var.aad_admin_object_id

  db_sku_name                      = var.sql_db_sku_name
  db_zone_redundant                = var.sql_db_zone_redundant
  backup_short_term_retention_days = var.sql_backup_pitr_days

  create_mode        = var.create_mode
  source_database_id = module.sql_primary.database_id

  private_endpoint_subnet_id   = module.network_secondary.subnet_ids["pep"]
  private_dns_zone_id_database = module.private_dns.zone_ids["privatelink.database.windows.net"]

  tags = var.tags
}


resource "azurerm_mssql_failover_group" "fog" {
  name      = "${var.name_prefix}-fog"
  server_id = module.sql_primary.server_id

  databases = [module.sql_primary.database_id]

  partner_server {
    id = module.sql_secondary.server_id
  }

  read_write_endpoint_failover_policy {
    mode          = "Automatic"
    grace_minutes = 60
  }

  tags = var.tags

  depends_on = [
    module.sql_secondary
  ]
}


############################
# App Service 
############################
module "app" {
  source              = "../degreed/terraformModules/appService"
  name_prefix         = var.name_prefix
  location            = var.location
  resource_group_name = module.rg.name

  plan_sku_name               = "P1v4"
  plan_zone_balancing_enabled = var.plan_zone_balancing_enabled
  enable_private_endpoint     = true

  private_endpoint_subnet_id        = module.network_secondary.subnet_ids["pep"]
  subnet_integration_id             = module.network.subnet_ids["integration"]
  private_dns_zone_id_azurewebsites = module.private_dns.zone_ids["privatelink.azurewebsites.net"]


  health_check_path = var.health_check_path

  extra_app_settings = {
    "Quotes__SqlServer" = "${azurerm_mssql_failover_group.fog.name}.database.windows.net"
    "Quotes__Database"  = module.sql_primary.database_name
  }

  tags = var.tags
}

############################
# 7) App Service 
############################
module "app_secondary" {
  source              = "../degreed/terraformModules/appService"
  name_prefix         = "${var.name_prefix}-2"
  location            = var.secondary_location
  resource_group_name = module.rg.name

  plan_sku_name               = "P1v4"
  plan_zone_balancing_enabled = var.plan_zone_balancing_enabled
  enable_private_endpoint     = true

  private_endpoint_subnet_id        = module.network_secondary.subnet_ids["pep"]
  subnet_integration_id             = module.network_secondary.subnet_ids["integration"]
  private_dns_zone_id_azurewebsites = module.private_dns.zone_ids["privatelink.azurewebsites.net"]


  health_check_path = var.health_check_path
  extra_app_settings = {
    "Quotes__SqlServer" = "${azurerm_mssql_failover_group.fog.name}.database.windows.net"
    "Quotes__Database"  = module.sql_primary.database_name
  }

  tags = var.tags
}

############################
# 8) Front Door (Standard) — two origins
############################
module "front_door" {
  source              = "../degreed/terraformModules/frontDoor"
  name_prefix         = var.name_prefix
  resource_group_name = module.rg.name

  app_hostnames = [
    module.app.default_hostname,
    module.app_secondary.default_hostname
  ]

  health_check_path = var.health_check_path
  tags              = var.tags
}

