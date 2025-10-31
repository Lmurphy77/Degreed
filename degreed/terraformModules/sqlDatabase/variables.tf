variable "name_prefix" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "public_network_access_enabled" {
  type    = bool
  default = false
}

variable "administrator_login" {
  type    = string
  default = null
}

variable "administrator_login_password" {
  type      = string
  default   = null
  sensitive = true
}

variable "db_sku_name" {
  type    = string
  default = "BC_Gen5_2"
}

variable "db_zone_redundant" {
  type    = bool
  default = true
}

variable "backup_short_term_retention_days" {
  type    = number
  default = 7
}

variable "private_endpoint_subnet_id" {
  type = string
}

variable "private_dns_zone_id_database" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "aad_admin_login_name" {
  type    = string
  default = null
}

variable "aad_admin_object_id" {
  type    = string
  default = null
}

variable "enable_aad_admin" {
  type    = bool
  default = true
}

variable "db_name" {
  type = string
}

variable "create_mode" {
  type    = string
  default = "Default"
}

variable "source_database_id" {
  type    = string
  default = null
}
