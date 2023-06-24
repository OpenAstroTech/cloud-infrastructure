output "location_short" {
  value = var.region != "" ? module.region.location_short : ""
}

output "value" {
  value = join("-", flatten([
    var.application,
    var.component != "" ? [var.component] : [],
    var.stage != "" ? [var.stage] : [],
    var.region != "" ? [module.region.location_short] : []
  ]))
}

output "tags" {
  value = merge(
    {
      application = var.application
      stage       = var.stage
    },
    var.component != "" ? { component = var.component } : null,
    var.region != "" ? { region = var.region } : null
  )
}
