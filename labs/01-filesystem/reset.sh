#!/usr/bin/env bash
set -euo pipefail
cd /workspace 2>/dev/null || cd / || true
BASE=${LAB_TRAINING_ROOT:-/workspace/training}/${V_DIR:-fs-lab}
rm -rf "$BASE"
mkdir -p "$BASE/${V_INBOX:-inbox}"
printf 'raw training data\n' > "$BASE/${V_INBOX:-inbox}/${V_RAW:-raw.txt}"
printf 'temporary file\n' > "$BASE/${V_TEMP:-temp.tmp}"
