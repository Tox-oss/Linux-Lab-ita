#!/usr/bin/env bash
set -euo pipefail
cd /workspace 2>/dev/null || cd / || true
BASE=${LAB_TRAINING_ROOT:-/workspace/training}/${V_DIR:-users-lab}
rm -rf "$BASE"
mkdir -p "$BASE"
if id ${V_USER:-learner} >/dev/null 2>&1; then
  userdel -r ${V_USER:-learner} >/dev/null 2>&1 || userdel ${V_USER:-learner} >/dev/null 2>&1 || true
fi
if getent group ${V_GROUP:-devops} >/dev/null 2>&1; then
  groupdel ${V_GROUP:-devops} >/dev/null 2>&1 || true
fi
