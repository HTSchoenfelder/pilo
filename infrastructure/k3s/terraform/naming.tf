locals {
  resource_name       = var.resource_name
  resource_name_short = replace(local.resource_name, "-", "")
  resource_group_name = var.resource_group_name
}

