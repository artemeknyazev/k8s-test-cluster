# k8s-cluster

Kubernetes cluster built atop of Vagrant and VirtualBox for local development and education purpose.

## Requirements

- Vagrant
- VirtualBox

## How To

**NOTE:** Tested only on MacBook M1.

- Run using `make init`
- Remove using `make destroy`

## What's Inside

- Kubernetes w/ CRI-O CRI and Cilium (w/ Hubble) CNI
- Ingress Nginx
- Metrics Server

## Caveats

- Control node joins workers automatically by executing `kubeadm join` remotely using ssh.
    - To do this, a key pair is generated on the host, added to the control node, and public key is added to allowed keys on all workers.
    - `.ssh-key` `Makefile` step generates key pair, then `Vagrantfile` provisions keys to control and workers and adds them to allowed keys on workers, allowing to establish control-to-worker ssh connection.
    - During the first connection workers are added to known hosts. `-o "StrictHostKeyChecking no"` option is used for automation purposes in a local insecure environment. Don't do this in production.
- Metrics Server skips TLS checks.
    - `--kubelet-insecure-tls` option is used to skip generating certificates to simplify setup. Don't do this in production.

## Acknowledgements

- [CKA](https://github.com/sandervanvugt/cka), [CKAD](https://github.com/sandervanvugt/ckad) by Sander van Vugt
- [CKS](https://github.com/chrijack/CKS) by Chris Jackson

