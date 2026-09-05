LAB 05 — text processing

OBIETTIVO
  grep, sort, uniq, awk su log e csv.

WORKDIR
  cd ${LAB_TRAINING_ROOT:-/workspace/training}/text-lab
  (I dati access.log e services.csv li crea il reset: lab start 05-text-processing)

DATI — struttura dei file di input
  access.log    4 colonne separate da spazio:
                 $1 = IP   $2 = livello (INFO/ERROR/WARN)   $3 = percorso   $4 = codice HTTP
                 Esempio:  10.0.0.2  ERROR  /api/users  500
  services.csv  3 colonne separate da virgola (CSV con header):
                 $1 = service   $2 = region   $3 = requests
                 Prima riga = header (service,region,requests)

AVVIO
  Avvia il lab e vai nel WORKDIR:
    lab start 05-text-processing
    cd ${LAB_TRAINING_ROOT:-/workspace/training}/text-lab

TASK
  1. Conta le righe con ERROR in access.log → error_count.txt
  2. IP con status 500, unici, ordinati → failing_ips.txt
  3. Somma colonna requests del servizio api in services.csv → api_total.txt
  4. Crea il file summary.txt e scrivi come prima riga il testo: "log analysis complete"

SUGGERIMENTI — i comandi di questo lab
  La pipe | passa l'output di un comando all'input del successivo.
  Esempio:  grep 'ERROR' access.log | wc -l
  - grep:  cerca e tiene solo le righe che contengono la stringa cercata.
  - wc -l: (word count lines) conta le RIGHE dello stream. Da solo, wc
           conta caratteri/parole/righe; con -l conta solo le righe.
  - sort -u: ordina le righe e, con -u (unique), toglie i duplicati.
  - awk:  processa file riga per riga, diviso in colonne. Esempio base:
            awk '{print $1}' file            # stampa la 1^ colonna
            awk -F, '{print $1}' file.csv    # separatore = virgola
    Per calcolare una somma usa il blocco END:
            awk -F, 'NR>1 && $1=="api" {sum+=$3} END {print sum}' services.csv
    'NR>1' salta la prima riga (header), '$1=="api"' filtra per servizio,
    'END' stampa il totale a fine lettura.

VERIFY
  lab check 05-text-processing

NOTE
  summary.txt e' un documento di TESTO: va creato e la sua prima riga deve
  essere "log analysis complete" (senza virgolette). Crearlo vuoto NON basta.
  Si scrive con printf oppure echo (newline finale tollerato):
  printf 'log analysis complete\n' > summary.txt
  oppure:  echo 'log analysis complete' > summary.txt
