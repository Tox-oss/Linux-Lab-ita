#!/usr/bin/env bash
set -euo pipefail
cd /workspace 2>/dev/null || cd / || true
BASE=${LAB_TRAINING_ROOT:-/workspace/training}/nav-lab
rm -rf "$BASE"
mkdir -p "$BASE/docs" "$BASE/evidence/2026/alpha" "$BASE/evidence/2026/beta" "$BASE/evidence/archive" "$BASE/logs"

cat > "$BASE/evidence/2026/alpha/incident-001.txt" <<'EOF'
CASE=incident-001
SEVERITY=warning
SERVICE=api
EOF

cat > "$BASE/evidence/2026/beta/incident-002.txt" <<'EOF'
CASE=incident-002
SEVERITY=critical
SERVICE=payments
EOF

cat > "$BASE/evidence/archive/incident-003.txt" <<'EOF'
CASE=incident-003
SEVERITY=info
SERVICE=worker
EOF

cat > "$BASE/evidence/archive/readme.txt" <<'EOF'
Archived incident notes live here.
EOF

cat > "$BASE/logs/app.log" <<'EOF'
10:00 INFO boot sequence started
10:01 INFO config loaded
10:02 WARN cache warmup slow
10:03 INFO api worker ready
10:04 ERROR payment timeout
10:05 WARN retry scheduled
10:06 INFO retry completed
EOF

cat > "$BASE/docs/runbook.txt" <<'EOF'
APPLICATION RUNBOOK

Service: learner-api
Tier: internal training

Escalation owner: sre-oncall
Secondary contact: platform-duty

Procedure:
1. Check the last application events.
2. Find incident files under evidence.
3. Record only the requested owner in owner.txt.
EOF
