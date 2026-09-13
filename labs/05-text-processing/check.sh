#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
BASE=${LAB_TRAINING_ROOT:-/workspace/training}/${V_DIR:-text-lab}

printf 'check 05-text-processing\n'

LOG=${V_LOG:-access.log}
CSV=${V_CSV:-services.csv}
OUT1=${V_OUT1:-error_count.txt}
OUT2=${V_OUT2:-failing_ips.txt}
OUT3=${V_OUT3:-api_total.txt}
OUT4=${V_OUT4:-summary.txt}
TXT=${V_TEXT:-log analysis complete}

# 0. Controllo e ripristino percorsi errati comuni
warn_misplaced "/workspace/$OUT1" "$BASE/$OUT1"
warn_misplaced "${LAB_TRAINING_ROOT:-/workspace/training}/$OUT1" "$BASE/$OUT1"
warn_misplaced "/workspace/$OUT2" "$BASE/$OUT2"
warn_misplaced "${LAB_TRAINING_ROOT:-/workspace/training}/$OUT2" "$BASE/$OUT2"
warn_misplaced "/workspace/$OUT3" "$BASE/$OUT3"
warn_misplaced "${LAB_TRAINING_ROOT:-/workspace/training}/$OUT3" "$BASE/$OUT3"
warn_misplaced "/workspace/$OUT4" "$BASE/$OUT4"
warn_misplaced "${LAB_TRAINING_ROOT:-/workspace/training}/$OUT4" "$BASE/$OUT4"

# Attesi calcolati DAI DATI REALI (data-driven: le varianti non richiedono
# valori memorizzati — il check ricalcola gli esiti dai file di input).
expected_errors=$(grep -c 'ERROR' "$BASE/$LOG" 2>/dev/null || echo 0)
expected_ips=$(awk '$4 == 500 { print $1 }' "$BASE/$LOG" 2>/dev/null | sort -u | tr -d '\r' | awk '{$1=$1; print}' | grep -v '^$' || echo "")
expected_sum=$(awk -F, 'NR > 1 && $1 == "api" { total += $3 } END { print total+0 }' "$BASE/$CSV" 2>/dev/null)

# 1. File error_count.txt
if [ -f "$BASE/$OUT1" ] && [ "$(tr -d '[:space:]' < "$BASE/$OUT1")" = "$expected_errors" ]; then
  pass "$OUT1 = $expected_errors"
else
  got="assente"
  [ -f "$BASE/$OUT1" ] && got=$(tr -d '[:space:]' < "$BASE/$OUT1")
  miss "$OUT1 errato (ora: $got, atteso: $expected_errors)" "punto 1: grep ERROR $LOG | wc -l > $OUT1" "cat $OUT1"
fi

# 2. File failing_ips.txt
got_ips=""
if [ -f "$BASE/$OUT2" ]; then
  got_ips=$(tr -d '\r' < "$BASE/$OUT2" | awk '{$1=$1; print}' | grep -v '^$' || echo "")
fi

if [ -f "$BASE/$OUT2" ] && [ "$got_ips" = "$expected_ips" ]; then
  pass "$OUT2 ordinato e unico"
else
  miss "$OUT2 errato o assente" "punto 2: awk '\$4 == 500 {print \$1}' $LOG | sort -u > $OUT2" "cat $OUT2"
fi

# 3. File api_total.txt
if [ -f "$BASE/$OUT3" ] && [ "$(tr -d '[:space:]' < "$BASE/$OUT3")" = "$expected_sum" ]; then
  pass "$OUT3 = $expected_sum"
else
  got="assente"
  [ -f "$BASE/$OUT3" ] && got=$(tr -d '[:space:]' < "$BASE/$OUT3")
  miss "$OUT3 errato (ora: $got, atteso: $expected_sum)" "punto 3: somma requests dove service=api (awk -F, 'NR > 1 && \$1 == \"api\" { total += \$3 } END { print total }')" "cat $OUT3"
fi

# 4. File summary.txt
got_summary=""
if [ -f "$BASE/$OUT4" ]; then
  got_summary=$(head -n 1 "$BASE/$OUT4" | tr -d '\r' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
fi

if [ -f "$BASE/$OUT4" ] && [ "$got_summary" = "$TXT" ]; then
  pass "$OUT4 riga 1 ok"
else
  miss "$OUT4 prima riga errata" "punto 4: prima riga = $TXT (ok printf, echo o nano)" "head -n 1 $OUT4"
fi

[ "$fail" -eq 0 ]
