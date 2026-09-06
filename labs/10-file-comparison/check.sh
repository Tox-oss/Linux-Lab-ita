#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
BASE=${LAB_TRAINING_ROOT:-/workspace/training}/diff-lab

printf 'check 10-file-comparison\n'

for f in config.diff report_check.txt only_prod.txt release_diff.txt; do
  warn_misplaced "/workspace/$f" "$BASE/$f"
  warn_misplaced "${LAB_TRAINING_ROOT:-/workspace/training}/$f" "$BASE/$f"
done

if [ -s "$BASE/config.diff" ] \
   && grep -qx -- '-port=8080' "$BASE/config.diff" \
   && grep -qx -- '+port=8443' "$BASE/config.diff"; then
  pass "config.diff cattura la modifica (port 8080 -> 8443)"
else
  miss "config.diff assente o non riflette la modifica" "punto 1: diff -u config.old.conf config.new.conf > config.diff" "cat config.diff"
fi

rc=""
if [ -f "$BASE/report_check.txt" ]; then
  rc=$(tr -d '[:space:]' < "$BASE/report_check.txt" | tr '[:upper:]' '[:lower:]')
fi
if cmp -s "$BASE/report_a.txt" "$BASE/report_b.txt" && [ "$rc" = "identici" ]; then
  pass "report_check.txt = identici (confermato con cmp)"
else
  miss "report_check.txt errato o assente" "punto 2: cmp -s report_a.txt report_b.txt && echo identici > report_check.txt" "cmp report_a.txt report_b.txt"
fi

expected_prod=$(printf 'host-a\nhost-d')
got_prod=""
if [ -f "$BASE/only_prod.txt" ]; then
  got_prod=$(tr -d '\r' < "$BASE/only_prod.txt" | awk '{$1=$1; print}' | grep -v '^$' || echo "")
fi
if [ "$got_prod" = "$expected_prod" ]; then
  pass "only_prod.txt = host-a, host-d (comm -23)"
else
  miss "only_prod.txt errato o assente" "punto 3: comm -23 servers_prod.txt servers_staging.txt > only_prod.txt" "comm -23 servers_prod.txt servers_staging.txt"
fi

if [ -s "$BASE/release_diff.txt" ] && grep -q 'app.conf' "$BASE/release_diff.txt"; then
  pass "release_diff.txt individua app.conf come file cambiato"
else
  miss "release_diff.txt assente o non cita app.conf" "punto 4: diff -r release_v1 release_v2 > release_diff.txt" "cat release_diff.txt"
fi

if [ ! -e "$BASE/deprecated.old" ]; then
  pass "deprecated.old eliminato"
else
  miss "deprecated.old ancora presente" "punto 5: rm deprecated.old" "ls deprecated.old"
fi

[ "$fail" -eq 0 ]
