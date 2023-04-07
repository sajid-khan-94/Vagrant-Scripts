#!/bin/bash

echo "Disabling Firewall"
systemctl disable firewalld; systemctl stop firewalld

echo "Disabling Swap Space"
swapoff -a; sed -i '/swap/d' /etc/fstab

echo "Enabling bridge n/w for kubernetes"
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

echo "Install bare minimum required packages"
yum install wget tmux vim unzip -y

echo "Install Docker Engine"
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce-19.*
systemctl enable --now docker


"Adding kubernetes repo"
cat >>/etc/yum.repos.d/kubernetes.repo<<EOF
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

echo "Setup Done"
