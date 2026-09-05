#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
BASE=${LAB_TRAINING_ROOT:-/workspace/training}/nav-lab

printf 'check 06-navigation-search\n'

for f in current_path.txt root_listing.txt incident_files.txt last_events.txt owner.txt; do
  warn_misplaced "/workspace/$f" "$BASE/$f"
  warn_misplaced "${LAB_TRAINING_ROOT:-/workspace/training}/$f" "$BASE/$f"
done

if [ -f "$BASE/current_path.txt" ] && [ "$(head -n 1 "$BASE/current_path.txt" | tr -d '\r')" = "$BASE" ]; then
  pass "current_path.txt contiene il WORKDIR assoluto"
else
  miss "current_path.txt errato o assente" "punto 1: cd nel WORKDIR, poi pwd > current_path.txt" "cat current_path.txt"
fi

listing=$(tr -d '\r' < "$BASE/root_listing.txt" 2>/dev/null | awk 'NF {print}' | sort || true)
for entry in docs evidence logs; do
  if printf '%s\n' "$listing" | grep -qx "$entry"; then
    pass "root_listing.txt contiene $entry"
  else
    miss "root_listing.txt non contiene $entry" "punto 2: ls -1 > root_listing.txt" "cat root_listing.txt"
  fi
done

expected_incidents=$(printf 'evidence/2026/alpha/incident-001.txt\nevidence/2026/beta/incident-002.txt\nevidence/archive/incident-003.txt')
got_incidents=$(tr -d '\r' < "$BASE/incident_files.txt" 2>/dev/null | awk 'NF {print}' || true)
if [ -f "$BASE/incident_files.txt" ] && [ "$got_incidents" = "$expected_incidents" ]; then
  pass "incident_files.txt contiene i 3 incident ordinati"
else
  miss "incident_files.txt errato o assente" "punto 3: find evidence -type f -name 'incident-*.txt' | sort > incident_files.txt" "cat incident_files.txt"
fi

expected_tail=$(tail -n 4 "$BASE/logs/app.log")
got_tail=$(tr -d '\r' < "$BASE/last_events.txt" 2>/dev/null || true)
if [ -f "$BASE/last_events.txt" ] && [ "$got_tail" = "$expected_tail" ]; then
  pass "last_events.txt contiene le ultime 4 righe del log"
else
  miss "last_events.txt errato o assente" "punto 4: tail -n 4 logs/app.log > last_events.txt" "cat last_events.txt"
fi

owner=$(head -n 1 "$BASE/owner.txt" 2>/dev/null | tr -d '\r' | awk '{$1=$1; print}' || true)
if [ -f "$BASE/owner.txt" ] && [ "$owner" = "sre-oncall" ]; then
  pass "owner.txt = sre-oncall"
else
  miss "owner.txt errato o assente" "punto 5: less docs/runbook.txt, poi scrivi sre-oncall in owner.txt" "cat owner.txt"
fi

[ "$fail" -eq 0 ]
