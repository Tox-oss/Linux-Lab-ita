LAB 07 — storage and archives

OBIETTIVO
  Misurare spazio disco, stimare dimensioni di directory e creare/ripristinare archivi tar.

WORKDIR
  cd ${LAB_TRAINING_ROOT:-/workspace/training}/storage-lab
  (I dati datasets/ li crea il reset: lab start 07-storage-archives)

DATI — struttura del WORKDIR (dopo il reset)
  storage-lab/
    datasets/service-a/config.yml
    datasets/service-a/logs/app.log
    datasets/service-b/readme.txt
    datasets/big/blob.bin   <- il file piu' grande (64K), creato dal reset

AVVIO
  Avvia il lab e vai nel WORKDIR:
    lab start 07-storage-archives
    cd ${LAB_TRAINING_ROOT:-/workspace/training}/storage-lab

TASK
  1. Salva un report leggibile del filesystem corrente in filesystem_report.txt
  2. Salva la dimensione leggibile di datasets in dataset_size.txt
  3. Trova il file piu grande sotto datasets e salva la riga completa in largest_item.txt
  4. Crea l'archivio compresso service-a.tar.gz da datasets/service-a
  5. Estrai service-a.tar.gz dentro restore

SUGGERIMENTI — i comandi di questo lab
  La redirezione > scrive l'output di un comando in un file.
  Esempio:   df -h . > filesystem_report.txt
  La pipe | passa l'output di un comando all'input del successivo.
  - df -h:  mostra lo spazio dei filesystem montati in formato leggibile.
            df -h .  = il filesystem che contiene la directory corrente (il punto).
            -h (human readable) = dimensioni in K/M/G invece di byte.
  - du: misura quanto spazio occupano file e directory.
            du -sh datasets
            -s (sum) = un solo totale;  -h = leggibile.
  - find ... -exec: misura ogni singolo file e prende il piu' grande:
            find datasets -type f -exec du -h {} + | sort -h | tail -n 1
            -type f        = solo file, non cartelle
            -exec du -h {} +  = per ogni file trovato calcola la dimensione leggibile
            | sort -h      = ordina per dimensione (human sort: 1K < 1M < 1G)
            | tail -n 1    = tiene solo l'ultima riga (la piu' grande)
  - tar: crea e ripristina archivi.
            Crea:   tar -czf service-a.tar.gz datasets/service-a
                    c=create  z=gzip(compress)  f=file  seguito dal nome archivio
                    e poi la cartella da archiviare.
            Estrai: mkdir -p restore
                    tar -xzf service-a.tar.gz -C restore
                    x=extract  z=gzip  f=file  -C=la directory dove estrarre.
            mkdir -p restore crea la cartella di destinazione se non esiste.

VERIFY
  lab check 07-storage-archives

NOTE
  L'obiettivo non e' memorizzare numeri assoluti: in Docker le dimensioni possono
  cambiare leggermente. Il check verifica i CONCETTI (un report df, una misura di
  datasets, il file piu' grande che e' blob.bin, un archivio con config.yml,
  l'estrazione riuscita), non un valore esatto.
  Valori di riferimento (possono variare di poco):
  - filesystem_report.txt deve contenere la riga d'intestazione "Filesystem".
  - dataset_size.txt deve terminare con "datasets".
  - largest_item.txt deve citare "datasets/big/blob.bin".
  - service-a.tar.gz deve elencare "datasets/service-a/config.yml" (tar -tzf).
  - dopo l'estrazione deve esistere restore/datasets/service-a/config.yml.
