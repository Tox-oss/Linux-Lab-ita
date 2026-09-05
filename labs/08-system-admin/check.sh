#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
BASE=${LAB_TRAINING_ROOT:-/workspace/training}/admin-lab

printf 'check 08-system-admin\n'

for f in top_snapshot.txt memory_report.txt openrc_version.txt syslog_snapshot.txt sudo_user.txt installed_cron.txt; do
  warn_misplaced "/workspace/$f" "$BASE/$f"
  warn_misplaced "${LAB_TRAINING_ROOT:-/workspace/training}/$f" "$BASE/$f"
done

if [ -f "$BASE/top_snapshot.txt" ] && grep -qi '^top ' "$BASE/top_snapshot.txt"; then
  pass "top_snapshot.txt contiene output di top"
else
  miss "top_snapshot.txt errato o assente" "punto 1: top -b -n 1 > top_snapshot.txt" "cat top_snapshot.txt"
fi

if [ -f "$BASE/memory_report.txt" ] && grep -Eq '^(Mem|Memory):' "$BASE/memory_report.txt"; then
  pass "memory_report.txt contiene output di free"
else
  miss "memory_report.txt errato o assente" "punto 2: free -h > memory_report.txt" "cat memory_report.txt"
fi

if [ -f "$BASE/openrc_version.txt" ] && grep -qi '^openrc' "$BASE/openrc_version.txt"; then
  pass "openrc_version.txt contiene la versione OpenRC"
else
  miss "openrc_version.txt errato o assente" "punto 3: openrc --version | head -n 1 > openrc_version.txt" "cat openrc_version.txt"
fi

if [ -f "$BASE/syslog_snapshot.txt" ] && grep -qi 'assisted-lab' "$BASE/syslog_snapshot.txt"; then
  pass "syslog_snapshot.txt contiene il messaggio del log di sistema"
else
  miss "syslog_snapshot.txt errato o assente" "punto 4: grep assisted-lab /var/log/messages > syslog_snapshot.txt" "cat syslog_snapshot.txt"
fi

if [ -f "$BASE/sudo_user.txt" ] && [ "$(tr -d '[:space:]' < "$BASE/sudo_user.txt")" = "auditor" ]; then
  pass "sudo_user.txt = auditor"
else
  miss "sudo_user.txt errato o assente" "punto 5: sudo -u auditor whoami > sudo_user.txt" "cat sudo_user.txt"
fi

expected_cron='17 3 * * * /usr/local/bin/lab doctor >/tmp/lab-doctor.log 2>&1'
actual_cron=$(crontab -l 2>/dev/null | grep -F "$expected_cron" || true)
saved_cron=$(grep -F "$expected_cron" "$BASE/installed_cron.txt" 2>/dev/null || true)
if [ -n "$actual_cron" ] && [ -n "$saved_cron" ]; then
  pass "crontab installata e salvata in installed_cron.txt"
else
  miss "crontab non installata o installed_cron.txt incompleto" "punto 6: crontab nightly.cron; crontab -l > installed_cron.txt" "crontab -l"
fi

[ "$fail" -eq 0 ]