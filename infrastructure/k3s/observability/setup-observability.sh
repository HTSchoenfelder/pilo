#!/usr/bin/env bash

set -e

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm upgrade --install loki grafana/loki -f values.yaml --namespace monitoring --create-namespace
helm upgrade --install grafana grafana/grafana --namespace monitoring --create-namespace
helm upgrade --install alloy grafana/alloy --namespace monitoring --create-namespace