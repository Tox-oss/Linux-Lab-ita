# Assisted Linux Labs — schermata di benvenuto (shell interattiva).
# Sourced da /etc/bash.bashrc e /etc/profile.d/

case $- in
  *i*) ;;
  *) return 0 ;;
esac

# Prompt personale: se l'identita' e' stata creata dall'intro (utente salvato
# sul volume), mostra NOME@container e il path, coerente con cio' che l'intro
# ha promesso ("il tuo prompt personale sara' NOME@container").
# E' settato PRIMA della guardia banner_shown cosi' vale anche dentro le shell
# che ereditano ASSISTED_LABS_BANNER_SHOWN (es. `su - nome` avviato dall'intro).
INTRO_NAME_FILE="${LAB_TRAINING_ROOT:-/workspace/training}/.intro-name"
CUR_USER=$(id -un 2>/dev/null || true)
SAVED_USER=""
[ -f "$INTRO_NAME_FILE" ] && SAVED_USER=$(cat "$INTRO_NAME_FILE" 2>/dev/null || true)
if [ -n "$SAVED_USER" ] && [ "$CUR_USER" = "$SAVED_USER" ]; then
  PS1='\[\033[1;32m\]'"$SAVED_USER"'@container\[\033[0m\]:\[\033[1;34m\]\w\[\033[0m\]\$ '
  export PS1
fi

if [ -n "${ASSISTED_LABS_BANNER_SHOWN:-}" ]; then
  return 0
fi
export ASSISTED_LABS_BANNER_SHOWN=1

# Se il cwd e' sparito (reset mentre eri dentro), torna su /workspace.
if ! pwd >/dev/null 2>&1; then
  cd /workspace 2>/dev/null || cd / || true
fi

# PATH di emergenza se qualcuno rompe l'ambiente.
if ! command -v lab >/dev/null 2>&1; then
  export PATH="/opt/assisted-labs/bin:/usr/local/bin:${PATH:-/usr/bin:/bin}"
fi

# Colori soft con fallback: usati solo se stdout e' un terminale.
if [ -t 1 ]; then
  C_GRN=$'\033[32m'
  C_CYN=$'\033[36m'
  C_YEL=$'\033[33m'
  C_DIM=$'\033[2m'
  C_BLD=$'\033[1m'
  C_RST=$'\033[0m'
else
  C_GRN=
  C_CYN=
  C_YEL=
  C_DIM=
  C_BLD=
  C_RST=
fi

# Intro "Primo Giorno" (primo accesso): chi sei, dove sei, perche' non root.
# Eseguita solo al primo accesso (stato salvato sul volume) e solo con
# terminale interattivo; idempotente e non bloccante in CI/pipe.
# Al primo run lo script cambia utente (`su - nome`); quando la shell del nuovo
# utente termina, l'intro esce con codice 42. In quel caso il box di benvenuto
# e' gia' stato mostrato dalla shell del nuovo utente (o cmq l'intro ha gia'
# accolto l'utente): lo saltiamo per non stamparlo due volte.
if [ -t 0 ] && [ -t 1 ] \
   && [ -z "${SKIP_INTRO:-}" ] \
   && [ -f /opt/assisted-labs/bin/intro.sh ] \
   && [ ! -f "${LAB_TRAINING_ROOT:-/workspace/training}/.intro-done" ]; then
  bash /opt/assisted-labs/bin/intro.sh
  rc=$?
  if [ "$rc" -eq 42 ]; then
    ASSISTED_LABS_NO_BOX=1
  fi
fi

# Rientro automatico nell'identita' personale (dalla SECONDA sessione in poi).
# L'intro non riparte (.intro-done vive sul volume) ma l'account Linux e' stato
# ricreato dall'entrypoint leggendo .intro-name: senza questo blocco la shell
# resterebbe root, contraddicendo la promessa dell'intro ("da ora sei NOME").
# Guardie: solo con TTY, solo da root, solo se l'account esiste davvero.
# Vie di fuga: ASSISTED_LABS_NO_AUTOSU=1 (resta root) oppure SKIP_INTRO=1.
if [ -z "${ASSISTED_LABS_NO_BOX:-}" ]    && [ -t 0 ] && [ -t 1 ]    && [ -z "${ASSISTED_LABS_NO_AUTOSU:-}" ]    && [ -z "${SKIP_INTRO:-}" ]    && [ "$CUR_USER" = "root" ]    && [ -n "$SAVED_USER" ]    && id "$SAVED_USER" >/dev/null 2>&1; then
  printf '
[32m%s[0m

' "=== Bentornato, ${SAVED_USER}: rientro nella tua identita' ==="
  su - "$SAVED_USER"
  ASSISTED_LABS_NO_BOX=1
fi

# Larghezza interna del box (celle tra i due bordi verticali).
# Momo: i caratteri di disegno box si usano solo se il terminale li
# supporta; altrimenti si ripiega su un box ASCII (+, -, |) che si
# renderizza ovunque (anche su encoding legacy tipo CP437).
W=44
# Sostituti del box: i caratteri Unicode di disegno box (U+2550..U+2573)
# non vengono renderizzati da alcuni terminali/encoding (appaiono come "�")
# ANCHE quando la locale dichiara UTF-8. L'ASCII puro (+, -, |) si renderizza
# invece sempre correttamente: e' quindi il default.
# Per riattivare il box Unicode forzare: ASSISTED_LABS_BANNER_ASCII=0
if [ "${ASSISTED_LABS_BANNER_ASCII:-1}" = "1" ]; then
  # Box ASCII puro: sempre sicuro, nessun terminale lo sbaglia.
  TL='+'; HB='-'; TR='+'; VB='|'; BL='+'; BR='+'
else
  # Box Unicode (solo per terminali che lo renderizzano correttamente).
  TL='╔'; HB='═'; TR='╗'; VB='║'; BL='╚'; BR='╝'
fi
top()   { printf '%s'   "${C_GRN}${TL}"; printf '%*s' "$W" "" | tr ' ' "$HB"; printf '%s\n' "${TR}${C_RST}"; }
# vlen: lunghezza VISIBILE del testo (ignora i codici colore ANSI).
vlen()  { printf '%s' "$1" | sed -e "s/$(printf '\033')\[[0-9;]*m//g" | wc -m; }
# mid: centra il testo dentro il box (W celle, meno 2 per i bordi di testo).
mid()   { local t="$1" n left right; n=$(vlen "$t"); left=$(( (W - n) / 2 )); [ "$left" -lt 0 ] && left=0; right=$(( W - n - left )); printf '%s' "${C_GRN}${VB}"; printf '%*s' "$left" ""; printf '%s%*s' "$t" "$right" ""; printf '%s\n' "${VB}${C_RST}"; }
bottom(){ printf '%s'   "${C_GRN}${BL}"; printf '%*s' "$W" "" | tr ' ' "$HB"; printf '%s\n' "${BR}${C_RST}"; }

if [ -n "${ASSISTED_LABS_NO_BOX:-}" ]; then
  printf '%s\n' ''
  printf '%s\n' "${C_DIM}Hai chiuso la shell di ${C_BLD}$(cat "$INTRO_NAME_FILE" 2>/dev/null || echo 'il tuo utente')${C_RST}${C_DIM}. Sei tornato a ${C_BLD}root${C_RST}${C_DIM}: usa ${C_BLD}su - nome${C_RST}${C_DIM} per rientrare o ${C_BLD}exit${C_RST}${C_DIM} per chiudere.${C_RST}"
  printf '%s\n' ''
  return 0
fi

top
mid "${C_BLD}Assisted Linux Labs${C_RST}"
mid "${C_YEL}il tuo laboratorio Linux, pronto per te.${C_RST}"
bottom

printf '%s\n' ''
printf '%s\n' "${C_YEL}Sei in una sandbox sicura: sperimenta senza timore.${C_RST}"
printf '%s\n' ''
printf '  %s%-14s%s %s\n' "${C_CYN}" "lab list"      "${C_RST}" "cosa posso fare qui"
printf '  %s%-14s%s %s\n' "${C_CYN}" "lab start <id>" "${C_RST}" "parti il primo esercizio"
printf '  %s%-14s%s %s\n' "${C_CYN}" "lab check <id>" "${C_RST}" "verifica il lavoro  [non cancella nulla]"
printf '  %s%-14s%s %s\n' "${C_CYN}" "lab hint  <id>" "${C_RST}" "un indizio se ti blocchi"
printf '  %s%-14s%s %s\n' "${C_CYN}" "lab mode"       "${C_RST}" "scegli la modalita: standard · arcade · class"
printf '  %s%-14s%s %s\n' "${C_CYN}" "lab mode class" "${C_RST}" "le lezioni di tutti i lab, in ordine"
printf '  %s%-14s%s %s\n' "${C_CYN}" "lab help"       "${C_RST}" "tutti i comandi e le regole"
printf '%s\n' ''
printf '  %s%s%s   %s%s%s\n' "${C_DIM}" "Prima cosa da fare:" "${C_RST}" "${C_BLD}" "lab list" "${C_RST}"
printf '%s\n' ''
