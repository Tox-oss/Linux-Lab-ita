#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
BASE=${LAB_TRAINING_ROOT:-/workspace/training}/${V_DIR:-nav-lab}

printf 'check 06-navigation-search\n'

DOCS=${V_DOCS:-docs}
EVID=${V_EVID:-evidence}
LOGS=${V_LOGS:-logs}
APP=${V_APP:-app.log}
INC_PAT=${V_INC_PAT:-incident-*.txt}
OUT_CP=${V_OUT_CP:-current_path.txt}
OUT_RL=${V_OUT_RL:-root_listing.txt}
OUT_IF=${V_OUT_IF:-incident_files.txt}
OUT_LE=${V_OUT_LE:-last_events.txt}
OUT_OWN=${V_OUT_OWN:-owner.txt}
OWNER=${V_OWNER:-sre-oncall}

for f in "$OUT_CP" "$OUT_RL" "$OUT_IF" "$OUT_LE" "$OUT_OWN"; do
  warn_misplaced "/workspace/$f" "$BASE/$f"
  warn_misplaced "${LAB_TRAINING_ROOT:-/workspace/training}/$f" "$BASE/$f"
done

if [ -f "$BASE/$OUT_CP" ] && [ "$(head -n 1 "$BASE/$OUT_CP" | tr -d '\r')" = "$BASE" ]; then
  pass "$OUT_CP contiene il WORKDIR assoluto"
else
  miss "$OUT_CP errato o assente" "punto 1: cd nel WORKDIR, poi pwd > $OUT_CP" "cat $OUT_CP"
fi

listing=$(tr -d '\r' < "$BASE/$OUT_RL" 2>/dev/null | awk 'NF {print}' | sort || true)
for entry in "$DOCS" "$EVID" "$LOGS"; do
  if printf '%s\n' "$listing" | grep -qx "$entry"; then
    pass "$OUT_RL contiene $entry"
  else
    miss "$OUT_RL non contiene $entry" "punto 2: ls -1 > $OUT_RL" "cat $OUT_RL"
  fi
done

expected_incidents=$(cd "$BASE" && find "$EVID" -type f -name "$INC_PAT" 2>/dev/null | sort)
expected_incidents=$(printf '%s\n' "$expected_incidents" | tr -d '\r' | awk 'NF {print}')
got_incidents=$(tr -d '\r' < "$BASE/$OUT_IF" 2>/dev/null | awk 'NF {print}' || true)
if [ -f "$BASE/$OUT_IF" ] && [ "$got_incidents" = "$expected_incidents" ]; then
  pass "$OUT_IF contiene i 3 incident ordinati"
else
  miss "$OUT_IF errato o assente" "punto 3: find $EVID -type f -name '$INC_PAT' | sort > $OUT_IF" "cat $OUT_IF"
fi

expected_tail=$(tail -n 4 "$BASE/$LOGS/$APP")
got_tail=$(tr -d '\r' < "$BASE/$OUT_LE" 2>/dev/null || true)
if [ -f "$BASE/$OUT_LE" ] && [ "$got_tail" = "$expected_tail" ]; then
  pass "$OUT_LE contiene le ultime 4 righe del log"
else
  miss "$OUT_LE errato o assente" "punto 4: tail -n 4 $LOGS/$APP > $OUT_LE" "cat $OUT_LE"
fi

owner=$(head -n 1 "$BASE/$OUT_OWN" 2>/dev/null | tr -d '\r' | awk '{$1=$1; print}' || true)
if [ -f "$BASE/$OUT_OWN" ] && [ "$owner" = "$OWNER" ]; then
  pass "$OUT_OWN = $OWNER"
else
  miss "$OUT_OWN errato o assente" "punto 5: less $DOCS/${V_RUNBOOK:-runbook.txt}, poi scrivi $OWNER in $OUT_OWN" "cat $OUT_OWN"
fi

[ "$fail" -eq 0 ]
