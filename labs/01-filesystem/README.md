LAB 01 — filesystem basics

OBIETTIVO
  Creare directory, spostare, copiare, cancellare file.

WORKDIR
  cd ${LAB_TRAINING_ROOT:-/workspace/training}/@V_DIR@
  (il reset crea @V_INBOX@/ con @V_RAW@ e @V_TEMP@: lab start 01-filesystem)

DATI — struttura iniziale
  @V_INBOX@/@V_RAW@     un file di testo di partenza (lo sposterai)
  @V_TEMP@          un file temporaneo (lo eliminerai)

AVVIO
  Prima apri il container del corso (vedi il README del corso: i comandi
  "lab ..." vivono DENTRO il container, non sull'host). Poi avvia il lab
  e vai nel WORKDIR:
    lab start 01-filesystem
    cd ${LAB_TRAINING_ROOT:-/workspace/training}/@V_DIR@

TASK
  1. Crea la directory @V_MAIN@/@V_DOCS@
  2. Crea il file @V_MAIN@/@V_NOTES@ e scrivi DENTRO il file questo testo: "@V_TEXT@"
  3. Sposta @V_INBOX@/@V_RAW@ in @V_MAIN@/@V_DATA@  (mv, non cp)
  4. Copia @V_MAIN@/@V_DATA@ in @V_MAIN@/@V_DOCS@/@V_BACKUP@
  5. Elimina @V_TEMP@

SUGGERIMENTI — i comandi di questo lab
  - mkdir: crea una directory. Di default crea UN SOLO livello: se una
    cartella del percorso non esiste ancora, fallisce con "No such file or
    directory".
    - mkdir @V_MAIN@              crea solo @V_MAIN@/
    - mkdir -p @V_MAIN@/@V_DOCS@      il flag -p crea anche le cartelle mancanti
                                 lungo il percorso (@V_MAIN@). Qui -p e'
                                 indispensabile: senza, fallisce perche'
                                 @V_MAIN@/ non esiste ancora.
  - Scrivere testo in un file (redirect >): esempi
    - printf '@V_TEXT@\n' > @V_MAIN@/@V_NOTES@
    - echo '@V_TEXT@' > @V_MAIN@/@V_NOTES@   (newline finale tollerato)
  - mv sorgente destinazione: SPOSTA (taglia e incolla) un file, cambiandone
    il nome e/o la cartella. Il file originale scompare.
  - cp sorgente destinazione: COPIA il file, lasciando l'originale al suo posto.
  - rm file: cancella un file. (NON rimuove una directory non vuota: servira' rm -r
    o rm -rf, che pero' NON servono per questo lab.)

VERIFY
  lab check 01-filesystem

NOTE
  @V_NOTES@ e' un documento di TESTO: va creato e al suo interno va scritta
  la stringa "@V_TEXT@" (senza virgolette). Crearlo vuoto (es. touch)
  NON basta: il check controlla il contenuto del file.
  Il task 3 chiede esplicitamente MV e non CP: "Sposta" = il file originale
  (@V_INBOX@/@V_RAW@) non deve piu' esistere quando hai finito.
  Dopo aver spostato @V_RAW@, la cartella @V_INBOX@/ resta vuota: va bene cosi',
  il check non la valida (non serve eliminarla).
