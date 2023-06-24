resource "azurerm_resource_group" "default" {
  name     = "rg-dns"
  location = var.location
}

resource "azurerm_dns_zone" "names" {
  for_each = toset(var.names)

  name = each.key
  resource_group_name = azurerm_resource_group.default.name
}