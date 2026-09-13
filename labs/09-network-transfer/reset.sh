#!/usr/bin/env bash
set -euo pipefail
cd /workspace 2>/dev/null || cd / || true
BASE=${LAB_TRAINING_ROOT:-/workspace/training}/${V_DIR:-net-lab}

if [ -f "$BASE/listener.pid" ]; then
  oldpid=$(tr -d '[:space:]' < "$BASE/listener.pid" 2>/dev/null || true)
  if [ -n "${oldpid:-}" ] && kill -0 "$oldpid" 2>/dev/null; then
    kill "$oldpid" >/dev/null 2>&1 || true
    sleep 0.1
    kill -9 "$oldpid" >/dev/null 2>&1 || true
  fi
fi

rm -rf "$BASE"
mkdir -p "$BASE/${V_REMOTE:-remote}/${V_NESTED:-nested}"

printf '%s\n' "${V_JSON_DATA:-{\"service\":\"training-api\",\"status\":\"ok\",\"port\":8088\}}" > "$BASE/${V_REMOTE:-remote}/${V_JSON:-status.json}"

printf 'synced by rsync\n' > "$BASE/${V_REMOTE:-remote}/${V_NESTED:-nested}/${V_INFO:-info.txt}"

nc -lk 127.0.0.1 ${V_PORT:-8088} >/dev/null 2>&1 &
echo $! > "$BASE/listener.pid"
