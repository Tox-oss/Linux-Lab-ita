#!/usr/bin/env bash
set -euo pipefail
cd /workspace 2>/dev/null || cd / || true
BASE=${LAB_TRAINING_ROOT:-/workspace/training}/users-lab
rm -rf "$BASE"
mkdir -p "$BASE"
if id learner >/dev/null 2>&1; then
  userdel -r learner >/dev/null 2>&1 || userdel learner >/dev/null 2>&1 || true
fi
if getent group devops >/dev/null 2>&1; then
  groupdel devops >/dev/null 2>&1 || true
fi
