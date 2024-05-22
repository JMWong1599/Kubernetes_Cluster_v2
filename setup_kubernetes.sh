#!/bin/bash

# Install dependencies
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Install container runtime (containerd)
echo "Installing containerd..."
sudo apt-get update && sudo apt-get install -y containerd
echo "Containerd installed successfully."

# Configure containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

# Restart containerd
sudo systemctl restart containerd

# Add Kubernetes apt repository and key
echo "Adding Kubernetes apt repository and key..."
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Install Kubernetes components
echo "Installing Kubernetes components..."
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
echo "Kubernetes components installed successfully."

# Hold kubelet, kubeadm, kubectl to prevent automatic updates
sudo apt-mark hold kubelet kubeadm kubectl

# Configure sysctl settings required by Kubernetes
echo "Configuring sysctl settings..."
echo "net.bridge.bridge-nf-call-iptables=1" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Initialize Kubernetes cluster using kubeadm
echo "Initializing Kubernetes cluster..."
sudo kubeadm init --kubernetes-version=1.29.0
echo "Kubernetes cluster initialized successfully."

# Set up kubeconfig for the current user
echo "Setting up kubeconfig..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install Pod network addon (example: Calico)
echo "Installing Pod network addon (Calico)..."
kubectl apply -f https://docs.projectcalico.org/v3.18/manifests/calico.yaml
echo "Pod network addon (Calico) installed successfully."
