data "azurerm_dns_zone" "default" {
  name                = var.dns_zone.name
  resource_group_name = var.dns_zone.resource_group_name
}

data "azurerm_cdn_frontdoor_profile" "default" {
  name                = var.cdn_frontdoor_profile.name
  resource_group_name = var.cdn_frontdoor_profile.resource_group_name
}
