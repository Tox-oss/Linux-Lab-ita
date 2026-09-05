#!/usr/bin/env bash
# Idempotente: si puo rilanciare senza errori se user/group esistono gia.
set -euo pipefail
cd ${LAB_TRAINING_ROOT:-/workspace/training}/users-lab

if ! getent group devops >/dev/null 2>&1; then
  groupadd devops
fi

if ! id learner >/dev/null 2>&1; then
  useradd -m -s /bin/bash learner
else
  # assicura shell
  usermod -s /bin/bash learner
fi

# -aG non rimuove gli altri gruppi
usermod -aG devops learner

mkdir -p team
chown learner:devops team
chmod 770 team
lab check 03-users-groups
