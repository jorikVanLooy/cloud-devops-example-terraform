output "client_id_managed_identity" {
  value = azurerm_user_assigned_identity.client_id
}

output "tenant_id_managed_identity" {
  value = azurerm_user_assigned_identity.tenant_id
}
