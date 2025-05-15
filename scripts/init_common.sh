#!/bin/bash
set -euxo pipefail

# Turn swap off and keep it off after reboot
swapoff -a
(crontab -l 2>/dev/null; echo "@reboot /sbin/swapoff -a") | crontab - || true

