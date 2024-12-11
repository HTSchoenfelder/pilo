#!/usr/bin/env bash

set -e

SILENT_MODE=false
for arg in "$@"; do
    if [[ "$arg" == "--silent" ]]; then
        SILENT_MODE=true
        break
    fi
done

if [[ -z "$TF_VAR_resource_name" ]]; then
    echo "Error: TF_VAR_resource_name is not set. Exiting." >&2
    exit 1
fi

if [[ -z "$TF_VAR_resource_group_name" ]]; then
    echo "Error: TF_VAR_resource_group_name is not set. Exiting." >&2
    exit 1
fi

# Confirm TF_VAR_resource_name unless in --silent mode
if [[ "$SILENT_MODE" == false ]]; then
    echo "TF_VAR_resource_name is set to: $TF_VAR_resource_name"
    read -p "Proceed? (yes/no): " CONFIRM
    if [[ "$CONFIRM" != "yes" ]]; then
        echo "Aborting ..."
        exit 1
    fi
fi

echo "Proceeding with TF_VAR_resource_name: $TF_VAR_resource_name"

SCRIPT_DIR=$(realpath "$(dirname "$0")")

cd "$SCRIPT_DIR/infrastructure/k3s/terraform"
echo "Deploying infrastructure ..."
./deploy-infrastructure.sh

cd "$SCRIPT_DIR"
source ./set-variables.sh

cd "$SCRIPT_DIR/infrastructure/k3s/ansible"
echo "Deploying k3s ..."
./deploy-k3s.sh

cd "$SCRIPT_DIR/infrastructure/k3s/tls"
echo "Deploying tls resources"
./setup-tls.sh

cd "$SCRIPT_DIR/app"
echo "Deploying pilo"
./deploy-pilo.sh
