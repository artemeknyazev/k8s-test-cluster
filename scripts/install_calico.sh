#!/bin/bash
set -euxo pipefail

# https://docs.tigera.io/calico/latest/getting-started/kubernetes/helm#how-to
helm repo add projectcalico https://docs.tigera.io/calico/charts
helm install calico projectcalico/tigera-operator \
	--version $CALICO_VERSION \
	--namespace tigera-operator \
	--create-namespace

# https://docs.tigera.io/calico/latest/operations/calicoctl/install#install-calicoctl-as-a-binary-on-a-single-host
mkdir -p /home/vagrant/.local/bin
curl -L https://github.com/projectcalico/calico/releases/download/$CALICO_VERSION/calicoctl-linux-$ARCH -o /home/vagrant/.local/bin/calicoctl
chmod +x /home/vagrant/.local/bin/calicoctl

echo "export KUBECONFIG=/home/vagrant/.kube/config" >> .bashrc
echo "export DATASTORE_TYPE=kubernetes" >> .bashrc

