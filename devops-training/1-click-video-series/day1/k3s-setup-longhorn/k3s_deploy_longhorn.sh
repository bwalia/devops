#!/bin/bash

# Add the Longhorn Helm repository

helm repo add longhorn https://charts.longhorn.io

# Fetch the latest charts from the repository:

helm repo update

# Install longhorn version 1.9.1

helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace --version 1.9.1

# Confirm the deployment via pods are running
kubectl get pods -n longhorn-system

