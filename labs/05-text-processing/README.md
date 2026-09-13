LAB 05 — text processing

OBIETTIVO
  grep, sort, uniq, awk su log e csv.

WORKDIR
  cd ${LAB_TRAINING_ROOT:-/workspace/training}/@V_DIR@
  (I dati @V_LOG@ e @V_CSV@ li crea il reset: lab start 05-text-processing)

DATI — struttura dei file di input
  @V_LOG@    4 colonne separate da spazio:
                 $1 = IP   $2 = livello (INFO/ERROR/WARN)   $3 = percorso   $4 = codice HTTP
                 Esempio:  10.0.0.2  ERROR  /api/users  500
  @V_CSV@  3 colonne separate da virgola (CSV con header):
                 $1 = service   $2 = region   $3 = requests
                 Prima riga = header (service,region,requests)

AVVIO
  Avvia il lab e vai nel WORKDIR:
    lab start 05-text-processing
    cd ${LAB_TRAINING_ROOT:-/workspace/training}/@V_DIR@

TASK
  1. Conta le righe con ERROR in @V_LOG@ → @V_OUT1@
  2. IP con status 500, unici, ordinati → @V_OUT2@
  3. Somma colonna requests del servizio api in @V_CSV@ → @V_OUT3@
  4. Crea il file @V_OUT4@ e scrivi come prima riga il testo: "@V_TEXT@"

SUGGERIMENTI — i comandi di questo lab
  La pipe | passa l'output di un comando all'input del successivo.
  Esempio:  grep 'ERROR' @V_LOG@ | wc -l
  - grep:  cerca e tiene solo le righe che contengono la stringa cercata.
  - wc -l: (word count lines) conta le RIGHE dello stream. Da solo, wc
           conta caratteri/parole/righe; con -l conta solo le righe.
  - sort -u: ordina le righe e, con -u (unique), toglie i duplicati.
  - awk:  processa file riga per riga, diviso in colonne. Esempio base:
            awk '{print $1}' file            # stampa la 1^ colonna
            awk -F, '{print $1}' file.csv    # separatore = virgola
    Per calcolare una somma usa il blocco END:
            awk -F, 'NR>1 && $1=="api" {sum+=$3} END {print sum}' @V_CSV@
    'NR>1' salta la prima riga (header), '$1=="api"' filtra per servizio,
    'END' stampa il totale a fine lettura.
  Nota apici in awk: il programma awk va messo tra APICI SINGOLI ('...');
  cosi' la shell non tocca $1, $3 ecc. e li consegna ad awk. Se li scrivi
  con gli apici DOPPI ("..."), la shell espande $1/$3 (che valgono vuoto)
  prima che awk girino e il comando non fa piu' la somma giusta.

VERIFY
  lab check 05-text-processing

NOTE
  @V_OUT4@ e' un documento di TESTO: va creato e la sua prima riga deve
  essere "@V_TEXT@" (senza virgolette). Crearlo vuoto NON basta.
  Si scrive con printf oppure echo (newline finale tollerato):
  printf '@V_TEXT@\n' > @V_OUT4@
  oppure:  echo '@V_TEXT@' > @V_OUT4@
