module "name_suffix" {
  source = "../../naming"

  application = "config"
  component   = "db"
  stage       = var.stage
}

resource "azurerm_resource_group" "db" {
  name     = "rg-${module.name_suffix.value}"
  location = var.locations[0]
}

resource "azurerm_cosmosdb_account" "db" {
  name                = "cosmon-${module.name_suffix.value}"
  resource_group_name = azurerm_resource_group.db.name
  location            = azurerm_resource_group.db.location

  offer_type           = "Standard"
  kind                 = "MongoDB"
  mongo_server_version = "4.2"

  enable_automatic_failover = true

  capacity {
    total_throughput_limit = 400
  }

  # capabilities {
  #   name = "EnableServerless"
  # }

  # capabilities {
  #   name = "DisableRateLimitingResponses"
  # }

  capabilities {
    name = "EnableMongo"
  }

  capabilities {
    name = "EnableAggregationPipeline"
  }

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }

  dynamic "geo_location" {
    for_each = var.locations

    content {
      location          = geo_location.value
      failover_priority = index(var.locations, geo_location.value)
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}
