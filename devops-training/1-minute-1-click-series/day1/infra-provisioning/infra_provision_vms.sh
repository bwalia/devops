#!/bin/bash

multipass delete --purge k3s-master k3s-worker1 k3s-worker2 2>/dev/null

multipass launch --name k3s-master --cpus 2 --memory 2G --disk 5G
multipass launch --name k3s-worker1 --cpus 2 --memory 4G --disk 30G
multipass launch --name k3s-worker2 --cpus 2 --memory 4G --disk 30G

multipass exec k3s-master -- sudo apt update -y
multipass exec k3s-master -- sudo apt upgrade -y
multipass exec k3s-master -- sudo apt install -y curl wget

multipass exec k3s-worker1 -- sudo apt update -y
multipass exec k3s-worker1 -- sudo apt upgrade -y
multipass exec k3s-worker1 -- sudo apt install -y curl wget

multipass exec k3s-worker2 -- sudo apt update -y
multipass exec k3s-worker2 -- sudo apt upgrade -y
multipass exec k3s-worker2 -- sudo apt install -y curl wget

multipass ls

multipass info k3s-master
multipass info k3s-worker1
multipass info k3s-worker2

echo "Infra - multipass Ubuntu VMs created successfully"

sleep 30
