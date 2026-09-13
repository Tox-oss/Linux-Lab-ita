#!/usr/bin/env bash
set -euo pipefail
cd /workspace 2>/dev/null || cd / || true
BASE=${LAB_TRAINING_ROOT:-/workspace/training}/${V_DIR:-diff-lab}
rm -rf "$BASE"
mkdir -p "$BASE/${V_REL_A:-release_v1}" "$BASE/${V_REL_B:-release_v2}"

printf '%s\n' "${V_CFG_OLD_DATA:-port=8080
timeout=30
mode=production}" > "$BASE/${V_CFG_OLD:-config.old.conf}"

printf '%s\n' "${V_CFG_NEW_DATA:-port=8443
timeout=30
mode=production}" > "$BASE/${V_CFG_NEW:-config.new.conf}"

printf '%s\n' "${V_REP_TXT:-build 482 completato senza errori}" > "$BASE/${V_REP_A:-report_a.txt}"
cp "$BASE/${V_REP_A:-report_a.txt}" "$BASE/${V_REP_B:-report_b.txt}"

printf '%s\n' "${V_PROD_DATA:-host-a
host-b
host-c
host-d}" > "$BASE/${V_PROD:-servers_prod.txt}"

printf '%s\n' "${V_STAG_DATA:-host-b
host-c
host-e}" > "$BASE/${V_STAG:-servers_staging.txt}"

cat > "$BASE/${V_REL_A:-release_v1}/${V_APP_CONF:-app.conf}" <<'EOF'
timeout=30
EOF
cat > "$BASE/${V_REL_A:-release_v1}/readme.txt" <<'EOF'
release 1
EOF
printf '%s\n' "${V_VER_A:-1.0.0}" > "$BASE/${V_REL_A:-release_v1}/version.txt"

cat > "$BASE/${V_REL_B:-release_v2}/${V_APP_CONF:-app.conf}" <<'EOF'
timeout=60
EOF
cp "$BASE/${V_REL_A:-release_v1}/readme.txt" "$BASE/${V_REL_B:-release_v2}/readme.txt"
cp "$BASE/${V_REL_A:-release_v1}/version.txt" "$BASE/${V_REL_B:-release_v2}/version.txt"

printf 'da cancellare\n' > "$BASE/${V_DEPRECATED:-deprecated.old}"
