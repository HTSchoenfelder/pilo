#!/usr/bin/env bash

set -e

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm upgrade --install loki grafana/loki -f loki-values.yaml --namespace monitoring --create-namespace

envsubst -i grafana-values.yaml -o grafana-values.resolved.yaml
helm upgrade --install grafana grafana/grafana -f grafana-values.resolved.yaml --namespace monitoring --create-namespace

helm upgrade --install alloy grafana/alloy --namespace monitoring --create-namespace

kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode | wl-copy 
