#!/bin/bash

if [ -z "$1" ]; then
  echo "The env is empty, so setting ENV_REF to test (default)"
  ENV_REF="test"
else
   echo "The env is NOT empty, so setting ENV_REF to $1"
   ENV_REF=$1
fi

if [ -z "$ENV_REF" ]; then
  ENV_REF="test"
fi

helm uninstall minio-$ENV_REF --namespace $ENV_REF

echo "The minio is destroyed from Kubernetes successfully in the $ENV_REF namespace."

echo "Github repository - https://github.com/bwalia/devops.git"
