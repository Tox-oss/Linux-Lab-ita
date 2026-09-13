#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
BASE=${LAB_TRAINING_ROOT:-/workspace/training}/${V_DIR:-fs-lab}

printf 'check 01-filesystem\n'

# 0. Controllo e ripristino percorsi errati comuni
warn_misplaced "/workspace/${V_MAIN:-project}" "$BASE/${V_MAIN:-project}"
warn_misplaced "/workspace/${V_DOCS:-docs}" "$BASE/${V_MAIN:-project}/${V_DOCS:-docs}"
warn_misplaced "${LAB_TRAINING_ROOT:-/workspace/training}/${V_MAIN:-project}" "$BASE/${V_MAIN:-project}"
warn_misplaced "${LAB_TRAINING_ROOT:-/workspace/training}/${V_DOCS:-docs}" "$BASE/${V_MAIN:-project}/${V_DOCS:-docs}"
warn_misplaced "$BASE/${V_DOCS:-docs}" "$BASE/${V_MAIN:-project}/${V_DOCS:-docs}"
warn_misplaced "$BASE/${V_NOTES:-notes.txt}" "$BASE/${V_MAIN:-project}/${V_NOTES:-notes.txt}"
warn_misplaced "$BASE/${V_BACKUP:-data.backup}" "$BASE/${V_MAIN:-project}/${V_DOCS:-docs}/${V_BACKUP:-data.backup}"
warn_misplaced "$BASE/${V_MAIN:-project}/${V_BACKUP:-data.backup}" "$BASE/${V_MAIN:-project}/${V_DOCS:-docs}/${V_BACKUP:-data.backup}"
if [ -f "$BASE/${V_DATA:-data.txt}" ] && [ ! -f "$BASE/${V_MAIN:-project}/${V_DATA:-data.txt}" ]; then
  warn_misplaced "$BASE/${V_DATA:-data.txt}" "$BASE/${V_MAIN:-project}/${V_DATA:-data.txt}"
fi

# 1. Directory project/docs
if [ -d "$BASE/${V_MAIN:-project}/${V_DOCS:-docs}" ]; then
  pass "${V_DOCS:-docs} esiste"
else
  miss "manca ${V_MAIN:-project}/${V_DOCS:-docs}" "punto 1: mkdir -p ${V_MAIN:-project}/${V_DOCS:-docs}" "ls -d ${V_MAIN:-project}/${V_DOCS:-docs}"
fi

# 2. File notes.txt con testo richiesto (tollerante a newline e spazi)
if [ -f "$BASE/${V_MAIN:-project}/${V_NOTES:-notes.txt}" ] && grep -qE "^[[:space:]]*${V_TEXT:-filesystem lab}[[:space:]]*$" "$BASE/${V_MAIN:-project}/${V_NOTES:-notes.txt}"; then
  pass "${V_NOTES:-notes.txt} = '${V_TEXT:-filesystem lab}'"
else
  miss "${V_NOTES:-notes.txt} errato o assente" "punto 2: testo esatto = ${V_TEXT:-filesystem lab} (ok printf, echo o nano)" "cat ${V_MAIN:-project}/${V_NOTES:-notes.txt}"
fi

# 3. Spostamento inbox/raw.txt -> project/data.txt
if [ -f "$BASE/${V_MAIN:-project}/${V_DATA:-data.txt}" ]; then
  pass "${V_MAIN:-project}/${V_DATA:-data.txt} presente"
else
  miss "manca ${V_MAIN:-project}/${V_DATA:-data.txt}" "punto 3: mv ${V_INBOX:-inbox}/${V_RAW:-raw.txt} ${V_MAIN:-project}/${V_DATA:-data.txt}" "ls -l ${V_MAIN:-project}/${V_DATA:-data.txt}"
fi

if [ ! -f "$BASE/${V_INBOX:-inbox}/${V_RAW:-raw.txt}" ]; then
  pass "${V_INBOX:-inbox}/${V_RAW:-raw.txt} rimosso (move, non copy)"
else
  miss "${V_INBOX:-inbox}/${V_RAW:-raw.txt} c'e ancora" "punto 3: sposta con mv, non copiare" "ls ${V_INBOX:-inbox}/${V_RAW:-raw.txt}"
fi

# 4. Copia di backup identica
if [ -f "$BASE/${V_MAIN:-project}/${V_DOCS:-docs}/${V_BACKUP:-data.backup}" ] && [ -f "$BASE/${V_MAIN:-project}/${V_DATA:-data.txt}" ] && cmp -s "$BASE/${V_MAIN:-project}/${V_DATA:-data.txt}" "$BASE/${V_MAIN:-project}/${V_DOCS:-docs}/${V_BACKUP:-data.backup}"; then
  pass "${V_DOCS:-docs}/${V_BACKUP:-data.backup} identico a ${V_DATA:-data.txt}"
else
  miss "backup assente o diverso" "punto 4: cp ${V_MAIN:-project}/${V_DATA:-data.txt} ${V_MAIN:-project}/${V_DOCS:-docs}/${V_BACKUP:-data.backup}" "cmp ${V_MAIN:-project}/${V_DATA:-data.txt} ${V_MAIN:-project}/${V_DOCS:-docs}/${V_BACKUP:-data.backup}"
fi

# 5. Rimozione file temporaneo
if [ ! -f "$BASE/${V_TEMP:-temp.tmp}" ]; then
  pass "${V_TEMP:-temp.tmp} eliminato"
else
  miss "${V_TEMP:-temp.tmp} ancora presente" "punto 5: rm ${V_TEMP:-temp.tmp}" "ls ${V_TEMP:-temp.tmp}"
fi

[ "$fail" -eq 0 ]
