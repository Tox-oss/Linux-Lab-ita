#!/usr/bin/env bash
set -euo pipefail
cd /workspace 2>/dev/null || cd / || true
BASE=${LAB_TRAINING_ROOT:-/workspace/training}/process-lab

# Uccidi il worker tracciato, se vivo.
if [ -f "$BASE/worker.pid" ]; then
  oldpid=$(tr -d '[:space:]' < "$BASE/worker.pid" 2>/dev/null || true)
  if [ -n "${oldpid:-}" ] && kill -0 "$oldpid" 2>/dev/null; then
    kill "$oldpid" >/dev/null 2>&1 || true
    # attesa breve, poi force
    sleep 0.1
    kill -9 "$oldpid" >/dev/null 2>&1 || true
  fi
fi

# Scopa eventuali sleep 3600 orfani di lab precedenti in questo container.
# (solo sleep con argomento 3600 — non tocca altri processi)
while read -r pid; do
  [ -n "$pid" ] || continue
  # skip PID 1 se per caso
  [ "$pid" = "1" ] && continue
  cmdline=$(tr '\0' ' ' < "/proc/$pid/cmdline" 2>/dev/null || true)
  case "$cmdline" in
    *'sleep 3600'*) kill "$pid" >/dev/null 2>&1 || true ;;
  esac
done < <(pgrep -x sleep 2>/dev/null || true)

rm -rf "$BASE"
mkdir -p "$BASE"
