#!/usr/bin/env bash
set -euo pipefail
cd /workspace 2>/dev/null || cd / || true
BASE=${LAB_TRAINING_ROOT:-/workspace/training}/${V_DIR:-text-lab}
rm -rf "$BASE"
mkdir -p "$BASE"
printf '%s\n' "${V_LOG_DATA:-10.0.0.1 INFO /health 200
10.0.0.2 ERROR /api/users 500
10.0.0.3 INFO /api/orders 201
10.0.0.2 ERROR /api/payments 500
10.0.0.4 WARN /login 401
10.0.0.5 ERROR /api/users 503
10.0.0.6 INFO /assets/app.js 200
10.0.0.7 ERROR /api/orders 500}" > "$BASE/${V_LOG:-access.log}"
printf '%s\n' "${V_CSV_DATA:-service,region,requests
api,eu,120
web,eu,80
api,us,150
worker,eu,30
api,apac,70}" > "$BASE/${V_CSV:-services.csv}"
