#!/bin/bash
set -euxo pipefail

sudo apt-get update -y
sudo apt-get install -y \
	software-properties-common \
	curl \
	bash-completion

