module "dns" {
  source = "./dns"

  location = "westeurope"
  names    = ["cloud.openastrotech.com"]
}

module "front_door" {
  source = "./front-door"

  location = "westeurope"
}

moved {
  from = module.config_server
  to   = module.config_server["dev"]
}

module "config_server" {
  for_each = tomap({

    dev = {
      subdomain = "config-dev"
    }

    prod = {
      subdomain = "config"
    }

  })

  source = "./config-server"

  stage    = each.key
  location = "westeurope"
  regions = {
    "westeurope" = {
      geo_mappings = ["WORLD"]
    }
    "westus" = {
      geo_mappings = ["GEO-NA", "GEO-SA"]
    }
  }

  dns_zone = {
    name                = "cloud.openastrotech.com"
    resource_group_name = module.dns.resource_group_name
  }

  cdn_frontdoor_profile = module.front_door

  subdomain = each.value.subdomain
}