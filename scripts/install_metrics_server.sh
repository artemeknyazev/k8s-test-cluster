#!/bin/bash
set -euxo pipefail

helm upgrade --install metrics-server metrics-server \
	--repo https://kubernetes-sigs.github.io/metrics-server/ \
	--version $METRICS_SERVER_VERSION

