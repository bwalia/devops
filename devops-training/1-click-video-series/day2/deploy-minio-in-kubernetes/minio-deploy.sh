#!/bin/bash

helm upgrade --install -f minio-helm-chart/values.yaml minio-test ./minio-helm-chart \
      --set-string namespaceRef="test" \
      --set-string pvcStorageSize="1Gi" \
      --set secrets.MINIO_ROOT_USER=minioadmin \
      --set secrets.MINIO_ROOT_PASSWORD=miniopassword \
      --set secrets.MINIO_BROWSER_REDIRECT_URL=https://test-s3.workstation.co.uk \
      --set secrets.MINIO_DEFAULT_BUCKETS=test-images \
      --set-string "uiIngress.hosts[0].host=test-s3.workstation.co.uk" \
      --set-string "cliIngress.hosts[0].host=test-s3-cli.workstation.co.uk" \
      --namespace test --create-namespace

echo "The minio is deployed into Kubernetes successfully"

echo "Github repository - https://github.com/bwalia/devops.git"

sleep 10
