# k8s-cluster

Kubernetes cluster built atop of Vagrant and VirtualBox for local development and education purpose.

## Requirements

- Vagrant
- VirtualBox

## How To

**NOTE:** Tested only on MacBook M1.

- run using `make init`
- remove using `make destroy`

## What's Inside

- Kubernetes w/ CRI-O CRI and Cilium (w/ Hubble) CNI
- Ingress Nginx
- Metrics Server

## Acknowledgements

- [CKA](https://github.com/sandervanvugt/cka), [CKAD](https://github.com/sandervanvugt/ckad) by Sander van Vugt
- [CKS](https://github.com/chrijack/CKS) by Chris Jackson

