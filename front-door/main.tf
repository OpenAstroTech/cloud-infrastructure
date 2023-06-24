resource "azurerm_resource_group" "fd" {
  name     = "rg-fd"
  location = var.location
}

resource "azurerm_cdn_frontdoor_profile" "default" {
  name                = "fdp-default"
  resource_group_name = azurerm_resource_group.fd.name

  sku_name = "Standard_AzureFrontDoor"
}