#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
BASE=${LAB_TRAINING_ROOT:-/workspace/training}/perms-lab

printf 'check 02-permissions\n'

# 0. Controllo e ripristino percorsi errati comuni
warn_misplaced "/workspace/dropbox" "$BASE/dropbox"
warn_misplaced "${LAB_TRAINING_ROOT:-/workspace/training}/dropbox" "$BASE/dropbox"
warn_misplaced "/workspace/private.txt" "$BASE/private.txt"
warn_misplaced "${LAB_TRAINING_ROOT:-/workspace/training}/private.txt" "$BASE/private.txt"
warn_misplaced "/workspace/README.txt" "$BASE/dropbox/README.txt"
warn_misplaced "${LAB_TRAINING_ROOT:-/workspace/training}/README.txt" "$BASE/dropbox/README.txt"
warn_misplaced "$BASE/README.txt" "$BASE/dropbox/README.txt"

mode_of() { stat -c '%a' "$1" 2>/dev/null || echo ""; }

# 1. scripts/run.sh eseguibile per tutti
if [ -f "$BASE/scripts/run.sh" ]; then
  perms=$(mode_of "$BASE/scripts/run.sh")
  o=$((8#$perms))
  # owner x = 0100, group x = 010, other x = 01 (octal bits)
  if [ $((o & 0100)) -ne 0 ] && [ $((o & 010)) -ne 0 ] && [ $((o & 01)) -ne 0 ]; then
    pass "scripts/run.sh eseguibile u+g+o (mode $perms)"
  else
    miss "scripts/run.sh non eseguibile per owner/group/other" "punto 1: chmod a+x scripts/run.sh   (ora: $perms)" "stat -c '%a' scripts/run.sh"
  fi
else
  miss "manca scripts/run.sh" "lab corrotto? lab reset 02-permissions" "ls -l scripts/"
fi

# 2. private.txt mode 600
if [ -f "$BASE/private.txt" ] && [ "$(mode_of "$BASE/private.txt")" = "600" ]; then
  pass "private.txt mode 600"
else
  cur="assente"
  [ -f "$BASE/private.txt" ] && cur=$(mode_of "$BASE/private.txt")
  miss "private.txt non e 600 (ora: $cur)" "punto 2: chmod 600 private.txt" "stat -c '%a' private.txt"
fi

# 3. Cartella dropbox
if [ -d "$BASE/dropbox" ]; then
  pass "dropbox esiste"
else
  miss "manca dropbox" "punto 3: mkdir dropbox" "ls -d dropbox"
fi

# 4. dropbox mode 775
if [ -d "$BASE/dropbox" ] && [ "$(mode_of "$BASE/dropbox")" = "775" ]; then
  pass "dropbox mode 775"
else
  cur="n/a"
  [ -d "$BASE/dropbox" ] && cur=$(mode_of "$BASE/dropbox")
  miss "dropbox non e 775 (ora: $cur)" "punto 4: chmod 775 dropbox" "stat -c '%a' dropbox"
fi

# 5. Contenuto dropbox/README.txt
if [ -f "$BASE/dropbox/README.txt" ] && grep -qE '^[[:space:]]*permissions matter[[:space:]]*$' "$BASE/dropbox/README.txt"; then
  pass "dropbox/README.txt corretto"
else
  miss "dropbox/README.txt errato o assente" "punto 5: testo esatto = permissions matter (ok printf, echo o nano)" "cat dropbox/README.txt"
fi

[ "$fail" -eq 0 ]
