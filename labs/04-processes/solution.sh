#!/usr/bin/env bash
# Idempotente: se c'e gia un worker, lo sostituisce.
set -euo pipefail
cd ${LAB_TRAINING_ROOT:-/workspace/training}/process-lab

if [ -f worker.pid ]; then
  old=$(tr -d '[:space:]' < worker.pid || true)
  if [ -n "${old:-}" ] && kill -0 "$old" 2>/dev/null; then
    kill "$old" 2>/dev/null || true
  fi
fi

sleep 3600 &
echo $! > worker.pid
printf 'running\n' > status.txt
# alternativa per status.txt:  echo running > status.txt
# nota: se lanci 'cd ... && sleep 3600 &' in una riga sola, $! e' la subshell:
# separa con ';' oppure lancia sleep da solo.
ps -p "$(tr -d '[:space:]' < worker.pid)" -o pid,comm,args
lab check 04-processes
