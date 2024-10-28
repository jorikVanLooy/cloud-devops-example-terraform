output "client_id_managed_identity" {
  value = azurerm_user_assigned_identity.mi-deploy-aca.client_id
}

output "tenant_id_managed_identity" {
  value = azurerm_user_assigned_identity.mi-deploy-aca.tenant_id
}
