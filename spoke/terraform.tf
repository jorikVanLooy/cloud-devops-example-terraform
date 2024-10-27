terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.7.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-tf-state"
    storage_account_name = "terraformstatejorik"
    container_name       = "terraformstate"
    key                  = "terraform/"
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "resource_group" {
  name     = "rg-${var.env}"
  location = var.location

}
