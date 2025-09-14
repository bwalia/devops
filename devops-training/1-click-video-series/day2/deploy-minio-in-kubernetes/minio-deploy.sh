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

# Generate a random password
PASSWORD=$(head -c 16 /dev/urandom | base64 | tr -dc 'a-zA-Z0-9')

# Display the password
echo "Minio Admin user: minioadmin and password is: $PASSWORD"

echo $PASSWORD > /tmp/minio-credentials-$ENV_REF.txt

if [ "$ENV_REF" == "prod" ]; then
    ENV_UI_ENDPOINT=s3.workstation.co.uk
    ENV_API_ENDPOINT=s3-cli.workstation.co.uk
        elif [ "$ENV_REF" == "test" ]; then
        ENV_UI_ENDPOINT=$ENV_REF-s3.workstation.co.uk
        ENV_API_ENDPOINT=$ENV_REF-s3-cli.workstation.co.uk
            elif [ "$ENV_REF" == "acc" ]; then
            ENV_UI_ENDPOINT=$ENV_REF-s3.workstation.co.uk
            ENV_API_ENDPOINT=$ENV_REF-s3-cli.workstation.co.uk
        elif [ "$ENV_REF" == "dev" ]; then
        ENV_UI_ENDPOINT=$ENV_REF-s3.workstation.co.uk
        ENV_API_ENDPOINT=$ENV_REF-s3-cli.workstation.co.uk
fi

helm upgrade --install -f minio-helm-chart/values.yaml minio-$ENV_REF ./minio-helm-chart \
      --set-string namespaceRef="$ENV_REF" \
      --set-string pvStorageClass="longhorn" \
      --set-string pvcStorageSize="1Gi" \
      --set secrets.MINIO_ROOT_USER=minioadmin \
      --set secrets.MINIO_ROOT_PASSWORD=$PASSWORD \
      --set secrets.MINIO_BROWSER_REDIRECT_URL=https://$ENV_REF-s3.workstation.co.uk \
      --set secrets.MINIO_DEFAULT_BUCKETS=test-images \
      --set-string "uiIngress.hosts[0].host=$ENV_UI_ENDPOINT" \
      --set-string "cliIngress.hosts[0].host=$ENV_API_ENDPOINT" \
      --namespace $ENV_REF --create-namespace

echo "The minio is deployed into Kubernetes successfully in the $ENV_REF namespace."

echo "Github repository - https://github.com/bwalia/devops.git"

echo "The minio instance is up and running."

echo "You can access the Minio Console at: https://$ENV_UI_ENDPOINT"

echo "You can access the Minio S3 API at: https://$ENV_API_ENDPOINT"

echo "You can copy files to the Minio S3 bucket using the following command:"

echo "bash minio-copy-test.sh <env> <password>"
