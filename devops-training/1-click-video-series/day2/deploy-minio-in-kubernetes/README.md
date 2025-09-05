### Infrastructure Setup - Day 2 - Typical Task 2

#   Here is a simple **bash script** `minio-deploy.sh` to create minio instance in Kubernetes.
#   Typically you would use this script for **k3s** kubernetes cluster on prem or dev test cluster. However the process should work with EKS/GKE/AKS just update the storage class and other parameters accordingly.
#   This script will also create the necessary pvc in longhorn storage class on prem

---

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

helm upgrade --install -f minio-helm-chart/values.yaml minio-$ENV_REF ./minio-helm-chart \
      --set-string namespaceRef="$ENV_REF" \
      --set-string pvcStorageSize="1Gi" \
      --set secrets.MINIO_ROOT_USER=minioadmin \
      --set secrets.MINIO_ROOT_PASSWORD=$PASSWORD \
      --set secrets.MINIO_BROWSER_REDIRECT_URL=https://$ENV_REF-s3.workstation.co.uk \
      --set secrets.MINIO_DEFAULT_BUCKETS=test-images \
      --set-string "uiIngress.hosts[0].host=$ENV_REF-s3.workstation.co.uk" \
      --set-string "cliIngress.hosts[0].host=$ENV_REF-s3-cli.workstation.co.uk" \
      --namespace $ENV_REF --create-namespace

echo "The minio is deployed into Kubernetes successfully in the $ENV_REF namespace."

echo "Github repository - https://github.com/bwalia/devops.git"


---

### Note: To test copy a file to newly created bucket run

Run the following command:

```bash
./minio-copy-test.sh env password
```

---

### Note: To destroy the minio instance

Run the following command:

```bash
./minio-destroy.sh
```
