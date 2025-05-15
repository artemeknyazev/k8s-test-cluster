#!/bin/bash
set -euxo pipefail

helm upgrade --install ingress-nginx ingress-nginx \
	--repo https://kubernetes.github.io/ingress-nginx \
	--version $INGRESS_NGINX_VERSION \
	--namespace ingress-nginx \
	--create-namespace

