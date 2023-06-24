module "db" {
  source = "./db"

  stage     = var.stage
  locations = keys(var.regions)
}

module "log" {
  source = "./log"

  stage    = var.stage
  location = var.location
}

module "capp_rg_naming" {
  source = "../naming"

  application = "config"
  component   = "app"
  stage       = var.stage
}

module "app" {
  for_each = toset(keys(var.regions))
  source   = "./app"

  stage    = var.stage
  location = each.value

  mongodb_connection_string = module.db.connection_string

  log_analytics_workspace_id = module.log.log_analytics_workspace_id
  application_insights_connection_string = module.log.application_insights_connection_string
}

module "front_door" {
  source = "./fd"

  stage                 = var.stage
  dns_zone              = var.dns_zone
  cdn_frontdoor_profile = var.cdn_frontdoor_profile

  subdomain = var.subdomain

  origin_host_names = { for app in module.app : app.location_short => app.fqdn }
}
