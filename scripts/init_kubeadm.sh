#!/bin/bash
set -euxo pipefail

sudo kubeadm init \
	--apiserver-advertise-address=$CONTROL_IP \
	--apiserver-cert-extra-sans=$CONTROL_IP \
	--pod-network-cidr=$POD_CIDR \
	--service-cidr=$SERVICE_CIDR \
	--node-name "$NODE_NAME" \
	--ignore-preflight-errors Swap

