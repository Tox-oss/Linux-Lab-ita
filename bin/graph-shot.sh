#!/usr/bin/env bash
# graph-shot.sh — cattura "schermo" del rendering reale di una funzione del
# corso Assisted Linux Labs. Usato dall'agente Graph per il QA grafico/visivo
# (allineamento bordi/colonne, troncamenti, colori ANSI, elementi fuori posto).
#
# Perche' Xvfb? L'host e' GNOME Wayland: le catture programmatiche schermo sono
# bloccate (AccessDenied) e le finestre native non appaiono su X. Lo script
# apre una display virtuale (Xvfb) in un container dedicato, lancia un xterm
# che esegue la funzione del corso dai sorgenti montati, e cattura:
#   - una PNG della finestra xterm  -> evidenza visiva per ispezione umana/AGENTI
#   - un typescript esatto (script)  -> per analisi byte-precisa dell'allineamento
#
# Dipendenze host: docker.
# L'immagine di cattura e' definita in ~/assisted-labs/Screenshot.gra
# (tag graph-shoot:latest).
#
# Uso:
#   bin/graph-shot.sh <output-base> -- <comando corso...>
#   es. bin/graph-shot.sh reports/screenshots/01/task -- bash /sources/bin/lab task 01-filesystem
#       -> reports/screenshots/01/task.png + reports/screenshots/01/task.typescript
#
# Note sul comando: viene eseguito DENTRO l'xterm con i sorgenti montati su
# /sources (LAB_ROOT=/sources). Per il banner: `bash /sources/startup-banner.sh`
# oppure lanciare una shell logata col banner.
#
# Variabili opzionali:
#   SHOT_HOLD   secondi di permanenza della finestra (default 8)
#   SHOT_COLS   colonne del terminale virtuale (default 110)
#   SHOT_ROWS   righe del terminale virtuale (default 30)

set -euo pipefail

CAP_IMAGE="graph-shoot:latest"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SHOT_HOLD="${SHOT_HOLD:-8}"
SHOT_COLS="${SHOT_COLS:-110}"
SHOT_ROWS="${SHOT_ROWS:-30}"

usage() { echo "uso: bin/graph-shot.sh <output-base> -- <comando...>" >&2; exit 2; }

[ "$#" -lt 3 ] && usage
OUT_BASE="${1%/}"; shift
[ "$1" = "--" ] || usage
shift

mkdir -p "$(dirname "$OUT_BASE")"
OUT_PNG="$(readlink -f "$OUT_BASE").png"
OUT_TS="$(readlink -f "$OUT_BASE").typescript"
OUT_DIR="$(dirname "$OUT_PNG")"

# 1. Immagine di cattura, rebuild se non presente.
if ! docker image inspect "$CAP_IMAGE" >/dev/null 2>&1; then
  echo "==> build immagine di cattura $CAP_IMAGE ..." >&2
  docker build -f "$ROOT/Screenshot.gra" -t "$CAP_IMAGE" "$ROOT" >/dev/null 2>&1 \
    || { echo "ERRORE build immagine di cattura" >&2; exit 3; }
fi

# 2. Comando corso (escape per passarlo come argomento singolo all'xterm).
CMD="$*"

# 3. Runner eseguito DENTRO il container di cattura.
SCRATCH="$(mktemp -d /tmp/graph-shot.XXXXXX)"
trap 'rm -rf "$SCRATCH"' EXIT
RUNNER="$SCRATCH/runner.sh"

cat > "$RUNNER" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
export TERM=xterm-256color
Xvfb :99 -screen 0 1320x900x24 -nolisten tcp >/tmp/xvfb.log 2>&1 &
XVFB=$!
sleep 1

# Attesa che il server X sia realmente pronto (evita il race di startup:
# "Can't open display" se i client partono prima che Xvfb abbia finito).
export DISPLAY=:99
for i in $(seq 1 30); do
  xdpyinfo >/dev/null 2>&1 && break
  sleep 0.5
done

# Finestra xterm visibile: esegue il comando corso dai sorgenti montati, poi
# MANTIENE LA SHELL APERTA (sleep finale) cosi' la finestra resta viva durante
# l'intero hold (senno' chiude -> catture root vuote).
xterm -geometry "$SHOT_COLS"x"$SHOT_ROWS"+50+50 \
  -fg '#e0e0e0' -bg '#0d0d0d' \
  -e bash -lc 'cd /sources; export LAB_ROOT=/sources LAB_TRAINING_ROOT=/sources/tmp; eval "$CMD" 2>/tmp/cmderr; sleep "$((SHOT_HOLD+8))"' \
  >/tmp/xterm.log 2>&1 &
XTERM=$!

# 4+5+6. Attesa di rendering, poi cattura della ROOT display (sempre presente e
# deterministica). La cattura della sola finestra xterm e' risultata flaky
# (race sull'id/rendering); la root contiene comunque l'xterm (in alto a
# sinistra) ed e' affidabile.
sleep 5
timeout 10 import -window root "$OUT_PNG" 2>/tmp/import.log || true

# 7. Typescript esatto del flusso (script -c riceve il comando direttamente;
# nessun eval, cosi' le virgolette annidate del CMD non vengono alterate).
( cd /sources \
  && export DISPLAY=:99 LAB_ROOT=/sources LAB_TRAINING_ROOT=/sources/tmp \
  && timeout 15 script -q -c "cd /sources; export LAB_ROOT=/sources LAB_TRAINING_ROOT=/sources/tmp DISPLAY=:99; $CMD" "$OUT_TS" >/dev/null 2>&1 ) &
TS_PID=$!

# 8. Sostiene la finestra finche' SHOT_HOLD, poi chiude xterm/Xvfb/script.
sleep "$SHOT_HOLD"
kill "$XTERM" "$XVFB" "$TS_PID" 2>/dev/null || true
exit 0
EOF
chmod +x "$RUNNER"

# 9. Esegue il runner in un container temporaneo (sorgenti montate ro + output dir).
CTN="graph-shot-$(date +%s)"
docker run -d --name "$CTN" \
  -v "$ROOT:/sources:ro" \
  -v "$OUT_DIR":/shots:rw \
  -v "$RUNNER":/runner.sh:ro \
  -e CMD="$CMD" \
  -e OUT_PNG="/shots/$(basename "$OUT_PNG")" \
  -e OUT_TS="/shots/$(basename "$OUT_TS")" \
  -e SHOT_HOLD="$SHOT_HOLD" \
  -e SHOT_COLS="$SHOT_COLS" \
  -e SHOT_ROWS="$SHOT_ROWS" \
  "$CAP_IMAGE" bash /runner.sh >/dev/null 2>&1

# 10. Attesa del completamento (con kill di sicurezza contro gli hang).
ready=0
for i in $(seq 1 35); do
  docker inspect -f '{{.State.Running}}' "$CTN" 2>/dev/null | grep -q true || { ready=1; break; }
  sleep 1
done
[ "$ready" != "1" ] && { echo "WARN: cattura in timeout, kill" >&2; docker kill "$CTN" >/dev/null 2>&1; }
docker rm -f "$CTN" >/dev/null 2>&1 || true

# 11. Verifica esito: conta i pixel di TEXTO (chiari) - catture vuote ne
# hanno ~0; una cattura reale contiene testo chiaro su fondo scuro.
if [ -s "$OUT_PNG" ] && [ -s "$OUT_TS" ]; then
  NPIX="$(docker run --rm -v "$OUT_DIR":/chk:ro graph-shoot:latest \
    bash -lc "convert '/chk/$(basename "$OUT_PNG")' -colorspace gray -threshold 50% -format '%[fx:mean*w*h]' info:" 2>/dev/null || echo 0)"
  if [ "${NPIX%.*}" -gt 100 ]; then
    echo "OK: $OUT_PNG (contenuto: $NPIX px testo) + $OUT_TS"
    exit 0
  else
    echo "WARN: cattura quasi vuota (~$NPIX px testo) - $OUT_PNG" >&2
    exit 0
  fi
else
  echo "ERRORE: cattura incompleta ($OUT_PNG / $OUT_TS)" >&2
  exit 1
fi