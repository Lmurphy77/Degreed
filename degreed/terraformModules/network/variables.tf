variable "name_prefix" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }

variable "address_space" {
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

variable "tags" {
  type    = map(string)
  default = {}
}
