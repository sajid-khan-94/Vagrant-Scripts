#!/bin/bash

echo "updating DNS entries"
sed -i -e 's/#DNS=/DNS=8.8.8.8/' /etc/systemd/resolved.conf
service systemd-resolved restart

echo "Enabling ssh password authentication"
sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
systemctl reload sshd

echo "Setting up root password"
echo -e "12345\n12345" | passwd root >/dev/null 2>&1
echo "export TERM=xterm" >> /etc/bash.bashrc

echo "Filling repo data"
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

echo "Updating /etc/hosts file"
cat >>/etc/hosts<<EOF
192.168.5.11   kmaster1.example.com     kmaster1
192.168.5.12   kmaster2.example.com     kmaster2
192.168.5.13   kmaster3.example.com     kmaster3
192.168.5.21   kworker1.example.com     kworker1
192.168.5.31   loadbalancer1.example.com        loadbalancer1
192.168.5.32   loadbalancer2.example.com        loadbalancer2

