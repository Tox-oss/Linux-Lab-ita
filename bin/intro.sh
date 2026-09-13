#!/usr/bin/env bash
# intro.sh — "Primo Giorno" trasmesso al primo accesso.
# Simula il dialogo di Root, il guardiano del laboratorio, con chi arriva
# per la prima volta: testo che appare lettera per lettera (battitura),
# la domanda `whoami`, e la scelta del nome che diventa un utente Linux
# reale (in grado di usare sudo quando serve).
# La sceneggiatura risponde alle domande del primo giorno:
#   chi sei  · dove sei  · perché non lavorare da root  · che nome scegli.
#
# Eseguito SOLO una volta per volume Docker ("primo accesso"): salva lo stato
# in $LAB_TRAINING_ROOT/.intro-done e il nome in $LAB_TRAINING_ROOT/.intro-name.
# Idempotente e non bloccante: se lo stato esiste esce subito; in contesto
# non-TTY (CI, pipe, docker exec senza -t) non fa nulla.
#
# Uso:  bash /opt/assisted-labs/bin/intro.sh
# Var:  SKIP_INTRO=1  salta l'intro in ogni caso.

# --- Guardie: mai bloccare una shell in modo inatteso --------------------
# Volutamente NON si controlla `$-` (interattivita'): lo script parte come
# subprocess bash (bash intro.sh) dal banner, quindi e' tecnicamente
# non-interattivo pur girando su un terminale. La discriminante vera e'
# solo la presenza di un TTY su stdin/stdout: in CI/pipe/docker exec senza -t
# i file descriptor non sono terminali e qui si esce subito.
[ -t 0 ] && [ -t 1 ] || exit 0
[ -n "${SKIP_INTRO:-}" ] && exit 0

LAB_ROOT="${LAB_ROOT:-/opt/assisted-labs}"
TRAINING="${LAB_TRAINING_ROOT:-/workspace/training}"
INTRO_STATE_FILE="${TRAINING}/.intro-done"
INTRO_NAME_FILE="${TRAINING}/.intro-name"

[ -f "$INTRO_STATE_FILE" ] && exit 0

# --- Utilità --------------------------------------------------------------
# Velocita' di battitura (secondi per carattere): narrativa 0.04, comandi 0.04.
# Overridabili via ambiente per test rapidi (LAB_TYPE_NARR / LAB_TYPE_CMD).
# Il ritmo "a dettatura" (pause di punteggiatura) e' gestito dentro tw().
NARR_SPEED="${LAB_TYPE_NARR:-0.04}"
CMD_SPEED="${LAB_TYPE_CMD:-0.04}"

# --- Dettatura interattiva: INVIO o SPAZIO saltano al resto della riga -------
# Il terminale passa a modalita' non canonica senza echo solo durante la
# battitura; INVIO e SPAZIO completano subito il resto della riga, ogni altro
# tasto viene scartato senza eco e senza residui (ripristino garantito anche
# su Ctrl-C). Prima dei prompt reali (whoami, nome) tw_flush pulisce la coda.
INTRO_TTY_RAW=0
INTRO_STTY_SAVED=""
tw_trap() {
  if [ "${INTRO_TTY_RAW:-0}" = "1" ] && [ -n "${INTRO_STTY_SAVED:-}" ]; then
    stty "$INTRO_STTY_SAVED" </dev/tty 2>/dev/null || true
    INTRO_TTY_RAW=0
  fi
  trap - INT TERM EXIT
}
tw_interrupt() {
  tw_trap
  exit 130
}
tw_raw_on() {
  [ -t 1 ] || return 1
  INTRO_STTY_SAVED="$(stty -g </dev/tty 2>/dev/null)" || { INTRO_STTY_SAVED=""; return 1; }
  stty -icanon -echo </dev/tty 2>/dev/null || { INTRO_STTY_SAVED=""; return 1; }
  INTRO_TTY_RAW=1
  trap 'tw_interrupt' INT TERM
  trap 'tw_trap' EXIT
  return 0
}
tw_raw_off() {
  [ -t 1 ] || return 0
  tw_trap
  return 0
}
# tw_enter <secondi> — attende per <secondi> (accetta decimali) che l'utente
# prema INVIO o SPAZIO. Ritorna 0 se arriva INVIO o SPAZIO entro la finestra,
# 1 se scade. Ogni altro tasto viene letto e scartato subito.
tw_enter() {
  local win="$1" c k iters
  iters="$(awk -v w="$win" 'BEGIN{printf "%d", (w/0.01)+1}')"
  for (( k=0; k<iters; k++ )); do
    if IFS= read -r -s -n1 -t 0.01 c </dev/tty 2>/dev/null; then
      case "$c" in
        $'\n'|$'\r'|' ') return 0 ;;
      esac
    fi
  done
  return 1
}
# tw_flush — consuma l'input rimasto in coda prima di uscire dalla battitura:
# nulla deve finire nei prompt successivi (whoami, scelta del nome).
tw_flush() {
  local c
  while IFS= read -r -s -n1 -t 0.02 c </dev/tty 2>/dev/null; do :; done
  return 0
}

tw() {  # typewriter "a dettatura": stampa lettera per lettera con pause di punteggiatura
  local s="$1" speed="${2:-$NARR_SPEED}" i c
  local with_label="${3:-root}"   # "root" => etichetta "Root:" gialla; "none" => senza
  local ps="${LAB_PAUSE_SENTENCE:-0.4}"  # pausa lunga dopo . ! ?
  local pc="${LAB_PAUSE_COMMA:-0.15}"    # pausa breve dopo , ; :
  # Il personaggio che parla e' Root: la sua etichetta "Root:" e' in giallo
  # opaco (33), il testo del dialogo resta nel colore normale del terminale.
  # Disattivable per test puliti (LAB_PLAIN=1).
  local c_lbl=""
  if [ "${LAB_PLAIN:-0}" != "1" ] && [ "$with_label" = "root" ]; then
    c_lbl=$'\033[33mRoot:\033[0m '
  fi
  printf '%s' "$c_lbl"
  if [ "${LAB_INSTANT_RENDER:-0}" = "1" ] || [ "$speed" = "0" ] || [ ! -t 1 ]; then
    printf '%s\n' "$s"
    return
  fi
  tw_raw_on || { printf '%s\n' "$s"; return; }
  for (( i=0; i<${#s}; i++ )); do
    printf '%s' "${s:i:1}"
    c="${s:i:1}"
    # Dettatura: respiro dopo la punteggiatura; INVIO o SPAZIO saltano il resto.
    case "$c" in
      [.!?!])
        if tw_enter "$ps"; then
          printf '%s' "${s:i+1}"
          break
        fi
        ;;
      [,\;:])
        if tw_enter "$pc"; then
          printf '%s' "${s:i+1}"
          break
        fi
        ;;
    esac
    # Attesa base (velocita' di battitura); INVIO o SPAZIO saltano il resto.
    if tw_enter "$speed"; then
      printf '%s' "${s:i+1}"
      break
    fi
  done
  tw_flush
  tw_raw_off
  printf '\n'
}
tw_cmd() { tw "$1" "$CMD_SPEED" none; }   # battitura veloce dei comandi (senza etichetta)
twnl() { tw "$1"; printf '\n'; }   # battitura + riga vuota
pause() { sleep "$1"; }
scene_gap() { pause 3; clear; }   # 3s di lettura, poi schermo pulito
boxin() {  # box informativo colorato attorno a una domanda
  printf '\033[1;36m%s\033[0m\n' "$1"
}

say() { printf '\033[33mRoot:\033[0m %s\n' "$1"; }   # Root (giallo) parla all'utente
you() { printf '\033[1;34mUtente:\033[0m %s\n' "$1"; }   # la battuta attesa dell'utente (blu)

B=$'\033[1m'     # grassetto per i comandi/nomi nel dialogo (solo dentro say())
R=$'\033[0m'

# --- Scena 1: chi sei ------------------------------------------------------
clear
pause 2                                    # 2s di terminale vuoto

say "Oh, un nuovo visitatore? Benvenuto nel mio laboratorio."
pause 1
boxin "PRIMA LEZIONE: CHI SEI?"
twnl "Questo e' un corso interattivo: qui si sperimenta, si sbaglia e si impara."
say "Comincia dal gesto piu' semplice: prova a digitare ${B}whoami${R}"

# Fermata interattiva: il terminale lascia che sia l'utente a scrivere whoami
# per la prima volta. Senza timeout; fino a 3 tentativi; poi il terminale
# scrive lui 'whoami' (e su EOF/errore di lettura idem: l'intro non resta
# mai appesa).
ok_typed=0
for attempt in 1 2 3; do
  printf '\033[1;34m%s\033[0m ' "Utente:"
  if ! IFS= read -r TYPED; then
    # EOF (Ctrl-D): il terminale scrive lui whoami e prosegue.
    printf 'whoami\n'
    ok_typed=1
    break
  fi
  if [ "$TYPED" = "whoami" ]; then
    ok_typed=1
    break
  fi
  say "Non proprio: il comando e' ${B}whoami${R}. Prova di nuovo."
done
if [ "$ok_typed" != "1" ]; then
  you "whoami"
  tw_cmd "."
  tw_cmd ".."
  tw_cmd "..."
  pause 0.3
fi

say "Bella domanda! 'whoami' significa 'chi sono io'."
twnl "Chiedi al sistema con che identita' stai lavorando in questo momento."
say "E per capire la risposta servono i due ruoli del gioco: ${B}utente${R} e ${B}root${R}."
say "L'utente e' una persona come te: file, cartelle e permessi tutti suoi."
say "root e' l'amministratore: comanda ogni cosa, ma puo' anche rompere tutto."
twnl "Tu non sei root. Avrai una tua identita', e i pieni poteri si apriranno"
twnl "solo nei momenti in cui servono davvero."

scene_gap

# --- Scena 2: dove sei -----------------------------------------------------
boxin "DOVE SEI?"
twnl "Il laboratorio e' una sandbox: un container Docker isolato e sicuro,"
twnl "con tutti i comandi del corso gia' pronti dentro."
tw "Il tuo banco di lavoro e' /workspace/training. Ecco chi ti ospita: "
OS_NAME=$(awk -F= '/^PRETTY_NAME/{gsub(/"/,"",$2);print $2}' /etc/os-release 2>/dev/null || echo "un sistema Linux")
printf '\033[1;33m%s\033[0m\n' "$OS_NAME"
twnl "Un mondo in miniatura, tutto per te: quello che fai resta qui,"
twnl "e fuori non si accorge di nulla."

scene_gap

# --- Scena 3: perché non lavorare come root --------------------------------
boxin "PERCHE' NON LAVORIAMO COME ROOT?"
twnl "Perche' qui si impara facendo, senza timore di sbagliare. E root"
twnl "non perdona gli errori: bastano un comando e un attimo per perdere tutto."
twnl "Da utente normale, invece, si sbaglia, si osserva l'errore, si capisce."
say "Per i colpi da maestro esiste 'sudo': una porta che si apre"
twnl "solo nei casi che se la meritano davvero, mai per abitudine."

scene_gap

# --- Scena 4: scelta del nome + creazione utente reale ----------------------
boxin "CHI VUOI ESSERE?"
say "Prima di aprire le porte del laboratorio, mi serve una sola cosa: un nome."
say "Solo minuscole, numeri e _ (max 16 caratteri):"
while :; do
  printf '\033[1;34m%s\033[0m ' "Utente:"
  IFS= read -r NOME
  NOME=$(printf '%s' "$NOME" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9_')
  if [ -z "$NOME" ]; then
    say "Un nome vuoto non va bene. Riprova:"
    continue
  fi
  if [ "$NOME" = "root" ]; then
    say "root e' l'amministratore di sistema, non un nome tuo. Scegline un altro:"
    continue
  fi
  if [ ${#NOME} -gt 16 ]; then
    say "Troppo lungo (max 16 caratteri). Riprova:"
    continue
  fi
  break
done

say "Perfetto. Creo la tua identita'..."
if command -v adduser >/dev/null 2>&1; then
  adduser -D -s /bin/bash "$NOME" >/dev/null 2>&1 || true
  addgroup "$NOME" wheel >/dev/null 2>&1 || true
  mkdir -p "/home/$NOME" 2>/dev/null || true
  chown "$NOME:$NOME" "/home/$NOME" 2>/dev/null || true
  printf '%s:%s\n' "$NOME" "${NOME}pass" | chpasswd 2>/dev/null || true
else
  useradd -m -s /bin/bash "$NOME" >/dev/null 2>&1 || true
  usermod -aG sudo "$NOME" >/dev/null 2>&1 || true
  printf '%s\n' "$NOME:${NOME}pass" | chpasswd 2>/dev/null || true
fi

# Salva lo stato PRIMA dello switch: al prossimo avvio l'intro non riparte.
mkdir -p "$TRAINING"
# Dai la proprieta' dello spazio di lavoro all'utente: senza questo, la
# training resta root:root e il nuovo utente non puo' creare .lab-state
# (lab start/hint falliscono con "Permission denied").
chown -R "$NOME:$NOME" "$TRAINING" 2>/dev/null || true
printf '%s' "$NOME" > "$INTRO_NAME_FILE"
printf 'done' > "$INTRO_STATE_FILE"

say "Per ora sei uno user di nome '${NOME}' e avrai i permessi di quel ruolo."
say "La tua password di prova e' '${NOME}pass'."
twnl "Il tuo prompt sara' ${NOME}@container. Quando 'sudo' ti chiede la"
twnl "password, quella e' la chiave: apre la porta un comando alla volta."

pause 1
printf '\n\033[1;32m%s\033[0m\n\n' "=== Ingresso come ${NOME} ==="

# --- Switch reale all'utente appena creato ---------------------------------
if command -v su >/dev/null 2>&1 && id "$NOME" >/dev/null 2>&1; then
  HOME="/home/$NOME" USER="$NOME" LOGNAME="$NOME" \
    su - "$NOME"
fi
# Quando la shell del nuovo utente termina, si torna qui: segnala al banner
# (exit 42) che il primo giorno e' appena avvenuto, cosi' non stampa due box.
exit 42
