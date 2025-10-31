variable "name_prefix" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "app_hostnames" {
  type = list(string)
}

variable "health_check_path" {
  type    = string
  default = "/healthz"
}

variable "tags" {
  type    = map(string)
  default = {}
}
