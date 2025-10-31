variable "project" {
  type = string
}

variable "owner" {
  type = string
}

variable "environment" {
  type = string
}

variable "location" {
  type = string
}

variable "name_prefix" {
  type = string
}


variable "vnet_address_space" {
  type = list(string)
}

variable "subnets" {
  type = map(object({
    address_prefix = string
    purpose        = string
    associate_nsg  = optional(bool, true)
    nsg_rules = optional(list(object({
      name                         = string
      priority                     = number
      direction                    = string
      access                       = string
      protocol                     = string
      source_port_ranges           = optional(list(string))
      destination_port_ranges      = optional(list(string))
      source_address_prefixes      = optional(list(string))
      destination_address_prefixes = optional(list(string))
      source_address_prefix        = optional(string)
      destination_address_prefix   = optional(string)
      description                  = optional(string)
    })), [])
  }))
}


variable "private_dns_zones" {
  type = list(string)
}

variable "plan_sku_name" {
  type = string
}

variable "plan_zone_balancing_enabled" {
  type = bool
}

variable "health_check_path" {
  type    = string
  default = "/healthz"
}

variable "sql_db_sku_name" {
  type = string
}

variable "sql_db_zone_redundant" {
  type = bool
}

variable "sql_backup_pitr_days" {
  type = number
}

variable "aad_admin_login_name" {
  type = string
}

variable "aad_admin_object_id" {
  type = string
}


variable "tags" {
  type    = map(string)
  default = {}
}

variable "subscription_id" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "secondary_location" {
  type = string
}

variable "secondary_vnet_address_space" {
  type = list(string)
}

variable "secondary_subnets" {
  type = map(object({
    address_prefix = string
    purpose        = string
    associate_nsg  = bool
    nsg_rules      = list(any)
  }))
}

variable "db_name" {
  type = string
}

variable "peering_name_a_to_b" {
  type = string
}

variable "peering_name_b_to_a" {
  type = string
}

variable "create_mode" {
  type = string
}



