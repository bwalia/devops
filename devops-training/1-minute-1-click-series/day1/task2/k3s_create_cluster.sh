#!/bin/bash

multipass delete --purge k3s-master k3s-worker1 k3s-worker2 2>/dev/null

multipass launch --name k3s-master --cpus 2 --memory 2G --disk 5G
multipass launch --name k3s-worker1 --cpus 2 --memory 4G --disk 30G
multipass launch --name k3s-worker2 --cpus 2 --memory 4G --disk 30G

multipass exec k3s-master -- sudo apt update
multipass exec k3s-master -- sudo apt upgrade
multipass exec k3s-master -- sudo apt install -y curl wget

multipass exec k3s-master -- bash -c "curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION='v1.33.1+k3s1' INSTALL_K3S_EXEC='--disable=traefik' sh -s - --node-taint CriticalAddonsOnly=true:NoExecute"

multipass exec k3s-worker1 -- sudo apt update
multipass exec k3s-worker1 -- sudo apt install -y curl wget

multipass exec k3s-worker2 -- sudo apt update
multipass exec k3s-worker2 -- sudo apt install -y curl wget

sleep 30

K3S_TOKEN=$(multipass exec k3s-master -- sudo cat /var/lib/rancher/k3s/server/node-token)
K3S_URL=$(multipass info k3s-master | grep IPv4 | awk '{print $2}')

multipass exec k3s-worker1 -- bash -c "curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION='v1.33.1+k3s1' K3S_URL=https://$K3S_URL:6443 K3S_TOKEN=$K3S_TOKEN sh -"
multipass exec k3s-worker2 -- bash -c "curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION='v1.33.1+k3s1' K3S_URL=https://$K3S_URL:6443 K3S_TOKEN=$K3S_TOKEN sh -"

mkdir -p ~/.kube
multipass exec k3s-master -- sudo cat /etc/rancher/k3s/k3s.yaml > ~/.kube/k3s-config
sed -i.bak "s/127.0.0.1/$K3S_URL/g" ~/.kube/k3s-config

export KUBECONFIG=~/.kube/k3s-config
#   kubectl taint nodes k3s-master node-role.kubernetes.io/control-plane:NoSchedule
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml
kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=300s

K3S_LB_IP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

while [ -z "$K3S_LB_IP" ]; do
    echo "Waiting for LoadBalancer IP..."
    K3S_LB_IP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    sleep 5
done

echo "k3s Kubernetes cluster created successfully"
echo "Master IP: $K3S_URL"
echo "LoadBalancer IP: $K3S_LB_IP"
echo ""
echo "Add to /etc/hosts:"
echo "$K3S_LB_IP k3s.local"
echo ""
echo "command:"
echo "sudo sh -c 'echo \"$K3S_LB_IP k3s.local\" >> /etc/hosts && echo \"$K3S_LB_IP k3s.local\" >> /etc/hosts'"