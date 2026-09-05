#!/usr/bin/env bash
set -euo pipefail
cd /workspace 2>/dev/null || cd / || true
BASE=${LAB_TRAINING_ROOT:-/workspace/training}/net-lab

if [ -f "$BASE/listener.pid" ]; then
  oldpid=$(tr -d '[:space:]' < "$BASE/listener.pid" 2>/dev/null || true)
  if [ -n "${oldpid:-}" ] && kill -0 "$oldpid" 2>/dev/null; then
    kill "$oldpid" >/dev/null 2>&1 || true
    sleep 0.1
    kill -9 "$oldpid" >/dev/null 2>&1 || true
  fi
fi

rm -rf "$BASE"
mkdir -p "$BASE/remote/nested"

cat > "$BASE/remote/status.json" <<'EOF'
{"service":"training-api","status":"ok","port":8088}
EOF

cat > "$BASE/remote/nested/info.txt" <<'EOF'
synced by rsync
EOF

nc -lk 127.0.0.1 8088 >/dev/null 2>&1 &
echo $! > "$BASE/listener.pid"
