#!/bin/bash

# You should have a kubernetes cluster up and running (I have a k3s cluster)

kubectl get nodes

# Check prerequisites using the Longhorn command line tool
curl -sSfL https://raw.githubusercontent.com/longhorn/longhorn/v1.4.1/scripts/environment_check.sh | bash

# Add the Longhorn Helm repository

helm repo add longhorn https://charts.longhorn.io

# Fetch the latest charts from the repository:

helm repo update

# Install longhorn version 1.9.1

helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace --version 1.9.1

# Check the status of the Longhorn deployment
helm status longhorn -n longhorn-system

# You should also confirm the deployment via state of the pods are running or not
kubectl get pods -n longhorn-system

echo "Visit this Github repository for more details - https://github.com/bwalia/devops.git"
