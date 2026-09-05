LAB 01 — filesystem basics

OBIETTIVO
  Creare directory, spostare, copiare, cancellare file.

WORKDIR
  cd ${LAB_TRAINING_ROOT:-/workspace/training}/fs-lab
  (il reset crea inbox/ con raw.txt e temp.tmp: lab start 01-filesystem)

DATI — struttura iniziale
  inbox/raw.txt     un file di testo di partenza (lo sposterai)
  temp.tmp          un file temporaneo (lo eliminerai)

AVVIO
  Prima apri il container del corso (vedi il README del corso: i comandi
  "lab ..." vivono DENTRO il container, non sull'host). Poi avvia il lab
  e vai nel WORKDIR:
    lab start 01-filesystem
    cd ${LAB_TRAINING_ROOT:-/workspace/training}/fs-lab

TASK
  1. Crea la directory project/docs
  2. Crea il file project/notes.txt e scrivi DENTRO il file questo testo: "filesystem lab"
  3. Sposta inbox/raw.txt in project/data.txt  (mv, non cp)
  4. Copia project/data.txt in project/docs/data.backup
  5. Elimina temp.tmp

SUGGERIMENTI — i comandi di questo lab
  - mkdir: crea una directory. Di default crea UN SOLO livello: se una
    cartella del percorso non esiste ancora, fallisce con "No such file or
    directory".
    - mkdir project              crea solo project/
    - mkdir -p project/docs      il flag -p crea anche le cartelle mancanti
                                 lungo il percorso (project). Qui -p e'
                                 indispensabile: senza, fallisce perche'
                                 project/ non esiste ancora.
  - Scrivere testo in un file (redirect >): esempi
    - printf 'filesystem lab\n' > project/notes.txt
    - echo 'filesystem lab' > project/notes.txt   (newline finale tollerato)
  - mv sorgente destinazione: SPOSTA (taglia e incolla) un file, cambiandone
    il nome e/o la cartella. Il file originale scompare.
  - cp sorgente destinazione: COPIA il file, lasciando l'originale al suo posto.
  - rm file: cancella un file. (NON rimuove una directory non vuota: servira' rm -r
    o rm -rf, che pero' NON servono per questo lab.)

VERIFY
  lab check 01-filesystem

NOTE
  notes.txt e' un documento di TESTO: va creato e al suo interno va scritta
  la stringa "filesystem lab" (senza virgolette). Crearlo vuoto (es. touch)
  NON basta: il check controlla il contenuto del file.
  Il task 3 chiede esplicitamente MV e non CP: "Sposta" = il file originale
  (inbox/raw.txt) non deve piu' esistere quando hai finito.
  Dopo aver spostato raw.txt, la cartella inbox/ resta vuota: va bene cosi',
  il check non la valida (non serve eliminarla).
