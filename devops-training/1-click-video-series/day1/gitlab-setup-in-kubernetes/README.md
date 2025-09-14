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

## check the deployment worked:

`kubectl -n gitlab-system get deployment gitlab-controller-manager`

# Install Gitlab Server

`kubectl -n gitlab-system apply -f deploy_gitlab_server.yaml`
# This can take 10-15m

# Next stage is to install some Gitlab runners so we can run jobs in CI CD section of the gitlab project repositories

`cp gitlab-runner-values-template.yaml gitlab-runner-values.yaml`

`replace variables as per your env`

ARCH=amd64
GITLAB_URL=your github server url or gitlab.com
REGISTRATION_TOKEN=<registration token> # Obtain from github project url
RUNNER_CONCURRENT=2 # set RUNNER_CONCURRENT to number of concurrent runners you wish to run in case of busy env you can set it to 20-40 default is 2

`sed -i '' "s/CLUSTER_IP_PLACEHOLDER/$LB_IP/g" gitlab-runner-values.yaml`
`sed -i '' "s/\${ARCH}/$ARCH/g" gitlab-runner-values.yaml`

`helm uninstall gitlab-runner-alpine -n gitlab-runner 2>/dev/null || true`
`run bash file you should 2 files config-runner-alpine.yaml and config-runner-ubuntu.yaml`
`to provide output of the template to deploy runners such as alpine or ubuntu docker images for runners`

# Study bash file deploy_gitlab_using_kubernetes_operator.sh

# Github repo url: https://github.com/bwalia/devops.git
