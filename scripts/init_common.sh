#!/bin/bash
set -euxo pipefail

# Load modules at boot
cat <<EOF | sudo tee /etc/modules-load.d/crio.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Set up networking params
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system

# Turn swap off and keep it off after reboot
swapoff -a
(crontab -l 2>/dev/null; echo "@reboot /sbin/swapoff -a") | crontab - || true

