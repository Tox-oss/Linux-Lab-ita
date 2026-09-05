#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
BASE=${LAB_TRAINING_ROOT:-/workspace/training}/fs-lab

printf 'check 01-filesystem\n'

# 0. Controllo e ripristino percorsi errati comuni
warn_misplaced "/workspace/project" "$BASE/project"
warn_misplaced "/workspace/docs" "$BASE/project/docs"
warn_misplaced "${LAB_TRAINING_ROOT:-/workspace/training}/project" "$BASE/project"
warn_misplaced "${LAB_TRAINING_ROOT:-/workspace/training}/docs" "$BASE/project/docs"
warn_misplaced "$BASE/docs" "$BASE/project/docs"
warn_misplaced "$BASE/notes.txt" "$BASE/project/notes.txt"
warn_misplaced "$BASE/data.backup" "$BASE/project/docs/data.backup"
warn_misplaced "$BASE/project/data.backup" "$BASE/project/docs/data.backup"
if [ -f "$BASE/data.txt" ] && [ ! -f "$BASE/project/data.txt" ]; then
  warn_misplaced "$BASE/data.txt" "$BASE/project/data.txt"
fi

# 1. Directory project/docs
if [ -d "$BASE/project/docs" ]; then
  pass "project/docs esiste"
else
  miss "manca project/docs" "punto 1: mkdir -p project/docs" "ls -d project/docs"
fi

# 2. File notes.txt con testo richiesto (tollerante a newline e spazi)
if [ -f "$BASE/project/notes.txt" ] && grep -qE '^[[:space:]]*filesystem lab[[:space:]]*$' "$BASE/project/notes.txt"; then
  pass "notes.txt = 'filesystem lab'"
else
  miss "notes.txt errato o assente" "punto 2: testo esatto = filesystem lab (ok printf, echo o nano)" "cat project/notes.txt"
fi

# 3. Spostamento inbox/raw.txt -> project/data.txt
if [ -f "$BASE/project/data.txt" ]; then
  pass "project/data.txt presente"
else
  miss "manca project/data.txt" "punto 3: mv inbox/raw.txt project/data.txt" "ls -l project/data.txt"
fi

if [ ! -f "$BASE/inbox/raw.txt" ]; then
  pass "inbox/raw.txt rimosso (move, non copy)"
else
  miss "inbox/raw.txt c'e ancora" "punto 3: sposta con mv, non copiare" "ls inbox/raw.txt"
fi

# 4. Copia di backup identica
if [ -f "$BASE/project/docs/data.backup" ] && [ -f "$BASE/project/data.txt" ] && cmp -s "$BASE/project/data.txt" "$BASE/project/docs/data.backup"; then
  pass "docs/data.backup identico a data.txt"
else
  miss "backup assente o diverso" "punto 4: cp project/data.txt project/docs/data.backup" "cmp project/data.txt project/docs/data.backup"
fi

# 5. Rimozione file temporaneo
if [ ! -f "$BASE/temp.tmp" ]; then
  pass "temp.tmp eliminato"
else
  miss "temp.tmp ancora presente" "punto 5: rm temp.tmp" "ls temp.tmp"
fi

[ "$fail" -eq 0 ]
