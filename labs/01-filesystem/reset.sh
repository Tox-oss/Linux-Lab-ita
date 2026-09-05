#!/usr/bin/env bash
set -euo pipefail
cd /workspace 2>/dev/null || cd / || true
BASE=${LAB_TRAINING_ROOT:-/workspace/training}/fs-lab
rm -rf "$BASE"
mkdir -p "$BASE/inbox"
printf 'raw training data\n' > "$BASE/inbox/raw.txt"
printf 'temporary file\n' > "$BASE/temp.tmp"
