#!/bin/bash
# bash script to deploy cert-manager.

helm install \
  cert-manager oci://quay.io/jetstack/charts/cert-manager \
  --version v1.18.2 \
  --namespace cert-manager \
  --create-namespace \
  --set crds.enabled=true

sleep 30

kubectl -n cert-manager get deployment cert-manager
kubectl -n cert-manager get deployment cert-manager-webhook
kubectl -n cert-manager get deployment cert-manager-cainjector