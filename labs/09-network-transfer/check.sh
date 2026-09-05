#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
BASE=${LAB_TRAINING_ROOT:-/workspace/training}/net-lab

printf 'check 09-network-transfer\n'

for f in loopback_cidr.txt listening_8088.txt ping_localhost.txt fetched_status.json ssh_version.txt; do
  warn_misplaced "/workspace/$f" "$BASE/$f"
  warn_misplaced "${LAB_TRAINING_ROOT:-/workspace/training}/$f" "$BASE/$f"
done
warn_misplaced "/workspace/copies" "$BASE/copies"
warn_misplaced "${LAB_TRAINING_ROOT:-/workspace/training}/copies" "$BASE/copies"
warn_misplaced "/workspace/mirror" "$BASE/mirror"
warn_misplaced "${LAB_TRAINING_ROOT:-/workspace/training}/mirror" "$BASE/mirror"

if [ -f "$BASE/loopback_cidr.txt" ] && [ "$(tr -d '[:space:]' < "$BASE/loopback_cidr.txt")" = "127.0.0.1/8" ]; then
  pass "loopback_cidr.txt = 127.0.0.1/8"
else
  miss "loopback_cidr.txt errato o assente" "punto 1: ip -o -4 addr show lo | awk '{ print \$4 }' > loopback_cidr.txt" "cat loopback_cidr.txt"
fi

if [ -f "$BASE/listening_8088.txt" ] && grep -q ':8088' "$BASE/listening_8088.txt" && ss -ltn | grep -q ':8088'; then
  pass "listening_8088.txt mostra la porta 8088 in ascolto"
else
  miss "listening_8088.txt errato o listener non attivo" "punto 2: ss -ltn | grep ':8088' > listening_8088.txt; se il listener manca, rilancia lab start 09-network-transfer" "ss -ltn | grep ':8088'"
fi

if [ -f "$BASE/ping_localhost.txt" ] && grep -Eq '0% packet loss|1 received' "$BASE/ping_localhost.txt"; then
  pass "ping_localhost.txt mostra ping riuscito"
else
  miss "ping_localhost.txt errato o assente" "punto 3: ping -c 1 127.0.0.1 > ping_localhost.txt" "cat ping_localhost.txt"
fi

if [ -f "$BASE/fetched_status.json" ] && cmp -s "$BASE/remote/status.json" "$BASE/fetched_status.json"; then
  pass "fetched_status.json identico a remote/status.json"
else
  miss "fetched_status.json errato o assente" "punto 4: curl -s \"file://\$PWD/remote/status.json\" > fetched_status.json" "cat fetched_status.json"
fi

if [ -f "$BASE/ssh_version.txt" ] && grep -q '^OpenSSH_' "$BASE/ssh_version.txt"; then
  pass "ssh_version.txt contiene versione OpenSSH"
else
  miss "ssh_version.txt errato o assente" "punto 5: ssh -V > ssh_version.txt 2>&1" "cat ssh_version.txt"
fi

if [ -f "$BASE/copies/status.scp.json" ] && cmp -s "$BASE/remote/status.json" "$BASE/copies/status.scp.json"; then
  pass "scp ha copiato status.json"
else
  miss "copia scp mancante o diversa" "punto 6: mkdir -p copies; scp remote/status.json copies/status.scp.json" "cmp remote/status.json copies/status.scp.json"
fi

if [ -f "$BASE/mirror/status.json" ] && [ -f "$BASE/mirror/nested/info.txt" ] && cmp -s "$BASE/remote/status.json" "$BASE/mirror/status.json"; then
  pass "rsync ha sincronizzato remote/ in mirror/"
else
  miss "mirror incompleto o diverso" "punto 7: rsync -a remote/ mirror/" "diff -r remote/ mirror"
fi

[ "$fail" -eq 0 ]
