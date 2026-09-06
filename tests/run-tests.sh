#!/usr/bin/env bash
# Suite anti-auto-referenziale (PROMPTCORREZIONI P1-8).
# Chiama i check.sh DIRETTAMENTE (mai attraverso `lab check` come oracolo di se
# stessa) e valida anche i casi di fallimento, l'idempotenza delle soluzioni e
# il conteggio PASS/FAIL costante (scopre i check che escono a meta', P1-5).
set -uo pipefail

ROOT=/opt/assisted-labs
LABS_DIR="$ROOT/labs"
IDS="$(find "$LABS_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null | sort)"
[ -z "$IDS" ] && IDS="01-filesystem 02-permissions 03-users-groups 04-processes 05-text-processing 06-navigation-search 07-storage-archives 08-system-admin 09-network-transfer"
TRAINING="${LAB_TRAINING_ROOT:-/workspace/training}"

declare -i TESTS_OK=0 TESTS_BAD=0

step() { printf '\n\033[1;36m== %s ==\033[0m\n' "$1"; }
t_pass() { printf '  \033[1;32mPASS %s\033[0m\n' "$1"; TESTS_OK+=1; }
t_fail() { printf '  \033[1;31mFAIL %s\033[0m\n' "$1"; TESTS_BAD+=1; }

# Stampa l'output del check.sh di un lab e ne restituisce l'exit code.
run_check() {
  local out rc
  out="$(bash "$LABS_DIR/$1/check.sh" 2>&1)"
  rc=$?
  printf '%s' "$out"
  return "$rc"
}

count_pass() { printf '%s\n' "$1" | awk '/^  PASS  /{n++} END{print n+0}'; }
count_fail() { printf '%s\n' "$1" | awk '/^  FAIL  /{n++} END{print n+0}'; }
count_warn() { printf '%s\n' "$1" | grep -c 'AVVISO PERCORSO ERRATO' || true; }

# Ogni lab ha un "caso negativo mirato": uno stato sabotato che deve far
# fallire ALMENO un controllo.
sabotage() {
  local id="$1" base="$TRAINING"
  case "$id" in
    01-filesystem)        rm -f "$base/fs-lab/project/notes.txt" ;;
    02-permissions)       chmod 644 "$base/perms-lab/private.txt" ;;
    03-users-groups)      chmod 777 "$base/users-lab/team" ;;
    04-processes)         rm -f "$base/process-lab/status.txt" ;;
    05-text-processing)   printf '0\n' > "$base/text-lab/error_count.txt" ;;
    06-navigation-search) rm -f "$base/nav-lab/owner.txt" ;;
    07-storage-archives)  rm -f "$base/storage-lab/service-a.tar.gz" ;;
    08-system-admin)      rm -f "$base/admin-lab/top_snapshot.txt" ;;
    09-network-transfer)  rm -f "$base/net-lab/fetched_status.json" ;;
    10-file-comparison)   rm -f "$base/diff-lab/release_v2/app.conf" "$base/diff-lab/release_diff.txt" ;;
  esac
}

rev_ok() { printf '  %s\n\n' "$1"; }

for id in $IDS; do
  # 1. Reset => fallimento
  step "1/$id  reset -> check deve FALLIRE"
  lab reset "$id" >/dev/null 2>&1 || true
  outA="$(run_check "$id")"; rcA=$?
  aP=$(count_pass "$outA"); aF=$(count_fail "$outA"); aW=$(count_warn "$outA")
  if [ "$aW" -gt 0 ]; then
    t_fail "percorsi errati rilevati nello stato di reset (stato spurio)"
  elif [ "$rcA" -eq 0 ]; then
    t_fail "check PASSATO con lab appena azzerato (deve fallire)"
  elif [ "$aF" -lt 1 ]; then
    t_fail "nessun FAIL nello stato di reset"
  else
    t_pass "check fallisce come previsto (FAIL=$aF PASS=$aP)"
  fi
  rev_ok "$outA"

  # 2. Soluzione => successo, con idempotenza
  step "2/$id  solution (x2, idempotenza) -> check deve PASSARE"
  ok=1
  if ! bash "$ROOT/labs/$id/solution.sh" >/dev/null 2>&1; then
    t_fail "la soluzione termina con errore alla 1a esecuzione"
    ok=0
  else
    outB="$(run_check "$id")"; rcB=$?
    bP=$(count_pass "$outB"); bF=$(count_fail "$outB")
    if [ "$rcB" -ne 0 ] || [ "$bF" -gt 0 ]; then
      t_fail "check fallisce dopo la soluzione"
      rev_ok "$outB"
      ok=0
    fi
  fi
  if [ "$ok" -eq 1 ]; then
    if ! bash "$ROOT/labs/$id/solution.sh" >/dev/null 2>&1; then
      t_fail "la soluzione fallisce alla 2a esecuzione (idempotenza)"
      ok=0
    else
      outC="$(run_check "$id")"; rcC=$?
      if [ "$rcC" -ne 0 ] || [ "$(count_fail "$outC")" -gt 0 ]; then
        t_fail "idempotenza rotta: check fallisce dopo la 2a soluzione"
        rev_ok "$outC"
        ok=0
      fi
    fi
  fi
  [ "$ok" -eq 1 ] && t_pass "soluzione + idempotenza OK (PASS=$bP)"

  # 3. Caso negativo mirato
  step "3/$id  caso negativo mirato -> check deve FALLIRE"
  sabotage "$id"
  outD="$(run_check "$id")"; rcD=$?
  dP=$(count_pass "$outD"); dF=$(count_fail "$outD")
  if [ "$rcD" -eq 0 ]; then
    t_fail "il sabotaggio non e stato rilevato"
  else
    t_pass "sabotaggio rilevato (FAIL=$dF)"
  fi
  rev_ok "$outD"

  # 4. Conteggio PASS/FAIL costante tra il caso superato (soluzione) e quello
  #     fallito (sabotaggio): scopre i check che escono a meta' (P1-5).
  #     Uso lo stato di soluzione come riferimento perche' i check di sistema
  #     (03/04) mostrano legittimamente righe aggiuntive quando l'artefatto
  #     esiste. Nei lab condizionali il sabotaggio preserva l'artefatto.
  step "4/$id  conteggio PASS/FAIL costante (soluzione vs sabotaggio)"
  totB=$((bP + bF)); totD=$((dP + dF))
  if [ "$totB" -eq "$totD" ]; then
    t_pass "conteggio stabile ($totB righe sia in soluzione che in sabotaggio)"
  else
    t_fail "conteggio instabile: soluzione=$totB, sabotaggio=$totD (early-exit P1-5?)"
  fi
done

printf '\n\033[1;34m=== RIEPILOGO ===\033[0m\n'
printf '  PASS: %s   FAIL: %s\n' "$TESTS_OK" "$TESTS_BAD"
if [ "$TESTS_BAD" -gt 0 ]; then
  printf '\n\033[1;31mSUITE FALLITA\033[0m\n'
  exit 1
fi
printf '\n\033[1;32mSUITE SUPERATA (%s/%s lab)\033[0m\n' "$(printf '%s\n' $IDS | wc -l)" "$(printf '%s\n' $IDS | wc -l)"