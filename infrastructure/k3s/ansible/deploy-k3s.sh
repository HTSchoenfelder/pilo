#!/usr/bin/env bash

set -e

az keyvault secret show --vault-name $K3S_KEYVAULT_NAME --name "ssh-private-key" --query value -o tsv > ~/.ssh/id_ansible_vm
chmod 600 ~/.ssh/id_ansible_vm
ansible-playbook ./playbooks/site.yml \
    -i ./inventory.yml \
    --private-key ~/.ssh/id_ansible_vm \
    -e "server_fqdn=${K3S_VM_FQDN}" \
    -e "server_username=${K3S_VM_USER_NAME}" \
    -e "registry=${ACR_LOGIN_SERVER}" \
    -e "registry_username=${ACR_TOKEN_USER}" \
    -e "registry_password=${ACR_TOKEN_PASSWORD}"

echo "Waiting for CRD objects ..."
sleep 30