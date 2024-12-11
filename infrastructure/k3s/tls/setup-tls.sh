#!/usr/bin/env bash

set -e

NAMESPACE="cert-manager"
RELEASE_NAME="cert-manager"
CHART_NAME="jetstack/cert-manager"
REPO_URL="https://charts.jetstack.io"
VERSION="v1.16.2"

# Add and update Helm repository
helm repo add jetstack "$REPO_URL" --force-update
helm repo update

# Check if the release already exists
if ! helm status "$RELEASE_NAME" -n "$NAMESPACE" > /dev/null 2>&1; then
  echo "Release $RELEASE_NAME not found. Proceeding with installation..."
  helm install \
    "$RELEASE_NAME" "$CHART_NAME" \
    --namespace "$NAMESPACE" \
    --create-namespace \
    --version "$VERSION" \
    --set crds.enabled=true
else
  echo "Release $RELEASE_NAME already exists. No action needed."
fi

echo "Applying manifests ..."

cat cluster-issuer-production.yaml | envsubst | kubectl apply -f -
cat traefik-https-redirect-middleware.yaml | envsubst | kubectl apply -f -