#!/usr/bin/env bash
set -euo pipefail
cd ${LAB_TRAINING_ROOT:-/workspace/training}/${V_DIR:-net-lab}

ip -o -4 addr show lo | awk '{ print $4 }' > ${V_OUT_CIDR:-loopback_cidr.txt}
ss -ltn | grep ":${V_PORT:-8088}" > ${V_OUT_LIS:-listening_8088.txt}
ping -c 1 127.0.0.1 > ${V_OUT_PING:-ping_localhost.txt}
curl -s "file://$PWD/${V_REMOTE:-remote}/${V_JSON:-status.json}" > ${V_OUT_FETCH:-fetched_status.json}
ssh -V > ${V_OUT_SSH:-ssh_version.txt} 2>&1
mkdir -p ${V_COPIES:-copies}
scp ${V_REMOTE:-remote}/${V_JSON:-status.json} ${V_COPIES:-copies}/${V_SCP:-status.scp.json}
rsync -a ${V_REMOTE:-remote}/ ${V_MIRROR:-mirror}/

lab check 09-network-transfer
