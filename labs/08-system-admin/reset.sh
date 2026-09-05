#!/usr/bin/env bash
set -euo pipefail
cd /workspace 2>/dev/null || cd / || true
BASE=${LAB_TRAINING_ROOT:-/workspace/training}/admin-lab
rm -rf "$BASE"
mkdir -p "$BASE"

if ! id auditor >/dev/null 2>&1; then
  useradd -m -s /bin/bash auditor
fi

# Daemon di log (busybox syslogd) attivo + messaggio marcato nel log di
# sistema: il lab 4 del TASK lo recupera da /var/log/messages con grep.
if ! pgrep -x syslogd >/dev/null 2>&1; then
  syslogd >/dev/null 2>&1 || true
fi
logger -t assisted-lab "ciao da assisted-labs" 2>/dev/null || true

crontab -r >/dev/null 2>&1 || true

cat > "$BASE/nightly.cron" <<'EOF'
17 3 * * * /usr/local/bin/lab doctor >/tmp/lab-doctor.log 2>&1
EOF