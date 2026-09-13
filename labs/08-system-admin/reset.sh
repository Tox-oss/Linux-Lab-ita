#!/usr/bin/env bash
set -euo pipefail
cd /workspace 2>/dev/null || cd / || true
BASE=${LAB_TRAINING_ROOT:-/workspace/training}/${V_DIR:-admin-lab}
rm -rf "$BASE"
mkdir -p "$BASE"

# L'utente di sistema @V_USER@ ("auditor") e, per chi gira da utente normale,
# il daemon di log col messaggio marcato li ha gia' preparati l'ambiente
# (Dockerfile + entrypoint all'avvio del container).
# La suite, che gira da ROOT con le varianti (tag di log e utenti diversi),
# li prepara qui al volo: per lo studente (non-root) questi comandi falliscono
# in silenzio e non servono, perche' c'e' gia' il messaggio dell'entrypoint.
if ! id ${V_USER:-auditor} >/dev/null 2>&1 && [ "$(id -u)" = 0 ]; then
  useradd -m -s /bin/bash ${V_USER:-auditor}
fi
if [ "$(id -u)" = 0 ]; then
  pgrep -x syslogd >/dev/null 2>&1 || syslogd >/dev/null 2>&1 || true
  logger -t "${V_LOG_TAG:-assisted-lab}" "${V_LOG_MSG:-ciao da assisted-lab}" >/dev/null 2>&1 || true
fi
crontab -r >/dev/null 2>&1 || true

printf '%s\n' "${V_CRON_LINE:-17 3 * * * /usr/local/bin/lab doctor >/tmp/lab-doctor.log 2>&1}" > "$BASE/${V_CRON_FILE:-nightly.cron}"