#!/bin/bash

helm uninstall minio-test --namespace test
echo "The minio is uninstalled from Kubernetes successfully"
