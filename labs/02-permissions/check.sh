#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
BASE=${LAB_TRAINING_ROOT:-/workspace/training}/${V_DIR:-perms-lab}

printf 'check 02-permissions\n'

# 0. Controllo e ripristino percorsi errati comuni
warn_misplaced "/workspace/${V_DROPBOX:-dropbox}" "$BASE/${V_DROPBOX:-dropbox}"
warn_misplaced "${LAB_TRAINING_ROOT:-/workspace/training}/${V_DROPBOX:-dropbox}" "$BASE/${V_DROPBOX:-dropbox}"
warn_misplaced "/workspace/${V_PRIVATE:-private.txt}" "$BASE/${V_PRIVATE:-private.txt}"
warn_misplaced "${LAB_TRAINING_ROOT:-/workspace/training}/${V_PRIVATE:-private.txt}" "$BASE/${V_PRIVATE:-private.txt}"
warn_misplaced "/workspace/${V_DBOX_README:-README.txt}" "$BASE/${V_DROPBOX:-dropbox}/${V_DBOX_README:-README.txt}"
warn_misplaced "${LAB_TRAINING_ROOT:-/workspace/training}/${V_DBOX_README:-README.txt}" "$BASE/${V_DROPBOX:-dropbox}/${V_DBOX_README:-README.txt}"
warn_misplaced "$BASE/${V_DBOX_README:-README.txt}" "$BASE/${V_DROPBOX:-dropbox}/${V_DBOX_README:-README.txt}"

mode_of() { stat -c '%a' "$1" 2>/dev/null || echo ""; }

# 1. ${V_SCRIPTS:-scripts}/${V_SCRIPT:-run.sh} eseguibile per tutti
if [ -f "$BASE/${V_SCRIPTS:-scripts}/${V_SCRIPT:-run.sh}" ]; then
  perms=$(mode_of "$BASE/${V_SCRIPTS:-scripts}/${V_SCRIPT:-run.sh}")
  o=$((8#$perms))
  # owner x = 0100, group x = 010, other x = 01 (octal bits)
  if [ $((o & 0100)) -ne 0 ] && [ $((o & 010)) -ne 0 ] && [ $((o & 01)) -ne 0 ]; then
    pass "${V_SCRIPTS:-scripts}/${V_SCRIPT:-run.sh} eseguibile u+g+o (mode $perms)"
  else
    miss "${V_SCRIPTS:-scripts}/${V_SCRIPT:-run.sh} non eseguibile per owner/group/other" "punto 1: chmod a+x ${V_SCRIPTS:-scripts}/${V_SCRIPT:-run.sh}   (ora: $perms)" "stat -c '%a' ${V_SCRIPTS:-scripts}/${V_SCRIPT:-run.sh}"
  fi
else
  miss "manca ${V_SCRIPTS:-scripts}/${V_SCRIPT:-run.sh}" "lab corrotto? lab reset 02-permissions" "ls -l ${V_SCRIPTS:-scripts}/"
fi

# 2. ${V_PRIVATE:-private.txt} mode 600
if [ -f "$BASE/${V_PRIVATE:-private.txt}" ] && [ "$(mode_of "$BASE/${V_PRIVATE:-private.txt}")" = "600" ]; then
  pass "${V_PRIVATE:-private.txt} mode 600"
else
  cur="assente"
  [ -f "$BASE/${V_PRIVATE:-private.txt}" ] && cur=$(mode_of "$BASE/${V_PRIVATE:-private.txt}")
  miss "${V_PRIVATE:-private.txt} non e' 600 (ora: $cur)" "punto 2: chmod 600 ${V_PRIVATE:-private.txt}" "stat -c '%a' ${V_PRIVATE:-private.txt}"
fi

# 3. Cartella ${V_DROPBOX:-dropbox}
if [ -d "$BASE/${V_DROPBOX:-dropbox}" ]; then
  pass "${V_DROPBOX:-dropbox} esiste"
else
  miss "manca ${V_DROPBOX:-dropbox}" "punto 3: mkdir ${V_DROPBOX:-dropbox}" "ls -d ${V_DROPBOX:-dropbox}"
fi

# 4. ${V_DROPBOX:-dropbox} mode 775
if [ -d "$BASE/${V_DROPBOX:-dropbox}" ] && [ "$(mode_of "$BASE/${V_DROPBOX:-dropbox}")" = "775" ]; then
  pass "${V_DROPBOX:-dropbox} mode 775"
else
  cur="n/a"
  [ -d "$BASE/${V_DROPBOX:-dropbox}" ] && cur=$(mode_of "$BASE/${V_DROPBOX:-dropbox}")
  miss "${V_DROPBOX:-dropbox} non e' 775 (ora: $cur)" "punto 4: chmod 775 ${V_DROPBOX:-dropbox}" "stat -c '%a' ${V_DROPBOX:-dropbox}"
fi

# 5. Contenuto ${V_DROPBOX:-dropbox}/${V_DBOX_README:-README.txt}
if [ -f "$BASE/${V_DROPBOX:-dropbox}/${V_DBOX_README:-README.txt}" ] && grep -qE "^[[:space:]]*${V_TEXT:-permissions matter}[[:space:]]*$" "$BASE/${V_DROPBOX:-dropbox}/${V_DBOX_README:-README.txt}"; then
  pass "${V_DROPBOX:-dropbox}/${V_DBOX_README:-README.txt} corretto"
else
  miss "${V_DROPBOX:-dropbox}/${V_DBOX_README:-README.txt} errato o assente" "punto 5: testo esatto = ${V_TEXT:-permissions matter} (ok printf, echo o nano)" "cat ${V_DROPBOX:-dropbox}/${V_DBOX_README:-README.txt}"
fi

[ "$fail" -eq 0 ]
