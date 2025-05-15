#!/bin/bash
set -euxo pipefail

# https://docs.tigera.io/calico/latest/operations/calicoctl/install#install-calicoctl-as-a-binary-on-a-single-host
mkdir -p /home/vagrant/.local/bin
curl -L https://github.com/projectcalico/calico/releases/download/$CALICO_VERSION/calicoctl-linux-$ARCH -o /home/vagrant/.local/bin/calicoctl
chmod +x /home/vagrant/.local/bin/calicoctl

echo "export KUBECONFIG=/home/vagrant/.kube/config" >> .bashrc
echo "export DATASTORE_TYPE=kubernetes" >> .bashrc

