terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "tfstate174011566"
    container_name       = "default"
    key                  = "default.tfstate"
  }
}
