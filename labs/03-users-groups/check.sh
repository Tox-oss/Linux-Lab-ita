#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
BASE=${LAB_TRAINING_ROOT:-/workspace/training}/${V_DIR:-users-lab}

printf 'check 03-users-groups\n'

# 0. Controllo e ripristino percorsi errati comuni
warn_misplaced "/workspace/${V_TEAM:-team}" "$BASE/${V_TEAM:-team}"
warn_misplaced "${LAB_TRAINING_ROOT:-/workspace/training}/${V_TEAM:-team}" "$BASE/${V_TEAM:-team}"
warn_misplaced "/home/${V_USER:-learner}/${V_TEAM:-team}" "$BASE/${V_TEAM:-team}"

# 1. Gruppo devops
if getent group ${V_GROUP:-devops} >/dev/null; then
  pass "gruppo ${V_GROUP:-devops} esiste"
else
  miss "manca gruppo ${V_GROUP:-devops}" "punto 1: groupadd ${V_GROUP:-devops}" "getent group ${V_GROUP:-devops}"
fi

# 2. Utente learner con home e shell /bin/bash
if id ${V_USER:-learner} >/dev/null 2>&1; then
  pass "utente ${V_USER:-learner} esiste"
  if [ -d "/home/${V_USER:-learner}" ]; then
    pass "home /home/${V_USER:-learner} presente (-m)"
  else
    miss "manca /home/${V_USER:-learner}" "punto 2: crea utente con flag -m (useradd -m -s /bin/bash ${V_USER:-learner})" "ls -d /home/${V_USER:-learner}"
  fi
  
  learner_shell=$(getent passwd ${V_USER:-learner} 2>/dev/null | cut -d: -f7 || echo "")
  if [ "$learner_shell" = "/bin/bash" ]; then
    pass "shell ${V_USER:-learner} = /bin/bash"
  else
    miss "shell ${V_USER:-learner} errata (ora: $learner_shell)" "punto 2: -s /bin/bash" "getent passwd ${V_USER:-learner} | cut -d: -f7"
  fi
else
  miss "manca utente ${V_USER:-learner}" "punto 2: useradd -m -s /bin/bash ${V_USER:-learner}" "id ${V_USER:-learner}"
fi

# 3. learner nel gruppo devops (append -aG)
if id -nG ${V_USER:-learner} 2>/dev/null | tr ' ' '\n' | grep -qx ${V_GROUP:-devops}; then
  pass "${V_USER:-learner} nel gruppo ${V_GROUP:-devops}"
else
  miss "${V_USER:-learner} non in ${V_GROUP:-devops}" "punto 3: usermod -aG ${V_GROUP:-devops} ${V_USER:-learner}" "id -nG ${V_USER:-learner}"
fi

# 4. Directory team
if [ -d "$BASE/${V_TEAM:-team}" ]; then
  pass "directory ${V_TEAM:-team} esiste"
else
  miss "manca ${V_TEAM:-team}/" "punto 4: mkdir ${V_TEAM:-team}" "ls -d ${V_TEAM:-team}"
fi

# 5. Ownership team: learner:devops
if [ -d "$BASE/${V_TEAM:-team}" ] && [ "$(stat -c '%U:%G' "$BASE/${V_TEAM:-team}" 2>/dev/null)" = "${V_USER:-learner}:${V_GROUP:-devops}" ]; then
  pass "team owner = ${V_USER:-learner}:${V_GROUP:-devops}"
else
  cur="n/a"
  [ -d "$BASE/${V_TEAM:-team}" ] && cur=$(stat -c '%U:%G' "$BASE/${V_TEAM:-team}" 2>/dev/null || echo "n/a")
  miss "owner team errato (ora: $cur)" "punto 5: chown ${V_USER:-learner}:${V_GROUP:-devops} ${V_TEAM:-team}" "stat -c '%U:%G' ${V_TEAM:-team}"
fi

# 6. Permessi team: 770
if [ -d "$BASE/${V_TEAM:-team}" ] && [ "$(stat -c '%a' "$BASE/${V_TEAM:-team}" 2>/dev/null)" = "${V_TEAM_MODE:-770}" ]; then
  pass "team mode ${V_TEAM_MODE:-770}"
else
  cur="n/a"
  [ -d "$BASE/${V_TEAM:-team}" ] && cur=$(stat -c '%a' "$BASE/${V_TEAM:-team}" 2>/dev/null || echo "n/a")
  miss "team non e' ${V_TEAM_MODE:-770} (ora: $cur)" "punto 6: chmod ${V_TEAM_MODE:-770} ${V_TEAM:-team}" "stat -c '%a' ${V_TEAM:-team}"
fi

[ "$fail" -eq 0 ]
