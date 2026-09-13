#!/usr/bin/env bash
set -euo pipefail
cd /workspace 2>/dev/null || cd / || true
BASE=${LAB_TRAINING_ROOT:-/workspace/training}/${V_DIR:-process-lab}

# Uccidi il worker tracciato, se vivo.
if [ -f "$BASE/${V_PID:-worker.pid}" ]; then
  oldpid=$(tr -d '[:space:]' < "$BASE/${V_PID:-worker.pid}" 2>/dev/null || true)
  if [ -n "${oldpid:-}" ] && kill -0 "$oldpid" 2>/dev/null; then
    kill "$oldpid" >/dev/null 2>&1 || true
    # attesa breve, poi force
    sleep 0.1
    kill -9 "$oldpid" >/dev/null 2>&1 || true
  fi
fi

# Scopa eventuali sleep ${V_SLEEP:-3600} orfani di lab precedenti in questo container.
# (solo sleep con argomento ${V_SLEEP:-3600} — non tocca altri processi)
while read -r pid; do
  [ -n "$pid" ] || continue
  # skip PID 1 se per caso
  [ "$pid" = "1" ] && continue
  cmdline=$(tr '\0' ' ' < "/proc/$pid/cmdline" 2>/dev/null || true)
  case "$cmdline" in
    *"sleep ${V_SLEEP:-3600}"*) kill "$pid" >/dev/null 2>&1 || true ;;
  esac
done < <(pgrep -x sleep 2>/dev/null || true)

rm -rf "$BASE"
mkdir -p "$BASE"
