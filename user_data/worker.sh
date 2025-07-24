#!/bin/bash

sudo swapoff -a

# Load necessary kernel modules
modprobe overlay
modprobe br_netfilter

# Ensure kernel modules are loaded at boot
cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

cat <<EOF | tee /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# Install required packages for Docker repo setup
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gpg awscli

# Add Docker GPG key
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
| tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update and install containerd
apt-get update
apt-get install -y containerd.io

# Generate default containerd config
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml

# Enable SystemdCgroup
sed -i 's/^\(\s*SystemdCgroup\s*=\s*\)false/\1true/' /etc/containerd/config.toml

# Restart containerd to apply changes
systemctl restart containerd

# Restart containerd to apply changes
systemctl enable containerd

# 8. Add Kubernetes GPG key and repo for v1.30
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | gpg --dearmor -o /usr/share/keyrings/kubernetes-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" \
| tee /etc/apt/sources.list.d/kubernetes.list > /dev/null

apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

# Initialize Kubernetes cluster
kubeadm init \
  --pod-network-cidr=192.168.0.0/16 \
  --cri-socket=/var/run/containerd/containerd.sock \
  --ignore-preflight-errors=Mem,FileContent--proc-sys-net-ipv4-ip_forward \
  --v=5

# Set up kubectl for the ubuntu user
mkdir -p /home/ubuntu/.kube
cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
chown ubuntu:ubuntu /home/ubuntu/.kube/config