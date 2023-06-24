module "name_suffix" {
  source = "../../naming"

  application = "config"
  component = "log"
  stage  = var.stage
}

resource "azurerm_resource_group" "log" {
  name     = "rg-${module.name_suffix.value}"
  location = var.location
}

resource "azurerm_log_analytics_workspace" "log" {
  name                = "log-${module.name_suffix.value}"
  location            = azurerm_resource_group.log.location
  resource_group_name = azurerm_resource_group.log.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "log" {
  name                = "appi-${module.name_suffix.value}"
  location            = azurerm_resource_group.log.location
  resource_group_name = azurerm_resource_group.log.name
  workspace_id        = azurerm_log_analytics_workspace.log.id
  application_type    = "web"
}
