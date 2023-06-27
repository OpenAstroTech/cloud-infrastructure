module "naming" {
  source = "../../naming"

  stage       = var.stage
  application = "config"
  component   = "fd"
}

resource "azurerm_cdn_frontdoor_custom_domain" "default" {
  name = "fdcd-${module.naming.value}"

  cdn_frontdoor_profile_id = data.azurerm_cdn_frontdoor_profile.default.id
  dns_zone_id              = data.azurerm_dns_zone.default.id

  host_name = join(".", [var.subdomain, var.dns_zone.name])

  tls {
    certificate_type    = "ManagedCertificate"
    minimum_tls_version = "TLS12"
  }
}

resource "azurerm_cdn_frontdoor_origin_group" "default" {
  name                     = "fdog-${module.naming.value}"
  cdn_frontdoor_profile_id = data.azurerm_cdn_frontdoor_profile.default.id

  health_probe {
    interval_in_seconds = 120
    path                = "/api/v1/status/health"
    protocol            = "Https"
    request_type        = "HEAD"
  }

  load_balancing {
    sample_size                        = 4
    successful_samples_required        = 3
    additional_latency_in_milliseconds = 50
  }
}

resource "azurerm_cdn_frontdoor_origin" "default" {
  for_each = var.origin_host_names
  name     = "fdo-${module.naming.value}-${each.key}"

  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.default.id
  enabled                       = true

  certificate_name_check_enabled = false

  host_name          = each.value
  http_port          = 80
  https_port         = 443
  origin_host_header = each.value
  priority           = 1
  weight             = 1
}

resource "azurerm_cdn_frontdoor_endpoint" "default" {
  name                     = "fde-${module.naming.value}"
  cdn_frontdoor_profile_id = data.azurerm_cdn_frontdoor_profile.default.id
}

resource "azurerm_cdn_frontdoor_route" "default" {
  name = "fdr-${module.naming.value}"

  cdn_frontdoor_endpoint_id       = azurerm_cdn_frontdoor_endpoint.default.id
  cdn_frontdoor_origin_group_id   = azurerm_cdn_frontdoor_origin_group.default.id
  cdn_frontdoor_custom_domain_ids = [azurerm_cdn_frontdoor_custom_domain.default.id]
  cdn_frontdoor_origin_ids        = [for origin in azurerm_cdn_frontdoor_origin.default : origin.id]

  forwarding_protocol    = "HttpsOnly"
  https_redirect_enabled = true
  patterns_to_match      = ["/*"]
  supported_protocols    = ["Http", "Https"]
}

resource "azurerm_cdn_frontdoor_custom_domain_association" "default" {
  cdn_frontdoor_custom_domain_id = azurerm_cdn_frontdoor_custom_domain.default.id
  cdn_frontdoor_route_ids        = [azurerm_cdn_frontdoor_route.default.id]
}

resource "azurerm_dns_txt_record" "default" {
  name = join(".", ["_dnsauth", var.subdomain])

  zone_name           = var.dns_zone.name
  resource_group_name = var.dns_zone.resource_group_name

  ttl = 300

  record {
    value = azurerm_cdn_frontdoor_custom_domain.default.validation_token
  }
}

resource "azurerm_dns_cname_record" "default" {
  depends_on = [azurerm_cdn_frontdoor_route.default]

  name                = var.subdomain
  zone_name           = var.dns_zone.name
  resource_group_name = var.dns_zone.resource_group_name
  ttl                 = 300
  record              = azurerm_cdn_frontdoor_endpoint.default.host_name
}
