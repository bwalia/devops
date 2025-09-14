#!/bin/bash
# bash script to deploy cert-manager.

VM_NAME="k3s-worker1"

if multipass list | awk 'NR>1 {print $1}' | grep -qw "$VM_NAME"; then
    echo "VM '$VM_NAME' exists."
else
    echo "VM '$VM_NAME' does not exist."
fi

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