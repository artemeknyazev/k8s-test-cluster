#!/bin/bash
set -euxo pipefail

curl -fsSL -o /home/vagrant/get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 /home/vagrant/get_helm.sh
/home/vagrant/get_helm.sh

helm completion bash | sudo tee /etc/bash_completion.d/helm > /dev/null
sudo chmod a+r /etc/bash_completion.d/helm

