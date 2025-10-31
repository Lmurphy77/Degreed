variable "resource_group_name" {
  type = string
}

variable "zone_names" {
  type = list(string)
}

variable "vnets" {
  type = list(object({
    id   = string
    name = string
  }))
}

variable "registration_enabled" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}

