variable "name_prefix" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}


variable "plan_sku_name" {
  type    = string
  default = "S1"
}

variable "plan_zone_balancing_enabled" {
  type    = bool
  default = false
}

variable "health_check_path" {
  type    = string
  default = "/healthz"

}

variable "enable_private_endpoint" {
  type    = bool
  default = true
}

variable "public_network_access_enabled" {
  type    = bool
  default = null
}

variable "vnet_route_all_enabled" {
  type    = bool
  default = true
}


variable "extra_app_settings" {
  type    = map(string)
  default = {}
}

variable "subnet_integration_id" {
  type = string
}

variable "private_endpoint_subnet_id" {
  type    = string
  default = null
}

variable "private_dns_zone_id_azurewebsites" {
  type    = string
  default = null
}


variable "tags" {
  type    = map(string)
  default = {}
}

variable "health_check_eviction_time_in_min" {
  type    = number
  default = 10
}
