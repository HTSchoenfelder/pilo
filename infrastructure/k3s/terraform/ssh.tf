resource "azapi_resource" "ssh_public_key" {
  type      = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  name      = local.resource_name
  location  = var.location
  parent_id = azurerm_resource_group.rg.id
}
resource "azapi_resource_action" "ssh_public_key_gen" {
  type        = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  resource_id = azapi_resource.ssh_public_key.id
  action      = "generateKeyPair"
  method      = "POST"

  response_export_values = ["publicKey", "privateKey"]
}

resource "azurerm_key_vault" "keyvault" {
  name                          = local.resource_name
  location                      = var.location
  resource_group_name           = azurerm_resource_group.rg.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  purge_protection_enabled      = false
  enable_rbac_authorization     = true
  public_network_access_enabled = true
  network_acls {
    bypass         = "AzureServices"
    default_action = "Allow"
  }
}

resource "azurerm_key_vault_secret" "ssh_private_key" {
  name         = "ssh-private-key"
  value        = azapi_resource_action.ssh_public_key_gen.output.privateKey
  key_vault_id = azurerm_key_vault.keyvault.id
  depends_on   = [null_resource.wait_for_propagation]
}

data "azurerm_client_config" "current" {}

resource "azurerm_role_assignment" "key_vault_access" {
  scope                = azurerm_key_vault.keyvault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "null_resource" "wait_for_propagation" {
  provisioner "local-exec" {
    command = <<EOT
    for i in {1..10}; do
      az keyvault secret list --vault-name $(terraform output -raw keyvault_name) >/dev/null 2>&1 && exit 0
      sleep 10
    done
    echo "Role assignment did not propagate in time." >&2
    exit 1
    EOT
  }

  depends_on = [azurerm_role_assignment.key_vault_access]
}
