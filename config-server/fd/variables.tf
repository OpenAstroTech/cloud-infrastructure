variable "stage" {
  type = string
}

variable "cdn_frontdoor_profile" {
  type = object({
    name                = string
    resource_group_name = string
  })
}

variable "dns_zone" {
  type = object({
    name                = string
    resource_group_name = string
  })
}

variable "subdomain" {
  type = string
}

variable "origin_host_names" {
  type = map(string)
}