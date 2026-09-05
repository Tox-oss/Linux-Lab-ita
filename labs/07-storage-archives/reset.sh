#!/usr/bin/env bash
set -euo pipefail
cd /workspace 2>/dev/null || cd / || true
BASE=${LAB_TRAINING_ROOT:-/workspace/training}/storage-lab
rm -rf "$BASE"
mkdir -p "$BASE/datasets/service-a/logs" "$BASE/datasets/service-b" "$BASE/datasets/big"

cat > "$BASE/datasets/service-a/config.yml" <<'EOF'
service: service-a
port: 8080
mode: training
EOF

cat > "$BASE/datasets/service-a/logs/app.log" <<'EOF'
INFO boot
WARN slow request
INFO ready
EOF

cat > "$BASE/datasets/service-b/readme.txt" <<'EOF'
small reference dataset
EOF

dd if=/dev/zero of="$BASE/datasets/big/blob.bin" bs=1024 count=64 >/dev/null 2>&1
