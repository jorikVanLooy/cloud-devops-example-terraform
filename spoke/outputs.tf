output "client_id_managed_identity-java" {
  value = azurerm_user_assigned_identity.mi-deploy-aca-java.client_id
}

output "client_id_managed_identity-dotnet" {
  value = azurerm_user_assigned_identity.mi-deploy-aca-dotnet.client_id
}
