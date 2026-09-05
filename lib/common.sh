#!/usr/bin/env bash
# Assisted Linux Labs — helper condivisi per i check.sh.
# Importato con: source "$(dirname "$0")/../../lib/common.sh"
set -euo pipefail

fail=0
pass() { printf '  PASS  %s\n' "$1"; }

# miss "<problema>" "<comando correttivo X>" ["<verifica Y>"]
# 3° argomento opzionale = comando per verificare che il fix sia a posto.
miss() {
  printf '  FAIL  %s\n' "$1"
  [ "$#" -gt 1 ] && printf '        -> %s\n' "$2"
  [ "$#" -gt 2 ] && printf '        -> verifica: %s\n' "$3"
  fail=1
}

warn_misplaced() {
  local misplaced="$1"
  local expected="$2"
  if [ -e "$misplaced" ]; then
    printf '  [AVVISO PERCORSO ERRATO]\n'
    printf '  !! Risorsa creata nel posto sbagliato: %s\n' "$misplaced"
    printf '     Posizione attesa: %s\n' "$expected"
    printf '     -> Il check NON rimuove nulla. Rimuovila tu con il comando:\n'
    printf '        rm -rf -- %s\n' "$misplaced"
    printf '     -> Poi verifica con "pwd" di trovarti in: %s\n\n' "$BASE"
    fail=1
  fi
}
