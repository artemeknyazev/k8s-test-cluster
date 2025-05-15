#!/bin/bash
set -euxo pipefail

# https://github.com/cri-o/packaging/blob/main/README.md#distributions-using-deb-packages
curl -fsSL https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl

# https://kubernetes.io/docs/reference/kubectl/generated/kubectl_completion/
# https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#enable-shell-autocompletion
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
sudo chmod a+r /etc/bash_completion.d/kubectl

kubeadm completion bash | sudo tee /etc/bash_completion.d/kubeadm > /dev/null
sudo chmod a+r /etc/bash_completion.d/kubeadm

echo "alias k=kubectl" >> ~/.bashrc
echo "complete -o default -F __start_kubectl k" >> ~/.bashrc

