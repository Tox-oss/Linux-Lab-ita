#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
BASE=${LAB_TRAINING_ROOT:-/workspace/training}/${V_DIR:-net-lab}

printf 'check 09-network-transfer\n'

for f in ${V_OUT_CIDR:-loopback_cidr.txt} ${V_OUT_LIS:-listening_8088.txt} ${V_OUT_PING:-ping_localhost.txt} ${V_OUT_FETCH:-fetched_status.json} ${V_OUT_SSH:-ssh_version.txt}; do
  warn_misplaced "/workspace/$f" "$BASE/$f"
  warn_misplaced "${LAB_TRAINING_ROOT:-/workspace/training}/$f" "$BASE/$f"
done
warn_misplaced "/workspace/${V_COPIES:-copies}" "$BASE/${V_COPIES:-copies}"
warn_misplaced "${LAB_TRAINING_ROOT:-/workspace/training}/${V_COPIES:-copies}" "$BASE/${V_COPIES:-copies}"
warn_misplaced "/workspace/${V_MIRROR:-mirror}" "$BASE/${V_MIRROR:-mirror}"
warn_misplaced "${LAB_TRAINING_ROOT:-/workspace/training}/${V_MIRROR:-mirror}" "$BASE/${V_MIRROR:-mirror}"

if [ -f "$BASE/${V_OUT_CIDR:-loopback_cidr.txt}" ] && [ "$(tr -d '[:space:]' < "$BASE/${V_OUT_CIDR:-loopback_cidr.txt}")" = "127.0.0.1/8" ]; then
  pass "${V_OUT_CIDR:-loopback_cidr.txt} = 127.0.0.1/8"
else
  miss "${V_OUT_CIDR:-loopback_cidr.txt} errato o assente" "punto 1: ip -o -4 addr show lo | awk '{ print \$4 }' > ${V_OUT_CIDR:-loopback_cidr.txt}" "cat ${V_OUT_CIDR:-loopback_cidr.txt}"
fi

if [ -f "$BASE/${V_OUT_LIS:-listening_8088.txt}" ] && grep -q ":${V_PORT:-8088}" "$BASE/${V_OUT_LIS:-listening_8088.txt}" && ss -ltn | grep -q ":${V_PORT:-8088}"; then
  pass "${V_OUT_LIS:-listening_8088.txt} mostra la porta ${V_PORT:-8088} in ascolto"
else
  miss "${V_OUT_LIS:-listening_8088.txt} errato o listener non attivo" "punto 2: ss -ltn | grep \":${V_PORT:-8088}\" > ${V_OUT_LIS:-listening_8088.txt}; se il listener manca, rilancia lab start 09-network-transfer" "ss -ltn | grep \":${V_PORT:-8088}\""
fi

if [ -f "$BASE/${V_OUT_PING:-ping_localhost.txt}" ] && grep -Eq '0% packet loss|1 received' "$BASE/${V_OUT_PING:-ping_localhost.txt}"; then
  pass "${V_OUT_PING:-ping_localhost.txt} mostra ping riuscito"
else
  miss "${V_OUT_PING:-ping_localhost.txt} errato o assente" "punto 3: ping -c 1 127.0.0.1 > ${V_OUT_PING:-ping_localhost.txt}" "cat ${V_OUT_PING:-ping_localhost.txt}"
fi

if [ -f "$BASE/${V_OUT_FETCH:-fetched_status.json}" ] && cmp -s "$BASE/${V_REMOTE:-remote}/${V_JSON:-status.json}" "$BASE/${V_OUT_FETCH:-fetched_status.json}"; then
  pass "${V_OUT_FETCH:-fetched_status.json} identico a ${V_REMOTE:-remote}/${V_JSON:-status.json}"
else
  miss "${V_OUT_FETCH:-fetched_status.json} errato o assente" "punto 4: curl -s \"file://\$PWD/${V_REMOTE:-remote}/${V_JSON:-status.json}\" > ${V_OUT_FETCH:-fetched_status.json}" "cat ${V_OUT_FETCH:-fetched_status.json}"
fi

if [ -f "$BASE/${V_OUT_SSH:-ssh_version.txt}" ] && grep -q '^OpenSSH_' "$BASE/${V_OUT_SSH:-ssh_version.txt}"; then
  pass "${V_OUT_SSH:-ssh_version.txt} contiene versione OpenSSH"
else
  miss "${V_OUT_SSH:-ssh_version.txt} errato o assente" "punto 5: ssh -V > ${V_OUT_SSH:-ssh_version.txt} 2>&1" "cat ${V_OUT_SSH:-ssh_version.txt}"
fi

if [ -f "$BASE/${V_COPIES:-copies}/${V_SCP:-status.scp.json}" ] && cmp -s "$BASE/${V_REMOTE:-remote}/${V_JSON:-status.json}" "$BASE/${V_COPIES:-copies}/${V_SCP:-status.scp.json}"; then
  pass "scp ha copiato ${V_JSON:-status.json}"
else
  miss "copia scp mancante o diversa" "punto 6: mkdir -p ${V_COPIES:-copies}; scp ${V_REMOTE:-remote}/${V_JSON:-status.json} ${V_COPIES:-copies}/${V_SCP:-status.scp.json}" "cmp ${V_REMOTE:-remote}/${V_JSON:-status.json} ${V_COPIES:-copies}/${V_SCP:-status.scp.json}"
fi

if [ -f "$BASE/${V_MIRROR:-mirror}/${V_JSON:-status.json}" ] && [ -f "$BASE/${V_MIRROR:-mirror}/${V_NESTED:-nested}/${V_INFO:-info.txt}" ] && cmp -s "$BASE/${V_REMOTE:-remote}/${V_JSON:-status.json}" "$BASE/${V_MIRROR:-mirror}/${V_JSON:-status.json}"; then
  pass "rsync ha sincronizzato ${V_REMOTE:-remote}/ in ${V_MIRROR:-mirror}/"
else
  miss "${V_MIRROR:-mirror} incompleto o diverso" "punto 7: rsync -a ${V_REMOTE:-remote}/ ${V_MIRROR:-mirror}/" "diff -r ${V_REMOTE:-remote} ${V_MIRROR:-mirror}"
fi

[ "$fail" -eq 0 ]
