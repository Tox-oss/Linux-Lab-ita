#!/usr/bin/env bash
# bash-completion per il comando `lab`.
# Completa i sottocomandi (list/start/check/...) e gli ID dei laboratori.
# Accetta anche gli alias numerici 1..9 per gli ID brevi (es. `lab start 0<TAB>`).
#
# Installazione: copiato in /etc/bash_completion.d/lab dentro l'immagine.

_lab_labs() {
  find /opt/assisted-labs/labs -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null | sort
}

_lab_ids_and_nums() {
  local cur="$1" labs nums
  labs=$(_lab_labs)
  nums=$(printf '%s\n' "$labs" | sed -n 's/^0*\([0-9][0-9]*\)-.*/\1/p' | sort -u)
  COMPREPLY=( $(compgen -W "$labs" -- "$cur") )
  COMPREPLY+=( $(compgen -W "$nums" -- "$cur") )
}

_lab_complete() {
  local cur prev
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  local subcmds="list start task check hint solution reset status mode doctor quit help readme anim class -h --hint --help"
  # sottocomandi che prendono un lab-id come secondo argomento
  local id_cmds="start task check hint solution reset status anim class -h --hint"

  # primo argomento: i sottocomandi
  if [ "$COMP_CWORD" -eq 1 ]; then
    COMPREPLY=( $(compgen -W "$subcmds" -- "$cur") )
    return
  fi

  # id lab (o alias numerico) per i sottocomandi che ne richiedono uno
  if [[ " $id_cmds " == *" ${COMP_WORDS[1]} "* ]] && [ "$COMP_CWORD" -eq 2 ]; then
    _lab_ids_and_nums "$cur"
    return
  fi

  # secondo argomento di `lab mode`: le modalita (+ forme brevi)
  if [ "${COMP_WORDS[1]}" = "mode" ] && [ "$COMP_CWORD" -eq 2 ]; then
    COMPREPLY=( $(compgen -W "standard arcade hardcade class std -a -s -hc" -- "$cur") )
    return
  fi
}

complete -o default -F _lab_complete lab
