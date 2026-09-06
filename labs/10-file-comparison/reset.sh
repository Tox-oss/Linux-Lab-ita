#!/usr/bin/env bash
set -euo pipefail
cd /workspace 2>/dev/null || cd / || true
BASE=${LAB_TRAINING_ROOT:-/workspace/training}/diff-lab
rm -rf "$BASE"
mkdir -p "$BASE/release_v1" "$BASE/release_v2"

cat > "$BASE/config.old.conf" <<'EOF'
port=8080
timeout=30
mode=production
EOF

cat > "$BASE/config.new.conf" <<'EOF'
port=8443
timeout=30
mode=production
EOF

cat > "$BASE/report_a.txt" <<'EOF'
build 482 completato senza errori
EOF
cp "$BASE/report_a.txt" "$BASE/report_b.txt"

cat > "$BASE/servers_prod.txt" <<'EOF'
host-a
host-b
host-c
host-d
EOF

cat > "$BASE/servers_staging.txt" <<'EOF'
host-b
host-c
host-e
EOF

cat > "$BASE/release_v1/app.conf" <<'EOF'
timeout=30
EOF
cat > "$BASE/release_v1/readme.txt" <<'EOF'
release 1
EOF
cat > "$BASE/release_v1/version.txt" <<'EOF'
1.0.0
EOF

cat > "$BASE/release_v2/app.conf" <<'EOF'
timeout=60
EOF
cp "$BASE/release_v1/readme.txt" "$BASE/release_v2/readme.txt"
cp "$BASE/release_v1/version.txt" "$BASE/release_v2/version.txt"

printf 'da cancellare\n' > "$BASE/deprecated.old"
