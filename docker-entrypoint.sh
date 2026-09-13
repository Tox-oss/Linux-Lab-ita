#!/bin/sh
# assisted-labs-entrypoint.sh — prepara l'ambiente di sistema all'avvio.
# Sostituisce la preparazione che viveva nel reset del lab 08 (che gira come
# utente normale dal CLI) con un setup fatto UNA volta alla partenza del
# container, quando ancora siamo root:
#   - daemon di log (busybox syslogd) + messaggio marcato per il lab 08
#     (TASK 4 lo recupera con grep da /var/log/messages);
#   - l'utente di sistema 'auditor' (usato da `sudo -u auditor whoami`) e'
#     creato gia' a build nel Dockerfile, qui basta assicurarsi che il log ci sia;
#   - l'identita' personale dello studente, ricreata dal nome salvato sul volume.
# Idempotente e non bloccante in ogni circostanza.
#
# Uso:  ENTRYPOINT ["/usr/local/bin/assisted-labs-entrypoint.sh"]
#       CMD ["bash"]

set -u

if command -v syslogd >/dev/null 2>&1; then
  pgrep -x syslogd >/dev/null 2>&1 || syslogd >/dev/null 2>&1 || true
fi
logger -t assisted-lab "ciao da assisted-lab" >/dev/null 2>&1 || true

# --- Identita' personale: sopravvivere al riavvio del container -------------
# L'intro ("Primo Giorno") crea un utente Linux reale e ne salva il nome sul
# VOLUME (.intro-name), ma l'account vive nel filesystem del CONTAINER, che con
# `docker run --rm` sparisce alla chiusura. Dal secondo avvio in poi l'intro non
# riparte (.intro-done e' sul volume) e senza questo blocco lo studente
# tornerebbe root, con i file di /workspace/training di proprieta' di un UID
# orfano. Qui l'account viene ricreato dal nome salvato, con lo stesso gruppo
# wheel e la stessa password di prova (<nome>pass) che l'intro gli ha insegnato.
TRAINING="${LAB_TRAINING_ROOT:-/workspace/training}"
INTRO_NAME_FILE="${TRAINING}/.intro-name"
if [ -f "$INTRO_NAME_FILE" ]; then
  STUDENTE=$(tr -cd 'a-z0-9_' < "$INTRO_NAME_FILE" 2>/dev/null || true)
  if [ -n "${STUDENTE:-}" ] && ! id "$STUDENTE" >/dev/null 2>&1; then
    if command -v adduser >/dev/null 2>&1; then
      adduser -D -s /bin/bash "$STUDENTE" >/dev/null 2>&1 || true
      addgroup "$STUDENTE" wheel >/dev/null 2>&1 || true
    else
      useradd -m -s /bin/bash "$STUDENTE" >/dev/null 2>&1 || true
      usermod -aG wheel "$STUDENTE" >/dev/null 2>&1 || true
    fi
    printf '%s:%spass\n' "$STUDENTE" "$STUDENTE" | chpasswd >/dev/null 2>&1 || true
    [ -d "/home/$STUDENTE" ] || mkdir -p "/home/$STUDENTE" 2>/dev/null || true
    chown -R "$STUDENTE:$STUDENTE" "/home/$STUDENTE" 2>/dev/null || true
    # Lo spazio di lavoro torna dell'utente: i file creati nella sessione
    # precedente hanno l'UID vecchio, che puo' non coincidere con quello nuovo.
    chown -R "$STUDENTE:$STUDENTE" "$TRAINING" 2>/dev/null || true
  fi
fi

exec "$@"
