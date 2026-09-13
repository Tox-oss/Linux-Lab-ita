#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
BASE=${LAB_TRAINING_ROOT:-/workspace/training}/${V_DIR:-diff-lab}

printf 'check 10-file-comparison\n'

CFG_OLD=${V_CFG_OLD:-config.old.conf}
CFG_NEW=${V_CFG_NEW:-config.new.conf}
REP_A=${V_REP_A:-report_a.txt}
REP_B=${V_REP_B:-report_b.txt}
PROD=${V_PROD:-servers_prod.txt}
STAG=${V_STAG:-servers_staging.txt}
REL_A=${V_REL_A:-release_v1}
REL_B=${V_REL_B:-release_v2}
APP_CONF=${V_APP_CONF:-app.conf}
DEPRECATED=${V_DEPRECATED:-deprecated.old}
OUT_DIFF=${V_OUT_DIFF:-config.diff}
OUT_CHECK=${V_OUT_CHECK:-report_check.txt}
OUT_ONLY=${V_OUT_ONLY:-only_prod.txt}
OUT_REL=${V_OUT_REL:-release_diff.txt}
VERD=${V_VERD:-identici}

for f in "$OUT_DIFF" "$OUT_CHECK" "$OUT_ONLY" "$OUT_REL"; do
  warn_misplaced "/workspace/$f" "$BASE/$f"
  warn_misplaced "${LAB_TRAINING_ROOT:-/workspace/training}/$f" "$BASE/$f"
done

old_port=$(grep '^port=' "$BASE/$CFG_OLD" 2>/dev/null | head -n 1 || true)
new_port=$(grep '^port=' "$BASE/$CFG_NEW" 2>/dev/null | head -n 1 || true)
if [ -s "$BASE/$OUT_DIFF" ] \
   && [ -n "$old_port" ] && [ -n "$new_port" ] \
   && grep -qx -- "-$old_port" "$BASE/$OUT_DIFF" \
   && grep -qx -- "+$new_port" "$BASE/$OUT_DIFF"; then
  pass "$OUT_DIFF cattura la modifica ($old_port -> $new_port)"
else
  miss "$OUT_DIFF assente o non riflette la modifica" "punto 1: diff -u $CFG_OLD $CFG_NEW > $OUT_DIFF" "cat $OUT_DIFF"
fi

rc=""
if [ -f "$BASE/$OUT_CHECK" ]; then
  rc=$(tr -d '[:space:]' < "$BASE/$OUT_CHECK" | tr '[:upper:]' '[:lower:]')
fi
if cmp -s "$BASE/$REP_A" "$BASE/$REP_B" && [ "$rc" = "identici" ]; then
  pass "$OUT_CHECK = identici (confermato con cmp)"
else
  miss "$OUT_CHECK errato o assente" "punto 2: cmp -s $REP_A $REP_B && echo identici > $OUT_CHECK" "cmp $REP_A $REP_B"
fi

expected_prod=$(comm -23 "$BASE/$PROD" "$BASE/$STAG" 2>/dev/null | tr -d '\r' | awk '{$1=$1; print}' | grep -v '^$' || echo "")
got_prod=""
if [ -f "$BASE/$OUT_ONLY" ]; then
  got_prod=$(tr -d '\r' < "$BASE/$OUT_ONLY" | awk '{$1=$1; print}' | grep -v '^$' || echo "")
fi
if [ "$got_prod" = "$expected_prod" ]; then
  pass "$OUT_ONLY = $(printf '%s' "$expected_prod" | tr '\n' ', ' | sed 's/,$//') (comm -23)"
else
  miss "$OUT_ONLY errato o assente" "punto 3: comm -23 $PROD $STAG > $OUT_ONLY" "comm -23 $PROD $STAG"
fi

if [ -s "$BASE/$OUT_REL" ] && grep -q "$APP_CONF" "$BASE/$OUT_REL"; then
  pass "$OUT_REL individua $APP_CONF come file cambiato"
else
  miss "$OUT_REL assente o non cita $APP_CONF" "punto 4: diff -r $REL_A $REL_B > $OUT_REL" "cat $OUT_REL"
fi

if [ ! -e "$BASE/$DEPRECATED" ]; then
  pass "$DEPRECATED eliminato"
else
  miss "$DEPRECATED ancora presente" "punto 5: rm $DEPRECATED" "ls $DEPRECATED"
fi

[ "$fail" -eq 0 ]
