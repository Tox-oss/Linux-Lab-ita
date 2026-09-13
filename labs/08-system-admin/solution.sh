#!/usr/bin/env bash
set -euo pipefail
cd ${LAB_TRAINING_ROOT:-/workspace/training}/${V_DIR:-admin-lab}

top -b -n 1 > ${V_OUT_TOP:-top_snapshot.txt}
free -h > ${V_OUT_MEM:-memory_report.txt}
openrc --version | head -n 1 > ${V_OUT_VER:-openrc_version.txt}
grep -F "${V_LOG_TAG:-assisted-lab}" /var/log/messages > ${V_OUT_SYS:-syslog_snapshot.txt} || true
sudo -u ${V_USER:-auditor} whoami > ${V_OUT_SUDO:-sudo_user.txt}
# crontab di busybox non e' suid: ci vuole sudo (tabella di sistema). Con sudo
# la tabella installata e' quella di root e 'crontab -l' la rilegge identica.
sudo crontab ${V_CRON_FILE:-nightly.cron}
sudo crontab -l > ${V_OUT_CRON:-installed_cron.txt}

lab check 08-system-admin