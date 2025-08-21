#!/bin/bash

VM_NAME="k3s-master"

if multipass list | awk 'NR>1 {print $1}' | grep -qw "$VM_NAME"; then
    echo "VM '$VM_NAME' exists."
else
    echo "VM '$VM_NAME' does not exist. Creating..."
    bash $PWD/infra-provisioning/infra_provision_vms.sh
fi

VM_NAME="k3s-worker1"

if multipass list | awk 'NR>1 {print $1}' | grep -qw "$VM_NAME"; then
    echo "VM '$VM_NAME' exists."
else
    echo "VM '$VM_NAME' does not exist. Creating..."
    bash $PWD/infra-provisioning/infra_provision_vms.sh
fi

VM_NAME="k3s-worker2"

if multipass list | awk 'NR>1 {print $1}' | grep -qw "$VM_NAME"; then
    echo "VM '$VM_NAME' exists."
else
    echo "VM '$VM_NAME' does not exist. Creating..."
    bash $PWD/infra-provisioning/infra_provision_vms.sh
fi

multipass exec k3s-master -- bash -c "curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION='v1.33.1+k3s1' INSTALL_K3S_EXEC='--disable=traefik' sh -s - --node-taint CriticalAddonsOnly=true:NoExecute"

sleep 30

K3S_TOKEN=$(multipass exec k3s-master -- sudo cat /var/lib/rancher/k3s/server/node-token)
K3S_URL=$(multipass info k3s-master | grep IPv4 | awk '{print $2}')

multipass exec k3s-worker1 -- bash -c "curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION='v1.33.1+k3s1' K3S_URL=https://$K3S_URL:6443 K3S_TOKEN=$K3S_TOKEN sh -"
multipass exec k3s-worker2 -- bash -c "curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION='v1.33.1+k3s1' K3S_URL=https://$K3S_URL:6443 K3S_TOKEN=$K3S_TOKEN sh -"

mkdir -p ~/.kube
multipass exec k3s-master -- sudo cat /etc/rancher/k3s/k3s.yaml > ~/.kube/k3s-config
sed -i.bak "s/127.0.0.1/$K3S_URL/g" ~/.kube/k3s-config

echo "K3S cluster configuration completed."
echo "You can now use kubectl with the K3S cluster."
echo "To use kubectl, run the following commands:"
echo "cat ~/.kube/k3s-config"
echo "export KUBECONFIG=~/.kube/k3s-config"

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
echo "k3s nodes:"

kubectl get node -o wide
HOSTNAME="k3s-demo-app.local"

echo "k3s Master Node IP: $K3S_URL"
echo "k3s LoadBalancer IP: $K3S_LB_IP"
echo ""
echo "Add to /etc/hosts:"
echo "$K3S_LB_IP $HOSTNAME"
echo ""
echo "command:"
echo "sudo sh -c 'echo \"$K3S_LB_IP $HOSTNAME\" >> /etc/hosts'"

bash $PWD/k3s-cluster-setup/k3s_update_lb_ip_in_localdns.sh


# Check if the entry already exists
if grep -q "$HOSTNAME" /etc/hosts; then
    echo "[+] Updating existing entry for $HOSTNAME"
    sudo sed -i '' "s/^.*$HOSTNAME\$/$K3S_LB_IP $HOSTNAME/" /etc/hosts
else
    echo "[+] Adding new entry: $K3S_LB_IP $HOSTNAME"
    echo "$K3S_LB_IP $HOSTNAME" | sudo tee -a /etc/hosts > /dev/null
fi

echo "[✓] /etc/hosts updated."
