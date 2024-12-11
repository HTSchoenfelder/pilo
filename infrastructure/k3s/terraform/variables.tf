variable "location" {
  type    = string
  default = "westeurope"
}

variable "username" {
  type        = string
  description = "The username for the local account that will be created on the new VM."
}

variable "resource_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}