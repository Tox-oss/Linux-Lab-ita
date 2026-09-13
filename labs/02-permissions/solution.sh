#!/usr/bin/env bash
set -euo pipefail
cd ${LAB_TRAINING_ROOT:-/workspace/training}/${V_DIR:-perms-lab}
chmod a+x ${V_SCRIPTS:-scripts}/${V_SCRIPT:-run.sh}
chmod 600 ${V_PRIVATE:-private.txt}
mkdir -p ${V_DROPBOX:-dropbox}
chmod 775 ${V_DROPBOX:-dropbox}
printf '%s\n' "${V_TEXT:-permissions matter}" > ${V_DROPBOX:-dropbox}/${V_DBOX_README:-README.txt}
# alternativa (newline finale tollerato):  echo "${V_TEXT:-permissions matter}" > ${V_DROPBOX:-dropbox}/${V_DBOX_README:-README.txt}
lab check 02-permissions
