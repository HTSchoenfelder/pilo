#!/usr/bin/env bash

envsubst -i ./k8s/overlays/dev/patch.yaml -o ./k8s/overlays/dev/patch.resolved.yaml

kustomize build ./k8s/overlays/dev | kubectl apply -f -
