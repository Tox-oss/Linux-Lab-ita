#!/usr/bin/env bash
set -euo pipefail
cd /workspace 2>/dev/null || cd / || true
BASE=${LAB_TRAINING_ROOT:-/workspace/training}/${V_DIR:-storage-lab}
rm -rf "$BASE"
mkdir -p "$BASE/${V_DS:-datasets}/${V_A:-service-a}/logs" "$BASE/${V_DS:-datasets}/${V_B:-service-b}" "$BASE/${V_DS:-datasets}/${V_BIG:-big}"

cat > "$BASE/${V_DS:-datasets}/${V_A:-service-a}/${V_CFG:-config.yml}" <<'EOF'
service: service-a
port: 8080
mode: training
EOF

cat > "$BASE/${V_DS:-datasets}/${V_A:-service-a}/logs/${V_APP:-app.log}" <<'EOF'
INFO boot
WARN slow request
INFO ready
EOF

cat > "$BASE/${V_DS:-datasets}/${V_B:-service-b}/${V_README:-readme.txt}" <<'EOF'
small reference dataset
EOF

dd if=/dev/zero of="$BASE/${V_DS:-datasets}/${V_BIG:-big}/${V_BLOB:-blob.bin}" bs=1024 count=64 >/dev/null 2>&1
