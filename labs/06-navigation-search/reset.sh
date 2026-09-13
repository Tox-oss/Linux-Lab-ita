#!/usr/bin/env bash
set -euo pipefail
cd /workspace 2>/dev/null || cd / || true
BASE=${LAB_TRAINING_ROOT:-/workspace/training}/${V_DIR:-nav-lab}
DOCS=${V_DOCS:-docs}
EVID=${V_EVID:-evidence}
LOGS=${V_LOGS:-logs}
APP=${V_APP:-app.log}
RUNBOOK=${V_RUNBOOK:-runbook.txt}
YR=${V_YR:-2026}
A=${V_A:-alpha}
B=${V_B:-beta}
ARC=${V_ARC:-archive}
INC_PAT=${V_INC_PAT:-incident-*.txt}
OWNER=${V_OWNER:-sre-oncall}
SERVICE=${V_SERVICE:-learner-api}
stem="${INC_PAT%\**}"
rm -rf "$BASE"
mkdir -p "$BASE/$DOCS" "$BASE/$EVID/$YR/$A" "$BASE/$EVID/$YR/$B" "$BASE/$EVID/$ARC" "$BASE/$LOGS"

cat > "$BASE/$EVID/$YR/$A/${stem}001.txt" <<'EOF'
CASE=incident-001
SEVERITY=warning
SERVICE=api
EOF

cat > "$BASE/$EVID/$YR/$B/${stem}002.txt" <<'EOF'
CASE=incident-002
SEVERITY=critical
SERVICE=payments
EOF

cat > "$BASE/$EVID/$ARC/${stem}003.txt" <<'EOF'
CASE=incident-003
SEVERITY=info
SERVICE=worker
EOF

cat > "$BASE/$EVID/$ARC/readme.txt" <<'EOF'
Archived incident notes live here.
EOF

cat > "$BASE/$LOGS/$APP" <<'EOF'
10:00 INFO boot sequence started
10:01 INFO config loaded
10:02 WARN cache warmup slow
10:03 INFO api worker ready
10:04 ERROR payment timeout
10:05 WARN retry scheduled
10:06 INFO retry completed
EOF

cat > "$BASE/$DOCS/$RUNBOOK" <<EOF
APPLICATION RUNBOOK

Service: $SERVICE
Tier: internal training

Escalation owner: $OWNER
Secondary contact: platform-duty

Procedure:
1. Check the last application events.
2. Find incident files under $EVID.
3. Record only the requested owner in owner.txt.
EOF
