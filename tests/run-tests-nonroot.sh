#!/usr/bin/env bash
# run-tests-nonroot.sh — suite "utente normale" (copre il punto cieco da non-root).
# tests/run-tests.sh gira da ROOT: intercetta i lab che toccano il sistema
# (03 users-groups, 08 system-admin) SOLO se si eseguono da amministratore.
# Dalla ver 0026, dopo l'intro lo studente lavora come UTENTE (password di
# prova <nome>pass), quindi il percorso da utente normale va validato davvero.
#
# Questo smoke crea un utente di prova (wheel + password, come fa l'intro),
# gli affida /workspace/training (come fa l'intro con chown) e rifa i due lab
# critici esattamente come un principiante: comandi con 'sudo' e password
# fornita via 'sudo -S' (stesso flusso del primo sudo con la password).
#
# Uso (DENTRO il container, come root, con l'immagine vigente):
#   LAB_QA_MODE=1 bash /opt/assisted-labs/tests/run-tests-nonroot.sh
#
# NON usare su un volume studente reale: qui il training viene ripulito e
# affidato all'utente di prova (come farebbe l'intro al primo accesso).
set -uo pipefail

ROOT=/opt/assisted-labs
TRAINING=/workspace/training

STUDENT="student-wr"          # come NOME dell'intro (solo minuscole/lettere)
STUDENT_PASS="${STUDENT}pass" # la "password di prova" che l'intro insegna

# PATH uguale a /etc/profile (include /sbin:/usr/sbin per openrc), come lo ha
# lo studente reale dopo 'su - NOME' dell'intro.
STUDENT_ENV="HOME=/home/$STUDENT PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin LAB_QA_MODE=${LAB_QA_MODE:-1} LAB_TRAINING_ROOT=$TRAINING"

declare -i OK=0 BAD=0

step() { printf '\n\033[1;36m== %s ==\033[0m\n' "$1"; }
pass() { printf '  \033[1;32mPASS %s\033[0m\n' "$1"; OK+=1; }
fail() { printf '  \033[1;31mFAIL %s\033[0m\n' "$1"; BAD+=1; }

# std: comando semplice come utente normale.
std()  { su -s /bin/bash -c "export $STUDENT_ENV; $1" "$STUDENT"; }
# std_sudo: comando con sudo come utente normale, password della prova via -S.
std_sudo() { printf '%s\n' "$STUDENT_PASS" | su -s /bin/bash -c "export $STUDENT_ENV; sudo -S bash -c '$1'" "$STUDENT" 2>/dev/null; }

step "Preparazione: utente $STUDENT (wheel + password) e $TRAINING a lui affidato"
if id "$STUDENT" >/dev/null 2>&1; then
  userdel -r "$STUDENT" >/dev/null 2>&1 || true
fi
useradd -m -s /bin/bash "$STUDENT" || true
addgroup "$STUDENT" wheel >/dev/null 2>&1 || usermod -aG wheel "$STUDENT" || true
printf '%s:%s\n' "$STUDENT" "$STUDENT_PASS" | chpasswd || true
# Come l'intro: il training diventa dell'utente (per .lab-state e i WDIR).
rm -rf "$TRAINING"
mkdir -p "$TRAINING"
chown -R "$STUDENT:$STUDENT" "$TRAINING"
pass "ambiente non-root pronto"

step "LAB 03 users-groups — percorso da utente normale"
if std "lab start 03-users-groups >/dev/null 2>&1" \
   && std "cd $TRAINING/users-lab && mkdir -p team" \
   && std_sudo "cd $TRAINING/users-lab && groupadd devops && useradd -m -s /bin/bash learner && usermod -aG devops learner && chown learner:devops team && chmod 770 team" \
   && std "cd $TRAINING/users-lab && lab check 03-users-groups >/dev/null 2>&1"; then
  pass "lab 03 da utente normale OK (gruppo/utente/owner tramite sudo)"
else
  fail "lab 03 da utente normale — uno dei passi non root e' fallito"
fi

step "LAB 08 system-admin — percorso da utente normale"
if std "lab start 08-system-admin >/dev/null 2>&1" \
   && std "cd $TRAINING/admin-lab && top -b -n 1 > top_snapshot.txt && free -h > memory_report.txt && openrc --version | head -n 1 > openrc_version.txt && grep -F assisted-lab /var/log/messages > syslog_snapshot.txt || true" \
   && std_sudo "cd $TRAINING/admin-lab && sudo -u auditor whoami > sudo_user.txt" \
   && std_sudo "cd $TRAINING/admin-lab && crontab nightly.cron && crontab -l > installed_cron.txt" \
   && std "cd $TRAINING/admin-lab && lab check 08-system-admin >/dev/null 2>&1"; then
  pass "lab 08 da utente normale OK (snapshot, syslog, sudo -u auditor, crontab)"
else
  fail "lab 08 da utente normale — uno dei passi non root e' fallito"
fi

printf '\n\033[1;36m== RIEPILOGO (non-root) ==\033[0m\nPASS %d / FAIL %d\n' "$OK" "$BAD"
[ "$BAD" -eq 0 ]