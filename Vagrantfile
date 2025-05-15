NUM_WORKERS=1

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-24.04"
  config.vm.box_version = "202502.21.0"
  config.vm.box_check_update = true

  config.vm.provider "virtualbox" do |v|
    v.linked_clone = true
  end

  config.vm.provision :shell, name: "fix_hosts",
    path: "scripts/fix_hosts.sh"

  config.vm.provision :shell, name: "install_common",
    path: "scripts/install_common.sh"

  config.vm.provision :shell, name: "init_common",
    path: "scripts/init_common.sh"

  config.vm.provision :shell, name: "install_kubernetes",
    env: { "KUBERNETES_VERSION": "v1.33" },
    path: "scripts/install_kubernetes.sh"

  config.vm.provision :shell, name: "install_crio",
    env: { "CRIO_VERSION": "v1.32" },
    path: "scripts/install_crio.sh"

  # worker plane
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

  # control plane
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

    control.vm.provision :file, source: ".ssh/id_ed25519", destination: "/home/vagrant/.ssh"
    control.vm.provision :file, source: ".ssh/id_ed25519.pub", destination: "/home/vagrant/.ssh"

    control.vm.provision :shell, name: "init_kubeadm",
      env: {
        "CONTROL_IP": "192.168.0.101",
        "POD_CIDR": "172.16.1.0/16",
        "SERVICE_CIDR": "172.17.1.0/18",
        "NODE_NAME": "control1"
      },
      path: "scripts/init_kubeadm.sh"

    control.vm.provision :shell, name: "export_join_cluster_script",
      inline: "kubeadm token create --print-join-command > /vagrant/join-cluster.sh"

    control

    control.vm.provision :shell, name: "init_kubectl",
      privileged: false,
      path: "scripts/init_kubectl.sh"

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
      run: "never",
      env: { "INGRESS_NGINX_VERSION": "4.12.2" },
      privileged: false,
      path: "scripts/install_ingress_nginx.sh"

    control.vm.provision :shell, name: "install_metrics_server",
      run: "never",
      env: { "METRICS_SERVER_VERSION": "3.12.2" },
      privileged: false,
      path: "scripts/install_metrics_server.sh"
  end
end

