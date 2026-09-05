#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
BASE=${LAB_TRAINING_ROOT:-/workspace/training}/text-lab

printf 'check 05-text-processing\n'

# 0. Controllo e ripristino percorsi errati comuni
warn_misplaced "/workspace/error_count.txt" "$BASE/error_count.txt"
warn_misplaced "${LAB_TRAINING_ROOT:-/workspace/training}/error_count.txt" "$BASE/error_count.txt"
warn_misplaced "/workspace/failing_ips.txt" "$BASE/failing_ips.txt"
warn_misplaced "${LAB_TRAINING_ROOT:-/workspace/training}/failing_ips.txt" "$BASE/failing_ips.txt"
warn_misplaced "/workspace/api_total.txt" "$BASE/api_total.txt"
warn_misplaced "${LAB_TRAINING_ROOT:-/workspace/training}/api_total.txt" "$BASE/api_total.txt"
warn_misplaced "/workspace/summary.txt" "$BASE/summary.txt"
warn_misplaced "${LAB_TRAINING_ROOT:-/workspace/training}/summary.txt" "$BASE/summary.txt"

# 1. File error_count.txt
if [ -f "$BASE/error_count.txt" ] && [ "$(tr -d '[:space:]' < "$BASE/error_count.txt")" = "4" ]; then
  pass "error_count.txt = 4"
else
  got="assente"
  [ -f "$BASE/error_count.txt" ] && got=$(tr -d '[:space:]' < "$BASE/error_count.txt")
  miss "error_count.txt errato (ora: $got)" "punto 1: grep ERROR access.log | wc -l > error_count.txt" "cat error_count.txt"
fi

# 2. File failing_ips.txt
expected_ips=$(printf '10.0.0.2\n10.0.0.7')
got_ips=""
if [ -f "$BASE/failing_ips.txt" ]; then
  got_ips=$(tr -d '\r' < "$BASE/failing_ips.txt" | awk '{$1=$1; print}' | grep -v '^$' || echo "")
fi

if [ -f "$BASE/failing_ips.txt" ] && [ "$got_ips" = "$expected_ips" ]; then
  pass "failing_ips.txt ordinato e unico"
else
  miss "failing_ips.txt errato o assente" "punto 2: awk '\$4 == 500 {print \$1}' access.log | sort -u > failing_ips.txt" "cat failing_ips.txt"
fi

# 3. File api_total.txt
if [ -f "$BASE/api_total.txt" ] && [ "$(tr -d '[:space:]' < "$BASE/api_total.txt")" = "340" ]; then
  pass "api_total.txt = 340"
else
  got="assente"
  [ -f "$BASE/api_total.txt" ] && got=$(tr -d '[:space:]' < "$BASE/api_total.txt")
  miss "api_total.txt errato (ora: $got)" "punto 3: somma requests dove service=api (awk -F, 'NR > 1 && \$1 == \"api\" { total += \$3 } END { print total }')" "cat api_total.txt"
fi

# 4. File summary.txt
got_summary=""
if [ -f "$BASE/summary.txt" ]; then
  got_summary=$(head -n 1 "$BASE/summary.txt" | tr -d '\r' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
fi

if [ -f "$BASE/summary.txt" ] && [ "$got_summary" = "log analysis complete" ]; then
  pass "summary.txt riga 1 ok"
else
  miss "summary.txt prima riga errata" "punto 4: prima riga = log analysis complete (ok printf, echo o nano)" "head -n 1 summary.txt"
fi

[ "$fail" -eq 0 ]
