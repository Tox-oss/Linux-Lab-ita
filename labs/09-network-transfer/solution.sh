#!/usr/bin/env bash
set -euo pipefail
cd ${LAB_TRAINING_ROOT:-/workspace/training}/net-lab

ip -o -4 addr show lo | awk '{ print $4 }' > loopback_cidr.txt
ss -ltn | grep ':8088' > listening_8088.txt
ping -c 1 127.0.0.1 > ping_localhost.txt
curl -s "file://$PWD/remote/status.json" > fetched_status.json
ssh -V > ssh_version.txt 2>&1
mkdir -p copies
scp remote/status.json copies/status.scp.json
rsync -a remote/ mirror/

lab check 09-network-transfer
