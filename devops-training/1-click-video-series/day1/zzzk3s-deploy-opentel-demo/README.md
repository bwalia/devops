### Kubernetes Setup - Day 1 - Typical Task 4

Here's a simple **bash script** `k3s_deploy_elasticsearch.sh` to install elk stack with kibana ui and elastic search server and api in HA storage using operator

### 📄 `k3s_deploy_elasticsearch.sh`

# Install the Elastic Operator
helm install elastic-operator elastic/eck-operator -n elastic-system --create-namespace

# Deploy Elasticsearch cluster see bash script

Note: change storage system to longhorn in this case, you can use default storage class openebs or localpath etc.
        storageClassName: longhorn

# Deploy kibana 

Note: change the elastic search url to point to your elasticsearch cluster
    server.publicBaseUrl: https://elastic.workstation.co.uk

# Deploy the ingress 

Note: use a domain name that points to your k3s elasticsearch cluster example

    elasticapi.workstation.co.uk

echo "Visit this Github repository for more details - https://github.com/bwalia/devops.git"
