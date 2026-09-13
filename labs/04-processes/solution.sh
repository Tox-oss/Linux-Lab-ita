#!/usr/bin/env bash
# Idempotente: se c'e gia un worker, lo sostituisce.
set -euo pipefail
cd ${LAB_TRAINING_ROOT:-/workspace/training}/${V_DIR:-process-lab}

if [ -f ${V_PID:-worker.pid} ]; then
  old=$(tr -d '[:space:]' < ${V_PID:-worker.pid} || true)
  if [ -n "${old:-}" ] && kill -0 "$old" 2>/dev/null; then
    kill "$old" 2>/dev/null || true
  fi
fi

sleep ${V_SLEEP:-3600} &
echo $! > ${V_PID:-worker.pid}
printf '%s\n' "${V_TEXT:-running}" > ${V_STATUS:-status.txt}
# alternativa per ${V_STATUS:-status.txt}:  echo ${V_TEXT:-running} > ${V_STATUS:-status.txt}
# nota: se lanci 'cd ... && sleep 3600 &' in una riga sola, $! e' la subshell:
# separa con ';' oppure lancia sleep da solo.
ps -p "$(tr -d '[:space:]' < ${V_PID:-worker.pid})" -o pid,comm,args
lab check 04-processes
