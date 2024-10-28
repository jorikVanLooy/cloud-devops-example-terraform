output "client_id_managed_identity" {
  value = azurerm_user_assigned_identity.mi_deploy_aca.client_id
}

output "tenant_id_managed_identity" {
  value = azurerm_user_assigned_identity.mi_deploy_aca.tenant_id
}
