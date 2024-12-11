#!/usr/bin/env bash

SCRIPT_DIR=$(realpath "$(dirname "$0")")

cd "$SCRIPT_DIR/infrastructure/k3s/terraform"

echo "Getting terraform outputs ..."
# Export Terraform outputs to a JSON file
terraform output -json > tf_outputs.json

# Parse the JSON file to set environment variables
export K3S_VM_IP=$(jq -r '.k3s_vm_ip_address.value' tf_outputs.json)
export K3S_VM_USER_NAME=$(jq -r '.k3s_vm_username.value' tf_outputs.json)
export K3S_KEYVAULT_NAME=$(jq -r '.keyvault_name.value' tf_outputs.json)
export K3S_VM_FQDN=$(jq -r '.k3s_vm_fqdn.value' tf_outputs.json)
export ACR_LOGIN_SERVER=$(jq -r '.acr_login_server.value' tf_outputs.json)
export ACR_TOKEN_USER=$(jq -r '.acr_token_name.value' tf_outputs.json)
export ACR_TOKEN_PASSWORD=$(jq -r '.acr_token_password.value' tf_outputs.json)

echo "Setting KUBECONFIG ..."
export KUBECONFIG=~/.kube/config.k3s

export LATEST_COMMIT=$(git rev-parse HEAD)

cd "$SCRIPT_DIR"
