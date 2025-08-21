#!/bin/bash

multipass delete --purge k3s-master k3s-worker1 k3s-worker2 2>/dev/null

rm -f ~/.kube/k3s-config ~/.kube/k3s-config.bak 2>/dev/null

echo "Infra - multipass Ubuntu VMs destroyed successfully"
