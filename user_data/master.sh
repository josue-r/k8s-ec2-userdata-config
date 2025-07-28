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
apt-get update -y
apt-get install -y apt-transport-https ca-certificates curl gpg

# Install AWS CLI v2
if ! command -v aws &> /dev/null; then
  apt-get update
  apt-get install -y unzip curl

  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  ./aws/install
  rm -rf awscliv2.zip aws
fi

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

# Apply Calico CNI plugin (run as ubuntu user)
echo "Applying Calico tigera-operator.yaml..."
time su - ubuntu -c "kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.30.0/manifests/tigera-operator.yaml"

# Wait for the CRDs to be installed (check for the Installation CRD)
echo "Waiting for Calico CRDs to be available..."
start=$(date +%s)
until su - ubuntu -c "kubectl get crd installations.operator.tigera.io" >/dev/null 2>&1; do
  sleep 5
done
end=$(date +%s)
echo "CRDs available after $((end - start)) seconds"

# Apply Calico custom resources
echo "Applying Calico custom-resources.yaml..."
time su - ubuntu -c "kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.30.0/manifests/custom-resources.yaml"
# Generate token and write to S3
JOIN_COMMAND=$(kubeadm token create --print-join-command)

echo "##########
##########
$JOIN_COMMAND
#############
#############"

echo "$JOIN_COMMAND" > /tmp/join.sh
aws s3 cp --region us-east-1 /tmp/join.sh s3://k8s-bootstrap-artifacts/join-command.txt
rm /tmp/join.sh
