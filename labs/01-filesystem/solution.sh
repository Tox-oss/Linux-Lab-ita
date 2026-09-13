#!/usr/bin/env bash
# Soluzione di riferimento — leggila, poi digita tu i comandi.
set -euo pipefail
cd ${LAB_TRAINING_ROOT:-/workspace/training}/${V_DIR:-fs-lab}
mkdir -p ${V_MAIN:-project}/${V_DOCS:-docs}
printf '%s\n' "${V_TEXT:-filesystem lab}" > ${V_MAIN:-project}/${V_NOTES:-notes.txt}
# alternativa (newline finale tollerato):  echo 'regex' > project/notes.txt
if [ -f ${V_INBOX:-inbox}/${V_RAW:-raw.txt} ]; then mv ${V_INBOX:-inbox}/${V_RAW:-raw.txt} ${V_MAIN:-project}/${V_DATA:-data.txt}; fi
cp ${V_MAIN:-project}/${V_DATA:-data.txt} ${V_MAIN:-project}/${V_DOCS:-docs}/${V_BACKUP:-data.backup}
if [ -f ${V_TEMP:-temp.tmp} ]; then rm ${V_TEMP:-temp.tmp}; fi
lab check 01-filesystem
