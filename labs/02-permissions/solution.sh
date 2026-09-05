#!/usr/bin/env bash
set -euo pipefail
cd ${LAB_TRAINING_ROOT:-/workspace/training}/perms-lab
chmod a+x scripts/run.sh
chmod 600 private.txt
mkdir -p dropbox
chmod 775 dropbox
printf 'permissions matter\n' > dropbox/README.txt
# alternativa (newline finale tollerato):  echo 'permissions matter' > dropbox/README.txt
lab check 02-permissions
