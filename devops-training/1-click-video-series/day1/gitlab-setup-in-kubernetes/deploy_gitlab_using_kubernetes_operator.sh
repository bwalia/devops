#!/bin/bash

# bash script to deploy Gitlab cluster in kubernetes via operator.
# Run this bash file manually to deploy Gitlab(  Gitlab ce, gitlab runner) via operator.
# Prerequisite: kubernetes cluster with ingress-nginx controller installed and configured.
# Prerequisite: helm installed and configured.
# Prerequisite: kubectl installed and configured.
# Prerequisite: openssl installed.
# To install gitlab using helm chart please checkout my other video https://www.youtube.com/@BalinderWalia
# Run this bash file manually to deploy Gitlab( Gitlab ce, gitlab runner, Nexus registry and many other gitlab pipeline demos), after creating the cluster with the create_cluster.sh.

helm repo add gitlab https://charts.gitlab.io
helm repo update

helm install gitlab-operator gitlab/gitlab-operator \
  --create-namespace \
  --namespace gitlab-system

# sleep 30

# Install Gitlab Server via operator
kubectl -n gitlab-system get deployment gitlab-controller-manager
kubectl -n gitlab-system apply -f deploy_gitlab_server.yaml

# LB_IP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# ARCH=amd64
# #$(uname -m)

# cp gitlab-runner-values-template.yaml gitlab-runner-values.yaml
# sed -i '' "s/CLUSTER_IP_PLACEHOLDER/$LB_IP/g" gitlab-runner-values.yaml
# sed -i '' "s/\${ARCH}/$ARCH/g" gitlab-runner-values.yaml

cat > gitlab-runner-secret.yml << EOF
apiVersion: v1
kind: Secret
metadata:
  name: gitlab-runner-secret
type: Opaque
# Only one of the following fields can be set. The Operator fails to register the runner if both are provided.
# NOTE: runner-registration-token is deprecated and will be removed in GitLab 18.0. You should use runner-token instead.
stringData:
  runner-token: REPLACE_ME # your project runner token
  # runner-registration-token: "" # your project runner secret
EOF

# helm install gitlab-runner gitlab/gitlab-runner \
#   --namespace gitlab-runner \
#   --values gitlab-runner-values.yaml \
#   --set runnerRegistrationToken="$RUNNER_TOKEN" \
#   --set rbac.create=true \
#   --set rbac.clusterWideAccess=true

# Setup Gitlab Runner via operator
# Gitlab Server URL and runner token
# Please update the REGISTRATION_TOKEN value below with your actual registration token from Gitlab UI or API
# Change docker image to run in this runner via image: "alpine/git:latest" below
# You can create multiple runners with different config files and names
# For example config-runner-ubuntu.yaml below is another runner with ubuntu image
# You can also create your own custom docker image with all the tools you need in your CI
GITLAB_URL=http://gitlab-webservice-default.gitlab-system.svc.cluster.local:8080/
RUNNER_CONCURRENT=2
RUNNER_DOCKER_IMAGE_TAG=alpine3.19-x86_64-bleeding
# Obtain the registration token from GitLab UI or API
# or via kubectl if you have access to the GitLab instance
# Example: kubectl get secret gitlab-gitlab-runner-secret -n gitlab-system -ojsonpath='{.data.runner-registration-token}' | base64 -d

# REGISTRATION_TOKEN=<your_registration_token>
REGISTRATION_TOKEN="<your_registration_token>"

cat > config-runner-alpine.yaml << EOF
gitlabUrl: ${GITLAB_URL}
runnerRegistrationToken: "${REGISTRATION_TOKEN}"
concurrent: ${RUNNER_CONCURRENT}
rbac:
  create: true
  clusterWideAccess: true
runners:
  privileged: true
  config: |
    [[runners]]
      environment = ["GIT_SSL_NO_VERIFY=1"]
      [runners.kubernetes]
        namespace = "gitlab-runner"
        image = "alpine/git:latest"
        helper_image = "registry.gitlab.com/gitlab-org/gitlab-runner/gitlab-runner-helper:${RUNNER_DOCKER_IMAGE_TAG}"
        helper_image_flavor = "alpine"
        service_account = "gitlab-runner"
        privileged = true
        [[runners.kubernetes.host_aliases]]
          ip = "CLUSTER_IP_PLACEHOLDER"
          hostnames = ["gitlab-webservice-default.gitlab-system.svc.cluster.local", "gitlab.workstation.co.uk","gitlab.local", "registry.local", "docker-registry.docker-registry.svc.cluster.local"]
        [[runners.kubernetes.services]]
          name = "docker"
          alias = "docker"
          image = "docker:24.0.6-dind"
          command = ["dockerd", "--host=tcp://0.0.0.0:2376", "--tls=false", "--insecure-registry=docker-registry.docker-registry.svc.cluster.local:5000", "--insecure-registry=docker-registry.docker-registry:5000", "--registry-mirror=https://mirror.gcr.io"]
          privileged = true
        [runners.kubernetes.dns_config]
          nameservers = ["10.43.0.10"]
          searches = ["gitlab-system.svc.cluster.local", "gitlab.svc.cluster.local", "docker-registry.svc.cluster.local", "default.svc.cluster.local", "svc.cluster.local", "cluster.local"]
        [[runners.kubernetes.volumes.secret]]
          name = "kubeconfig"
          mount_path = "/etc/kubeconfig"
          read_only = true
image:
  tag: alpine3.18-v16.11.1

EOF

helm upgrade --install --namespace gitlab-runner gitlab-runner-alpine -f config-runner-alpine.yaml --set serviceAccount.create=true gitlab/gitlab-runner --create-namespace
sleep 10

# REGISTRATION_TOKEN=<your_registration_token>
REGISTRATION_TOKEN="glrt-Dn45apgRT5SWIGyeKwFG3G86MQpwOjIKdDozCnU6MQ8.01.171x3cegy"

cat > config-runner-ubuntu.yaml << EOF
gitlabUrl: ${GITLAB_URL}
runnerRegistrationToken: "${REGISTRATION_TOKEN}"
concurrent: 2
rbac:
  create: true

runners:
  secret: gitlab-runner-ubuntu-secret
  config: |
    [[runners]]
      [runners.kubernetes]
        namespace = "gitlab-runner"
        image = "ubuntu:22.04"
        privileged = true
      [[runners.kubernetes.volumes.empty_dir]]
        name = "docker-certs"
        mount_path = "/certs/client"
        medium = "Memory"

  ## Specify the name for the runner.
  name: "gitlab-runner-ubuntu"

EOF

helm upgrade --install --namespace gitlab-runner gitlab-runner-ubuntu -f config-runner-ubuntu.yaml --set serviceAccount.create=true gitlab/gitlab-runner --create-namespace
sleep 10
kubectl -n gitlab-runner get pods