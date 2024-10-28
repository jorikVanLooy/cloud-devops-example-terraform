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

data "azurerm_resource_group" "rg" {
  name = "rg-${var.env}"
}

resource "azurerm_log_analytics_workspace" "workspace" {
  name                = "workspace-${var.env}"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "aca_env" {
  name                       = "${var.env}-environment"
  location                   = data.azurerm_resource_group.rg.location
  resource_group_name        = data.azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id
}

resource "azurerm_container_app" "aca-dev" {
  name                         = "${var.env}-app"
  container_app_environment_id = azurerm_container_app_environment.aca_env.id
  resource_group_name          = data.azurerm_resource_group.rg.name
  revision_mode                = "Single"

  ingress {
    target_port      = 8080
    external_enabled = true

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {
    container {
      name   = "java-react-example-app"
      image  = "docker.io/jorikvl/cloud-devops-example:latest"
      cpu    = 0.25
      memory = "0.5Gi"

    }
  }

  lifecycle {
    ignore_changes = [
      template[0].container["image"]
    ]
  }

}

resource "azurerm_container_app" "aca-uat" {
  count = var.env == "dev" ? 1 : 0

  name                         = "${var.env}-app-uat"
  container_app_environment_id = azurerm_container_app_environment.aca_env.id
  resource_group_name          = data.azurerm_resource_group.rg.name
  revision_mode                = "Single"

  ingress {
    target_port      = 8080
    external_enabled = true

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {
    container {
      name   = "java-react-example-app"
      image  = "docker.io/jorikvl/cloud-devops-example:latest"
      cpu    = 0.25
      memory = "0.5Gi"

    }
  }


  lifecycle {
    ignore_changes = [
      template[0].container["image"]
    ]
  }
}


resource "azurerm_user_assigned_identity" "mi-deploy-aca" {
  name                = "mi-aca-${var.env}"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_role_assignment" "deploy-dev" {
  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.mi-deploy-aca.id

}

resource "azurerm_federated_identity_credential" "deploy-app" {
  name                = "deploy-${var.env}"
  resource_group_name = data.azurerm_resource_group.rg
  issuer              = "https://token.actions.githubusercontent.com"
  subject             = "repo:${var.GH_organization}/${var.GH_repo}:environment:${var.env}"
  parent_id           = azurerm_user_assigned_identity.mi-deploy-aca.id
  audience            = "api://AzureADTokenExchange"

}

