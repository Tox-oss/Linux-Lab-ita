#!/usr/bin/env bash
set -euo pipefail
cd /workspace 2>/dev/null || cd / || true
BASE=${LAB_TRAINING_ROOT:-/workspace/training}/perms-lab
rm -rf "$BASE"
mkdir -p "$BASE/scripts"
printf '#!/usr/bin/env bash\necho running\n' > "$BASE/scripts/run.sh"
chmod 644 "$BASE/scripts/run.sh"
printf 'secret\n' > "$BASE/private.txt"
chmod 644 "$BASE/private.txt"
