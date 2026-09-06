#!/usr/bin/env bash
# intro.sh — "Primo Giorno" trasmesso al primo accesso.
# Simula una conversazione: 2s di terminale vuoto, poi testo che appare
# lettera per lettera dentro il terminale (battitura), la domanda `whoami`,
# la scelta del nome che diventa l'amministratore (utente Linux reale con sudo).
# La sceneggiatura risponde alle domande del primo giorno:
#   dove sono  · chi sono  · perché non sono root  · perché cd prima di awk.
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
tw() {  # typewriter: stampa lettera per lettera (effetto conversazione)
  local s="$1" i c
  for (( i=0; i<${#s}; i++ )); do
    printf '%s' "${s:i:1}"
    sleep 0.015
  done
  printf '\n'
}
twnl() { tw "$1"; printf '\n'; }   # battitura + riga vuota
pause() { sleep "$1"; }
boxin() {  # box informativo colorato attorno a una domanda
  printf '\033[1;36m%s\033[0m\n' "$1"
}

C_NM=${LIGHTGREEN:-}
say() { printf '\033[1;32m%s\033[0m %s\n' ">>" "$1"; }   # il "sistema"
you() { printf '\033[1;34m%s\033[0m %s\n' ">" "$1"; }    # il giocatore (atteso)

# --- Scena 1: identità -----------------------------------------------------
clear
pause 2                                    # 2s di terminale vuoto

say "Rilevo un nuovo utente in questo laboratorio..."
twnl "Benvenuto nel mondo dei comandi. Nessuna paura: qui si sperimenta, si sbaglia e si impara."
pause 1
boxin "PRIMA LEZIONE: CHI SEI?"
twnl "Quello che stai per capire e' il comando piu' semplice e piu' importante di tutti."
say "Digita pure, senza paura:"

you "whoami"
twnl "."
twnl ".."
twnl "..."
pause 0.3
CMD_OUT=$(whoami 2>/dev/null || echo "?")
if [ "$CMD_OUT" != "root" ]; then
  CMD_OUT="root"
fi
printf '\033[1;33m%s\033[0m\n' "$CMD_OUT"
pause 0.8

tw "Vedi? Ora sei 'root'."
say "Ma 'root' non e' una persona: e' il super-utente del sistema."
say "Lavorare sempre come root vuol dire poter fare"
say "qualunque cosa, anche rompere tutto per sbaglio. Ecco perche' qui useremo"
twnl "un'identita' tutta tua, e sudo solo quando serve davvero."

# --- Scena 2: dove sono -----------------------------------------------------
boxin "DOVE SEI?"
twnl "Stai dentro un container Docker: una sandbox isolata e sicura, con dentro"
twnl "tutti i comandi del corso. Il tuo spazio di lavoro e' /workspace/training."
tw "Ecco chi ti ospita: "
OS_NAME=$(awk -F= '/^PRETTY_NAME/{gsub(/"/,"",$2);print $2}' /etc/os-release 2>/dev/null || echo "un sistema Linux")
printf '\033[1;33m%s\033[0m\n' "$OS_NAME"
twnl "I tuoi esercizi vivono qui accanto a te, isolati dal resto del mondo."

# --- Scena 3: perche' non root / sudo --------------------------------------
boxin "PERCHE' NON LAVORIAMO COME ROOT?"
twnl "Perche' qui si impara a *sperimentare*. Un errore da root puo' essere"
twnl "irreversibile; da utente normale e' un errore da cui si impara."
twnl "Sara' sempre disponibile 'sudo' per i casi seri, quando serve il potere."
pause 1

# --- Scena 4: perche' cd viene prima di awk --------------------------------
boxin "PERCHE' 'cd' VIENE PRIMA DI 'awk'?"
twnl "Per lavorare su un file devi prima sapere DOVE sei. Orientarti nel"
twnl "filesystem (cd, ls, pwd, find) viene SEMPRE prima di manipolare o"
twnl "elaborare il contenuto (grep, sort, awk)."
twnl "Ecco perche' il corso parte con filesystem e navigazione, e solo dopo"
twnl "con i comandi di elaborazione del testo. Prima sai dove andare,"
twnl "poi decidi cosa fare."
pause 1

# --- Scena 5: scelta del nome + creazione utente reale ----------------------
boxin "CHI VUOI ESSERE?"
say "Adesso crea la tua identita'. Scrivi un nome (solo minuscole, numeri e _):"
while :; do
  printf '\033[1;34m%s\033[0m ' "nome>"
  IFS= read -r NOME
  NOME=$(printf '%s' "$NOME" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9_')
  if [ -z "$NOME" ]; then
    say "Il nome non puo' essere vuoto. Riprova:"
    continue
  fi
  if [ "$NOME" = "root" ]; then
    say "root e' il super-utente di sistema, non un nome proprio. Scegline un altro:"
    continue
  fi
  if [ ${#NOME} -gt 16 ]; then
    say "Troppo lungo (max 16 caratteri). Riprova:"
    continue
  fi
  break
done

say "Creo la tua identita'..."
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
printf '%s' "$NOME" > "$INTRO_NAME_FILE"
printf 'done' > "$INTRO_STATE_FILE"

say "Fatto! D'ora in poi sarai '$NOME'."
twnl "Il tuo prompt personale sara' $NOME@container. Usa 'sudo' quando ti serve"
twnl "il potere di root. Sei pronto a cominciare con 'lab list'."

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
