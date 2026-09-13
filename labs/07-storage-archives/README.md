LAB 07 — storage and archives

OBIETTIVO
  Misurare spazio disco, stimare dimensioni di directory e creare/ripristinare archivi tar.

WORKDIR
  cd ${LAB_TRAINING_ROOT:-/workspace/training}/@V_DIR@
  (I dati @V_DS@/ li crea il reset: lab start 07-storage-archives)

DATI — struttura del WORKDIR (dopo il reset)
  @V_DIR@/
    @V_DS@/@V_A@/@V_CFG@
    @V_DS@/@V_A@/logs/@V_APP@
    @V_DS@/@V_B@/@V_README@
    @V_DS@/@V_BIG@/@V_BLOB@   <- il file piu' grande (64K), creato dal reset

AVVIO
  Avvia il lab e vai nel WORKDIR:
    lab start 07-storage-archives
    cd ${LAB_TRAINING_ROOT:-/workspace/training}/@V_DIR@

TASK
  1. Salva un report leggibile del filesystem corrente in @V_OUT_FS@
  2. Salva la dimensione leggibile di @V_DS@ in @V_OUT_SIZE@
  3. Trova il file piu grande sotto @V_DS@ e salva la riga completa in @V_OUT_ITEM@
  4. Crea l'archivio compresso @V_ARC@ da @V_DS@/@V_A@
  5. Estrai @V_ARC@ dentro @V_RESTORE@

SUGGERIMENTI — i comandi di questo lab
  La redirezione > scrive l'output di un comando in un file.
  Esempio:   df -h . > @V_OUT_FS@
  La pipe | passa l'output di un comando all'input del successivo.
  - df -h:  mostra lo spazio dei filesystem montati in formato leggibile.
            df -h .  = il filesystem che contiene la directory corrente (il punto).
            -h (human readable) = dimensioni in K/M/G invece di byte.
  - du: misura quanto spazio occupano file e directory.
            du -sh @V_DS@
            -s (sum) = un solo totale;  -h = leggibile.
  - find ... -exec: misura ogni singolo file e prende il piu' grande:
            find @V_DS@ -type f -exec du -h {} + | sort -h | tail -n 1
            -type f        = solo file, non cartelle
            -exec du -h {} +  = per ogni file trovato calcola la dimensione leggibile
            | sort -h      = ordina per dimensione (human sort: 1K < 1M < 1G)
            | tail -n 1    = tiene solo l'ultima riga (la piu' grande)
  - tar: crea e ripristina archivi.
            Crea:   tar -czf @V_ARC@ @V_DS@/@V_A@
                    c=create  z=gzip(compress)  f=file  seguito dal nome archivio
                    e poi la cartella da archiviare.
            Estrai: mkdir -p @V_RESTORE@
                    tar -xzf @V_ARC@ -C @V_RESTORE@
                    x=extract  z=gzip  f=file  -C=la directory dove estrarre.
            mkdir -p @V_RESTORE@ crea la cartella di destinazione se non esiste.

VERIFY
  lab check 07-storage-archives

NOTE
  L'obiettivo non e' memorizzare numeri assoluti: in Docker le dimensioni possono
  cambiare leggermente. Il check verifica i CONCETTI (un report df, una misura di
  @V_DS@, il file piu' grande che e' @V_BLOB@, un archivio con @V_CFG@,
  l'estrazione riuscita), non un valore esatto.
  Valori di riferimento (possono variare di poco):
  - @V_OUT_FS@ deve contenere la riga d'intestazione "Filesystem".
  - @V_OUT_SIZE@ deve terminare con "@V_DS@".
  - @V_OUT_ITEM@ deve citare "@V_DS@/@V_BIG@/@V_BLOB@".
  - @V_ARC@ deve elencare "@V_DS@/@V_A@/@V_CFG@" (tar -tzf).
  - dopo l'estrazione deve esistere @V_RESTORE@/@V_DS@/@V_A@/@V_CFG@.
