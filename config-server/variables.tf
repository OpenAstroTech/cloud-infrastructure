variable "stage" {
  type = string
}

variable "location" {
  type = string
}

variable "regions" {
  type = map(object({
    geo_mappings = list(string)
  }))
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