#!/usr/bin/env bash
set -euo pipefail
cd ${LAB_TRAINING_ROOT:-/workspace/training}/admin-lab

top -b -n 1 > top_snapshot.txt
free -h > memory_report.txt
openrc --version | head -n 1 > openrc_version.txt
grep -F 'assisted-lab' /var/log/messages > syslog_snapshot.txt || true
sudo -u auditor whoami > sudo_user.txt
crontab nightly.cron
crontab -l > installed_cron.txt

lab check 08-system-admin