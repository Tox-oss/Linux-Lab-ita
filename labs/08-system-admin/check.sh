#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
BASE=${LAB_TRAINING_ROOT:-/workspace/training}/${V_DIR:-admin-lab}

printf 'check 08-system-admin\n'

for f in ${V_OUT_TOP:-top_snapshot.txt} ${V_OUT_MEM:-memory_report.txt} ${V_OUT_VER:-openrc_version.txt} ${V_OUT_SYS:-syslog_snapshot.txt} ${V_OUT_SUDO:-sudo_user.txt} ${V_OUT_CRON:-installed_cron.txt}; do
  warn_misplaced "/workspace/$f" "$BASE/$f"
  warn_misplaced "${LAB_TRAINING_ROOT:-/workspace/training}/$f" "$BASE/$f"
done

if [ -f "$BASE/${V_OUT_TOP:-top_snapshot.txt}" ] && grep -qi '^top ' "$BASE/${V_OUT_TOP:-top_snapshot.txt}"; then
  pass "${V_OUT_TOP:-top_snapshot.txt} contiene output di top"
else
  miss "${V_OUT_TOP:-top_snapshot.txt} errato o assente" "punto 1: top -b -n 1 > ${V_OUT_TOP:-top_snapshot.txt}" "cat ${V_OUT_TOP:-top_snapshot.txt}"
fi

if [ -f "$BASE/${V_OUT_MEM:-memory_report.txt}" ] && grep -Eq '^(Mem|Memory):' "$BASE/${V_OUT_MEM:-memory_report.txt}"; then
  pass "${V_OUT_MEM:-memory_report.txt} contiene output di free"
else
  miss "${V_OUT_MEM:-memory_report.txt} errato o assente" "punto 2: free -h > ${V_OUT_MEM:-memory_report.txt}" "cat ${V_OUT_MEM:-memory_report.txt}"
fi

if [ -f "$BASE/${V_OUT_VER:-openrc_version.txt}" ] && grep -qi '^openrc' "$BASE/${V_OUT_VER:-openrc_version.txt}"; then
  pass "${V_OUT_VER:-openrc_version.txt} contiene la versione OpenRC"
else
  miss "${V_OUT_VER:-openrc_version.txt} errato o assente" "punto 3: openrc --version | head -n 1 > ${V_OUT_VER:-openrc_version.txt}" "cat ${V_OUT_VER:-openrc_version.txt}"
fi

if [ -f "$BASE/${V_OUT_SYS:-syslog_snapshot.txt}" ] && grep -qi "${V_LOG_TAG:-assisted-lab}" "$BASE/${V_OUT_SYS:-syslog_snapshot.txt}"; then
  pass "${V_OUT_SYS:-syslog_snapshot.txt} contiene il messaggio del log di sistema"
else
  miss "${V_OUT_SYS:-syslog_snapshot.txt} errato o assente" "punto 4: grep ${V_LOG_TAG:-assisted-lab} /var/log/messages > ${V_OUT_SYS:-syslog_snapshot.txt}" "cat ${V_OUT_SYS:-syslog_snapshot.txt}"
fi

if [ -f "$BASE/${V_OUT_SUDO:-sudo_user.txt}" ] && [ "$(tr -d '[:space:]' < "$BASE/${V_OUT_SUDO:-sudo_user.txt}")" = "${V_USER:-auditor}" ]; then
  pass "${V_OUT_SUDO:-sudo_user.txt} = ${V_USER:-auditor}"
else
  miss "${V_OUT_SUDO:-sudo_user.txt} errato o assente" "punto 5: sudo -u ${V_USER:-auditor} whoami > ${V_OUT_SUDO:-sudo_user.txt}" "cat ${V_OUT_SUDO:-sudo_user.txt}"
fi

expected_cron="${V_CRON_LINE:-17 3 * * * /usr/local/bin/lab doctor >/tmp/lab-doctor.log 2>&1}"
saved_cron=$(grep -F "$expected_cron" "$BASE/${V_OUT_CRON:-installed_cron.txt}" 2>/dev/null || true)
if [ "$(id -u)" = 0 ]; then
  actual_cron=$(crontab -l 2>/dev/null | grep -F "$expected_cron" || true)
else
  # Utente normale: crontab busybox non e' suid, la tabella e' di sistema
  # (installata con sudo). La rilegge con sudo -n: funziona se le credenziali
  # sono ancora in cache nella stessa sessione del 'sudo crontab'.
  actual_cron=$(sudo -n crontab -l 2>/dev/null | grep -F "$expected_cron" || true)
fi
if [ -n "$saved_cron" ] && { [ -n "$actual_cron" ] || [ "$(id -u)" != 0 ]; }; then
  pass "crontab installata e salvata in ${V_OUT_CRON:-installed_cron.txt}"
else
  miss "crontab non installata o ${V_OUT_CRON:-installed_cron.txt} incompleto" "punto 6: sudo crontab ${V_CRON_FILE:-nightly.cron}; sudo crontab -l > ${V_OUT_CRON:-installed_cron.txt}" "sudo crontab -l"
fi

[ "$fail" -eq 0 ]