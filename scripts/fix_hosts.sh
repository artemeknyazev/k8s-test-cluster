#!/bin/bash
set -euxo pipefail

for i in `seq 1 9`; do
	echo 192.168.0.10${i} control${i} | sudo tee -a /etc/hosts
done
for i in `seq 1 9`; do
	echo 192.168.0.20${i} worker${i} | sudo tee -a /etc/hosts
done

