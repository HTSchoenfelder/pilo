#!/usr/bin/env bash

set -e

export ARM_SUBSCRIPTION_ID=$(az account show | jq -r .id)
export STATE_KEY="terraform.tfstate"
export CONTAINER_NAME="terraform-state"
export STORAGE_ACCOUNT_NAME=$(echo "$TF_VAR_resource_name" | tr -d '-')

echo "Resolving backend config ..."
envsubst <backend.tf.template >backend.resolved.tf
cat backend.resolved.tf

REMOTE_STATE_CHECK=$(terraform init 2>&1 || true)
echo $REMOTE_STATE_CHECK
if echo "$REMOTE_STATE_CHECK" | grep -q "Error retrieving keys"; then
  echo "REMOTE_STATE_CHECK contains 'Error retrieving keys'"
  INITIAL_DEPLOYMENT=true
else
  echo "Remote backend state found."
  INITIAL_DEPLOYMENT=false
fi

if [ "$INITIAL_DEPLOYMENT" = true ]; then
  echo "Performing initial deployment with a local backend..."

  mv backend.resolved.tf backend.resolved.tf.bak  

  terraform init -backend=false
  terraform apply -auto-approve

  mv backend.resolved.tf.bak backend.resolved.tf

  echo "Migrating local state to the remote backend..."

  terraform init \
    -force-copy \
    -input=false \
    -migrate-state

  echo "State successfully migrated to the remote backend."
else
  echo "Performing a follow-up deployment with the remote backend..."
  terraform apply -auto-approve
fi

echo "Deployment complete."
