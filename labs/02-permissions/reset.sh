#!/usr/bin/env bash
set -euo pipefail
cd /workspace 2>/dev/null || cd / || true
BASE=${LAB_TRAINING_ROOT:-/workspace/training}/${V_DIR:-perms-lab}
rm -rf "$BASE"
mkdir -p "$BASE/${V_SCRIPTS:-scripts}"
printf '#!/usr/bin/env bash\necho running\n' > "$BASE/${V_SCRIPTS:-scripts}/${V_SCRIPT:-run.sh}"
chmod 644 "$BASE/${V_SCRIPTS:-scripts}/${V_SCRIPT:-run.sh}"
printf 'secret\n' > "$BASE/${V_PRIVATE:-private.txt}"
chmod 644 "$BASE/${V_PRIVATE:-private.txt}"
