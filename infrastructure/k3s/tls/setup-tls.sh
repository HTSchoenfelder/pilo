#!/usr/bin/env bash

set -e

helm repo add jetstack "https://charts.jetstack.io" --force-update
helm repo update
helm upgrade -install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.16.2 --set installCRDs=true

echo "Applying manifests ..."

cat cluster-issuer-production.yaml | envsubst | kubectl apply -f -
cat traefik-https-redirect-middleware.yaml | envsubst | kubectl apply -f -