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
  subscription_id = var.subscription_id
  features {}
  client_id     = var.client_id
  tenant_id     = var.tenant_id
  client_secret = var.client_secret
}

data "azurerm_resource_group" "rg-hub" {
  name = "rg-hub"
}
