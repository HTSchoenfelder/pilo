output "k3s_vm_ip_address" {
  value = azurerm_linux_virtual_machine.k3s_vm.public_ip_address
}

output "keyvault_name" {
  value = azurerm_key_vault.keyvault.name
}

output "k3s_vm_username" {
  value = azurerm_linux_virtual_machine.k3s_vm.admin_username
}

output "k3s_vm_fqdn" {
  value = azurerm_public_ip.vm_public_ip.fqdn
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "storage_account_name" {
  value = azurerm_storage_account.storage_account.name
}

output "container_name" {
  value = azurerm_storage_container.state_container.name
}

output "acr_token_name" {
  value = azurerm_container_registry_token.acr_token.name
}

output "acr_token_password" {
  sensitive = true
  value = azurerm_container_registry_token_password.acr_token_password.password1[0].value
}