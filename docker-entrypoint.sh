#!/bin/sh
# assisted-labs-entrypoint.sh — prepara l'ambiente di sistema all'avvio.
# Sostituisce la preparazione che viveva nel reset del lab 08 (che gira come
# utente normale dal CLI) con un setup fatto UNA volta alla partenza del
# container, quando ancora siamo root:
#   - daemon di log (busybox syslogd) + messaggio marcato per il lab 08
#     (TASK 4 lo recupera con grep da /var/log/messages);
#   - l'utente di sistema 'auditor' (usato da `sudo -u auditor whoami`) e'
#     creato gia' a build nel Dockerfile, qui basta assicurarsi che il log ci sia.
# Idempotente e non bloccante in ogni circostanza.
#
# Uso:  ENTRYPOINT ["/usr/local/bin/assisted-labs-entrypoint.sh"]
#       CMD ["bash"]

set -u

if command -v syslogd >/dev/null 2>&1; then
  pgrep -x syslogd >/dev/null 2>&1 || syslogd >/dev/null 2>&1 || true
fi
logger -t assisted-lab "ciao da assisted-lab" >/dev/null 2>&1 || true

exec "$@"