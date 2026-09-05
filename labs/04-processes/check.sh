#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
BASE=${LAB_TRAINING_ROOT:-/workspace/training}/process-lab

printf 'check 04-processes\n'

# 0. Controllo e ripristino percorsi errati comuni
warn_misplaced "/workspace/worker.pid" "$BASE/worker.pid"
warn_misplaced "${LAB_TRAINING_ROOT:-/workspace/training}/worker.pid" "$BASE/worker.pid"
warn_misplaced "/workspace/status.txt" "$BASE/status.txt"
warn_misplaced "${LAB_TRAINING_ROOT:-/workspace/training}/status.txt" "$BASE/status.txt"

# 1-2. File worker.pid e processo sleep attivo
if [ -f "$BASE/worker.pid" ]; then
  pass "worker.pid esiste"
  pid=$(tr -d '[:space:]' < "$BASE/worker.pid" 2>/dev/null || echo "")
  if [ -n "${pid:-}" ] && ps -p "$pid" >/dev/null 2>&1; then
    pass "PID $pid e in esecuzione"
    comm=$(ps -p "$pid" -o comm= 2>/dev/null | awk '{$1=$1; print}')
    if [ "$comm" = "sleep" ]; then
      pass "processo = sleep"
    else
      child=$(pgrep -P "$pid" -x sleep 2>/dev/null | head -n 1 || true)
      if [ -n "${child:-}" ]; then
        pass "il processo figlio e' sleep (PID $child)"
      else
        miss "PID non e sleep (comm=$comm)" "punto 1: deve essere sleep 3600 in background; se hai scritto 'cd ... && sleep 3600 &' in una riga, separa con ';' oppure entra prima nella cartella e poi lancia sleep da solo, poi salva \$! in worker.pid" "ps -p $pid -o comm="
      fi
    fi
  else
    miss "PID in worker.pid non punta a un processo vivo" "punti 1-2: sleep 3600 &  poi  echo \$! > worker.pid; il worker dura ~1 ora: se e' morto, rilancia  lab start 04-processes" "ps -p \$(cat worker.pid)"
  fi
else
  miss "manca worker.pid" "punto 2: echo \$! > worker.pid dopo sleep 3600 &" "cat worker.pid"
fi

# 3. File status.txt
if [ -f "$BASE/status.txt" ] && grep -qE '^[[:space:]]*running[[:space:]]*$' "$BASE/status.txt"; then
  pass "status.txt = running"
else
  miss "status.txt errato o assente" "punto 3: testo esatto = running (ok printf, echo o nano)" "cat status.txt"
fi

if [ "$fail" -eq 0 ]; then
  printf '  (nota: il worker vive ~1 ora; se il container viene riavviato, rilancia: lab start 04-processes)\n'
fi

[ "$fail" -eq 0 ]
