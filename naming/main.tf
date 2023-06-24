module "region" {
  source       = "claranet/regions/azurerm"
  azure_region = var.region != "" ? var.region : "global"
}