#!/usr/bin/env bash
# Soluzione di riferimento — leggila, poi digita tu i comandi.
set -euo pipefail
cd ${LAB_TRAINING_ROOT:-/workspace/training}/fs-lab
mkdir -p project/docs
printf 'filesystem lab\n' > project/notes.txt
# alternativa (newline finale tollerato):  echo 'filesystem lab' > project/notes.txt
if [ -f inbox/raw.txt ]; then mv inbox/raw.txt project/data.txt; fi
cp project/data.txt project/docs/data.backup
if [ -f temp.tmp ]; then rm temp.tmp; fi
lab check 01-filesystem
