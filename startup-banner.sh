# Assisted Linux Labs — schermata di benvenuto (shell interattiva).
# Sourced da /etc/bash.bashrc e /etc/profile.d/

case $- in
  *i*) ;;
  *) return 0 ;;
esac

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
  C_DIM=$'\033[2m'
  C_BLD=$'\033[1m'
  C_RST=$'\033[0m'
else
  C_GRN=
  C_CYN=
  C_DIM=
  C_BLD=
  C_RST=
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

top
mid "${C_BLD}Assisted Linux Labs${C_RST}"
mid "il tuo laboratorio Linux, pronto per te."
bottom

printf '%s\n' ''
printf '%s\n' "${C_DIM}Sei in una sandbox sicura: sperimenta senza timore.${C_RST}"
printf '%s\n' ''
printf '  %s%-14s%s %s\n' "${C_CYN}" "lab list"      "${C_RST}" "cosa posso fare qui"
printf '  %s%-14s%s %s\n' "${C_CYN}" "lab start <id>" "${C_RST}" "parti il primo esercizio"
printf '  %s%-14s%s %s\n' "${C_CYN}" "lab check <id>" "${C_RST}" "verifica il lavoro  [non cancella nulla]"
printf '  %s%-14s%s %s\n' "${C_CYN}" "lab hint  <id>" "${C_RST}" "un indizio se ti blocchi"
printf '  %s%-14s%s %s\n' "${C_CYN}" "lab help"       "${C_RST}" "tutti i comandi e le regole"
printf '%s\n' ''
printf '  %s%s%s   %s%s%s\n' "${C_DIM}" "Prima cosa da fare:" "${C_RST}" "${C_BLD}" "lab list" "${C_RST}"
printf '%s\n' ''
