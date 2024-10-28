
resource "azurerm_log_analytics_workspace" "workspace-java" {
  name                = "workspace-${var.env}-java"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "aca_env-java" {
  name                       = "${var.env}-environment-java"
  location                   = data.azurerm_resource_group.rg.location
  resource_group_name        = data.azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace-java.id
}

resource "azurerm_container_app" "aca-dev-java" {
  name                         = "${var.env}-app-java"
  container_app_environment_id = azurerm_container_app_environment.aca_env-java.id
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

resource "azurerm_user_assigned_identity" "mi-deploy-aca-java" {
  name                = "mi-aca-java-${var.env}-java"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_role_assignment" "deploy-dev-java" {
  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.mi-deploy-aca-java.principal_id

}

resource "azurerm_federated_identity_credential" "deploy-app-java" {
  name                = "deploy-java-${var.env}-java"
  resource_group_name = data.azurerm_resource_group.rg.name
  issuer              = "https://token.actions.githubusercontent.com"
  subject             = "repo:${var.GH_organization}/${var.GH_repo-java}:environment:${var.env}"
  parent_id           = azurerm_user_assigned_identity.mi-deploy-aca-java.id
  audience            = ["api://AzureADTokenExchange"]

}

