module "name_suffix" {
  source = "../../naming"

  application = "config"
  component   = "app"
  stage       = var.stage
  region      = var.location
}

resource "azurerm_resource_group" "oatconf" {
  name     = "rg-${module.name_suffix.value}"
  location = var.location
}

resource "azurerm_container_app_environment" "oatconf" {
  name                       = "cae-${module.name_suffix.value}"
  location                   = azurerm_resource_group.oatconf.location
  resource_group_name        = azurerm_resource_group.oatconf.name
  log_analytics_workspace_id = var.log_analytics_workspace_id
}

resource "azurerm_container_app" "oatconf" {
  name                         = "ca-${module.name_suffix.value}"
  container_app_environment_id = azurerm_container_app_environment.oatconf.id
  resource_group_name          = azurerm_resource_group.oatconf.name
  revision_mode                = "Single"

  secret {
    name  = "mongo-connection-string"
    value = var.mongodb_connection_string
  }

  secret {
    name  = "appinsights-connection-string"
    value = var.application_insights_connection_string
  }

  template {
    container {
      name   = "config-server"
      image  = "openastrotech/config-server:latest"
      cpu    = "0.25"
      memory = "0.5Gi"

      env {
        name        = "MONGO_CONNECTION_STRING"
        secret_name = "mongo-connection-string"
      }

      env {
        name        = "APPINSIGHTS_CONNECTION_STRING"
        secret_name = "appinsights-connection-string"
      }
    }
  }

  ingress {
    target_port                = 80
    external_enabled           = true
    allow_insecure_connections = false

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }

  }

  tags = merge(
    {
      image = "openastrotech/config-server"
    },
    module.name_suffix.tags
  )
}
