#!/bin/sh

# Pre-requisites on all kubernetes nodes (masters & workers)
echo -e "Configuration for Kubernetes service on master and worker nodes\n"

echo "Disable Swap"
swapoff -a; sed -i '/swap/d' /etc/fstab

echo "Disable Selinux"
setenforce 0; 
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config


echo "Enable and Load overlay Kernel modules"
{
cat >> /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter
}

echo "Add kernal settings"
{
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system
}
echo "Installing Containerd CRI"
{
  dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
  dnf install -y containerd 
  mkdir /etc/containerd
  containerd config default > /etc/containerd/config.toml
  systemctl restart containerd
  systemctl enable containerd
}
echo "Adding yum repo of Kubernetes"
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

echo "Installing Kuberenetes components"
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable --now kubelet
