variable "vnet_id_a" {
  type = string
}
variable "vnet_id_b" {
  type = string
}

variable "peering_name_a_to_b" {
  type = string
}

variable "peering_name_b_to_a" {
  type = string
}

variable "allow_virtual_network_access" {
  type    = bool
  default = true
}

variable "allow_forwarded_traffic_a_to_b" {
  type    = bool
  default = false
}

variable "allow_forwarded_traffic_b_to_a" {

  type    = bool
  default = false
}

variable "allow_gateway_transit_a_to_b" {
  type    = bool
  default = false
}
variable "allow_gateway_transit_b_to_a" {
  type    = bool
  default = false
}

variable "use_remote_gateways_a_to_b" {
  type    = bool
  default = false
}

variable "use_remote_gateways_b_to_a" {
  type    = bool
  default = false
}

variable "resource_group_name_a" {
  type = string
}

variable "vnet_name_a" {
  type = string
}

variable "resource_group_name_b" {
  type = string
}

variable "vnet_name_b" {
  type = string
}



