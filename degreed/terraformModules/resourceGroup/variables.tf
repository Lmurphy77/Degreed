variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "owner" {
  type    = string
  default = "devops"
}
