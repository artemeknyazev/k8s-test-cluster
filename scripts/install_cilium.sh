#!/bin/bash
set -euxo pipefail

# https://docs.cilium.io/en/stable/installation/k8s-install-helm/#installation-using-helm
# https://docs.cilium.io/en/stable/observability/hubble/setup/#enable-hubble-in-cilium
helm upgrade --install cilium cilium \
	--repo https://helm.cilium.io/ \
	--version $CILIUM_VERSION \
	--namespace kube-system \
	--set hubble.relay.enabled=true \
	--set hubble.ui.enabled=true

# https://docs.cilium.io/en/stable/installation/k8s-install-helm/#restart-unmanaged-pods
kubectl get pods --all-namespaces -o custom-columns=NAMESPACE:.metadata.namespace,NAME:.metadata.name,HOSTNETWORK:.spec.hostNetwork --no-headers=true | \
	grep '<none>' | \
	awk '{print "-n "$1" "$2}' | \
	xargs -L 1 -r kubectl delete pod

# https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/#install-the-cilium-cli
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${ARCH}.tar.gz{,.sha256sum}

# https://docs.cilium.io/en/stable/observability/hubble/setup/#install-the-hubble-client
curl -L --fail --remote-name-all https://github.com/cilium/hubble/releases/download/$HUBBLE_VERSION/hubble-linux-${ARCH}.tar.gz{,.sha256sum}
sha256sum --check hubble-linux-${ARCH}.tar.gz.sha256sum
sudo tar xzvfC hubble-linux-${ARCH}.tar.gz /usr/local/bin
rm hubble-linux-${ARCH}.tar.gz{,.sha256sum}

# Do this after:
# - https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/#validate-the-installation
# - https://docs.cilium.io/en/stable/observability/hubble/setup/#validate-hubble-api-access

