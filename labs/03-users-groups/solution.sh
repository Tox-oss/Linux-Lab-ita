#!/usr/bin/env bash
# Idempotente: si puo rilanciare senza errori se user/group esistono gia.
set -euo pipefail
cd ${LAB_TRAINING_ROOT:-/workspace/training}/${V_DIR:-users-lab}

if ! getent group ${V_GROUP:-devops} >/dev/null 2>&1; then
  sudo groupadd ${V_GROUP:-devops}
fi

if ! id ${V_USER:-learner} >/dev/null 2>&1; then
  sudo useradd -m -s /bin/bash ${V_USER:-learner}
else
  # assicura shell
  sudo usermod -s /bin/bash ${V_USER:-learner}
fi

# -aG non rimuove gli altri gruppi
sudo usermod -aG ${V_GROUP:-devops} ${V_USER:-learner}

mkdir -p ${V_TEAM:-team}
sudo chown ${V_USER:-learner}:${V_GROUP:-devops} ${V_TEAM:-team}
chmod ${V_TEAM_MODE:-770} ${V_TEAM:-team}
lab check 03-users-groups
