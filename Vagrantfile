NUM_CONTROL=1
NUM_WORKERS=2

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-24.04"
  config.vm.box_version = "202502.21.0"
  config.vm.box_check_update = true

  config.vm.provider "virtualbox" do |v|
    v.linked_clone = true
  end

  # Common
  config.vm.provision :shell, name: "fix_hosts",
    env: { 
      "NUM_CONTROL": NUM_CONTROL,
      "NUM_WORKERS": NUM_WORKERS
    },
    inline: <<-SCRIPT
      for i in `seq 1 $NUM_CONTROL`; do
        echo 192.168.0.10${i} control${i} | sudo tee -a /etc/hosts
      done
      for i in `seq 1 $NUM_WORKERS`; do
        echo 192.168.0.20${i} worker${i} | sudo tee -a /etc/hosts
      done
    SCRIPT

  config.vm.provision :shell, name: "install_common",
    inline: <<-SCRIPT
      sudo apt-get update -y
      sudo apt-get install -y \
        software-properties-common \
        curl \
        bash-completion
    SCRIPT

  config.vm.provision :shell, name: "init_common",
    path: "scripts/init_common.sh"

  config.vm.provision :shell, name: "install_kubernetes",
    env: { "KUBERNETES_VERSION": "v1.33" },
    path: "scripts/install_kubernetes.sh"

  config.vm.provision :shell, name: "install_crio",
    env: { "CRIO_VERSION": "v1.32" },
    path: "scripts/install_crio.sh"

  # Worker plane
  (1..NUM_WORKERS).each do |i|
    name = 'worker' + i.to_s
    ip = '192.168.0.' + (200+i).to_s

    config.vm.define name do |worker|
      worker.vm.hostname = name
      worker.vm.network :private_network,
        ip: ip,
        virtualbox__intnet: "k8s-security"

      worker.vm.provider "virtualbox" do |v|
        v.name = 'k8s-security-' + name
        v.cpus = 2
        v.memory = 4096
        v.linked_clone = true
      end

      worker.vm.provision :file, source: ".ssh/id_ed25519.pub", destination: "/home/vagrant/"

      worker.vm.provision :shell, name: "enable_control_to_worker_ssh",
        privileged: false,
        inline: "cat /home/vagrant/id_ed25519.pub >> /home/vagrant/.ssh/authorized_keys"
    end
  end

  # Control plane
  config.vm.define "control1", primary: true do |control|
    control.vm.hostname = "control1"
    control.vm.network :private_network,
      ip: "192.168.0.101",
      virtualbox__intnet: "k8s-security"

    control.vm.provider "virtualbox" do |v|
      v.name = 'k8s-security-control1'
      v.cpus = 2
      v.memory = 4096
      v.linked_clone = true
    end

    control.vm.provision :file, source: ".ssh/id_ed25519", destination: "/home/vagrant/.ssh/"
    control.vm.provision :file, source: ".ssh/id_ed25519.pub", destination: "/home/vagrant/.ssh/"

    control.vm.provision :shell, name: "init_kubeadm",
      env: {
        "CONTROL_IP": "192.168.0.101",
        "POD_CIDR": "172.16.1.0/16",
        "SERVICE_CIDR": "172.17.1.0/18",
        "NODE_NAME": "control1"
      },
      inline: <<-SCRIPT
        sudo kubeadm init \
          --apiserver-advertise-address=$CONTROL_IP \
          --apiserver-cert-extra-sans=$CONTROL_IP \
          --pod-network-cidr=$POD_CIDR \
          --service-cidr=$SERVICE_CIDR \
          --node-name "$NODE_NAME" \
          --ignore-preflight-errors Swap
      SCRIPT

    control.vm.provision :shell, name: "init_kubectl",
      privileged: false,
      inline: <<-SCRIPT
        mkdir -p /home/vagrant/.kube
        sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
        sudo chown 1000:1000 /home/vagrant/.kube/config
      SCRIPT

    control.vm.provision :shell, name: "join_workers", 
      env: { "NUM_WORKERS": NUM_WORKERS },
      privileged: false,
      inline: <<-SCRIPT
        JOIN_COMMAND=$(kubeadm token create --print-join-command)
        for i in `seq 1 $NUM_WORKERS`; do
          ssh -o "StrictHostKeyChecking no" worker${i} sudo $JOIN_COMMAND
        done
      SCRIPT

    control.vm.provision :shell, name: "install_helm",
      privileged: false,
      path: "scripts/install_helm.sh"

    control.vm.provision :shell, name: "install_cilium",
      env: {
        "CILIUM_CLI_VERSION": "v0.18.3",
        "CILIUM_VERSION": "v1.17.3",
        "HUBBLE_VERSION": "v1.17.3",
        "ARCH": "arm64"
      },
      privileged: false,
      path: "scripts/install_cilium.sh"

    control.vm.provision :shell, name: "install_calico",
      run: "never",
      env: {
        "CALICO_VERSION": "v3.30.0",
        "ARCH": "arm64"
      },
      privileged: false,
      path: "scripts/install_calico.sh"

    control.vm.provision :shell, name: "install_ingress_nginx",
      env: { "INGRESS_NGINX_VERSION": "4.12.2" },
      privileged: false,
      inline: <<-SCRIPT
        helm upgrade --install ingress-nginx ingress-nginx \
          --repo https://kubernetes.github.io/ingress-nginx \
          --version $INGRESS_NGINX_VERSION \
          --namespace ingress-nginx \
          --create-namespace
      SCRIPT

    # TODO: find how to sign a cert to remove --kubelet-insecure-tls option
    control.vm.provision :shell, name: "install_metrics_server",
      env: { "METRICS_SERVER_VERSION": "3.12.2" },
      privileged: false,
      inline: <<-SCRIPT
        helm upgrade --install metrics-server metrics-server \
          --repo https://kubernetes-sigs.github.io/metrics-server/ \
          --version $METRICS_SERVER_VERSION \
          --namespace kube-system \
          --set args[0]=--kubelet-insecure-tls
      SCRIPT
  end
end

