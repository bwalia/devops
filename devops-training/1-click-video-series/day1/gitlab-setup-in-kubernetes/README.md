# bash script to deploy Gitlab cluster in kubernetes via operator.

`bash gitlab_deploy_using_kubernetes_operator.sh`

# Step prerequisities

# Install Cert manager in the kubernetes cluster 

`bash deploy_cert-manager.sh`

# Step 1 Install gitlab operator using helm reference:

# https://docs.gitlab.com/operator/installation/?tab=Helm+Chart

`helm repo add gitlab https://charts.gitlab.io`
`helm repo update`

`helm install gitlab-operator gitlab/gitlab-operator \`
  `--create-namespace \`
  `--namespace gitlab-system`

# sleep 30


# Next stage is to install some Gitlab runners so we can run jobs in CI CD section of the gitlab project repositories

`cp gitlab-runner-values-template.yaml gitlab-runner-values.yaml`

`sed -i '' "s/CLUSTER_IP_PLACEHOLDER/$LB_IP/g" gitlab-runner-values.yaml`
`sed -i '' "s/\${ARCH}/$ARCH/g" gitlab-runner-values.yaml`

`helm uninstall gitlab-runner-2 -n gitlab-runner 2>/dev/null || true`

# sleep 10

`helm install gitlab-runner-2 gitlab/gitlab-runner \`
  `--namespace gitlab-runner \`
  `--values gitlab-runner-values.yaml \`
  `--set runnerRegistrationToken="$RUNNER_TOKEN" \`
  `--set rbac.create=true \`
  `--set rbac.clusterWideAccess=true`
