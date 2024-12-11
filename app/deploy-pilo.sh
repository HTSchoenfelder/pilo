#!/usr/bin/env bash

set -e

export LATEST_COMMIT=$(git rev-parse HEAD)

# Function to check if an image exists in ACR
function image_exists() {
  local repository=$1
  local tag=$2
  az acr repository show-tags \
    --name "$ACR_LOGIN_SERVER" \
    --repository "$repository" \
    --query "contains(@, '$tag')" \
    --output tsv
}

# Build pilo-api if the image doesn't exist
if [[ "$(image_exists pilo-api $LATEST_COMMIT)" != "true" ]]; then
  echo "Image pilo-api:$LATEST_COMMIT not found. Building..."
  az acr build ./pilo-api -r $ACR_LOGIN_SERVER -t pilo-api:$LATEST_COMMIT
else
  echo "Image pilo-api:$LATEST_COMMIT already exists. Skipping build."
fi

# Build pilo-app if the image doesn't exist
if [[ "$(image_exists pilo-app $LATEST_COMMIT)" != "true" ]]; then
  echo "Image pilo-app:$LATEST_COMMIT not found. Building..."
  az acr build ./pilo-app -r $ACR_LOGIN_SERVER -t pilo-app:$LATEST_COMMIT
else
  echo "Image pilo-app:$LATEST_COMMIT already exists. Skipping build."
fi

echo "Waiting for the images to be available..."
sleep 10

helm upgrade --install pilo ./helm/pilo \
  --namespace pilo-app \
  --create-namespace \
  --set acrLoginServer="$ACR_LOGIN_SERVER" \
  --set latestCommit="$LATEST_COMMIT" \
  --set ingressHost="$K3S_VM_FQDN"
