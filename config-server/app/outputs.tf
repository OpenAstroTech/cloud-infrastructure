output "fqdn" {
  value = azurerm_container_app.oatconf.ingress[0].fqdn
}

output "location_short" {
  value = module.name_suffix.location_short
}