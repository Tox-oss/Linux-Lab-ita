#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
BASE=${LAB_TRAINING_ROOT:-/workspace/training}/users-lab

printf 'check 03-users-groups\n'

# 0. Controllo e ripristino percorsi errati comuni
warn_misplaced "/workspace/team" "$BASE/team"
warn_misplaced "${LAB_TRAINING_ROOT:-/workspace/training}/team" "$BASE/team"
warn_misplaced "/home/learner/team" "$BASE/team"

# 1. Gruppo devops
if getent group devops >/dev/null; then
  pass "gruppo devops esiste"
else
  miss "manca gruppo devops" "punto 1: groupadd devops" "getent group devops"
fi

# 2. Utente learner con home e shell /bin/bash
if id learner >/dev/null 2>&1; then
  pass "utente learner esiste"
  if [ -d "/home/learner" ]; then
    pass "home /home/learner presente (-m)"
  else
    miss "manca /home/learner" "punto 2: crea utente con flag -m (useradd -m -s /bin/bash learner)" "ls -d /home/learner"
  fi
  
  learner_shell=$(getent passwd learner 2>/dev/null | cut -d: -f7 || echo "")
  if [ "$learner_shell" = "/bin/bash" ]; then
    pass "shell learner = /bin/bash"
  else
    miss "shell learner errata (ora: $learner_shell)" "punto 2: -s /bin/bash" "getent passwd learner | cut -d: -f7"
  fi
else
  miss "manca utente learner" "punto 2: useradd -m -s /bin/bash learner" "id learner"
fi

# 3. learner nel gruppo devops (append -aG)
if id -nG learner 2>/dev/null | tr ' ' '\n' | grep -qx devops; then
  pass "learner nel gruppo devops"
else
  miss "learner non in devops" "punto 3: usermod -aG devops learner" "id -nG learner"
fi

# 4. Directory team
if [ -d "$BASE/team" ]; then
  pass "directory team esiste"
else
  miss "manca team/" "punto 4: mkdir team" "ls -d team"
fi

# 5. Ownership team: learner:devops
if [ -d "$BASE/team" ] && [ "$(stat -c '%U:%G' "$BASE/team" 2>/dev/null)" = "learner:devops" ]; then
  pass "team owner = learner:devops"
else
  cur="n/a"
  [ -d "$BASE/team" ] && cur=$(stat -c '%U:%G' "$BASE/team" 2>/dev/null || echo "n/a")
  miss "owner team errato (ora: $cur)" "punto 5: chown learner:devops team" "stat -c '%U:%G' team"
fi

# 6. Permessi team: 770
if [ -d "$BASE/team" ] && [ "$(stat -c '%a' "$BASE/team" 2>/dev/null)" = "770" ]; then
  pass "team mode 770"
else
  cur="n/a"
  [ -d "$BASE/team" ] && cur=$(stat -c '%a' "$BASE/team" 2>/dev/null || echo "n/a")
  miss "team non e 770 (ora: $cur)" "punto 6: chmod 770 team" "stat -c '%a' team"
fi

[ "$fail" -eq 0 ]
