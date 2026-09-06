LAB 10 — file comparison

OBIETTIVO
  Confrontare versioni di file, verificarne l'identita byte-per-byte e
  confrontare intere directory con diff, cmp e comm.

WORKDIR
  cd ${LAB_TRAINING_ROOT:-/workspace/training}/diff-lab
  (I dati li crea il reset: lab start 10-file-comparison)

DATI — struttura del WORKDIR (dopo il reset)
  diff-lab/
    config.old.conf       <- versione precedente di un config (port=8080)
    config.new.conf       <- versione nuova dello stesso config (port=8443)
    report_a.txt          <- un report di build
    report_b.txt          <- copia dello stesso report (dovrebbero essere identici)
    servers_prod.txt      <- lista ORDINATA di host in produzione
    servers_staging.txt   <- lista ORDINATA di host in staging
    release_v1/           <- release precedente (3 file)
    release_v2/           <- release nuova (1 solo file cambiato: app.conf)
    deprecated.old        <- file da eliminare

AVVIO
  Avvia il lab e vai nel WORKDIR:
    lab start 10-file-comparison
    cd ${LAB_TRAINING_ROOT:-/workspace/training}/diff-lab

TASK
  1. Confronta config.old.conf e config.new.conf con diff -u, salva il risultato in config.diff
  2. Verifica se report_a.txt e report_b.txt sono identici byte-per-byte con cmp; scrivi "identici" oppure "diversi" in report_check.txt
  3. servers_prod.txt e servers_staging.txt sono liste ORDINATE: trova con comm gli host presenti SOLO in produzione, salvali in only_prod.txt
  4. Confronta ricorsivamente release_v1/ e release_v2/ con diff -r, salva l'output completo in release_diff.txt
  5. Elimina deprecated.old

SUGGERIMENTI — i comandi di questo lab
  - diff -u vecchio nuovo:  mostra le differenze in formato "unified" (lo stesso
            usato da git diff). Le righe rimosse iniziano con -, quelle aggiunte con +.
            Esempio:  diff -u config.old.conf config.new.conf > config.diff
            ATTENZIONE: diff termina con stato diverso da zero se i file
            differiscono. Non e' un errore: e' cosi' che diff segnala "ho
            trovato differenze" — la redirezione > funziona comunque.
  - cmp file1 file2:  confronta due file byte per byte. Nessun output = identici.
            Con -s (silent) non stampa nulla, restituisce solo lo stato di uscita:
            cmp -s report_a.txt report_b.txt && echo identici || echo diversi
  - comm file1 file2:  richiede DUE file gia' ordinati (sort). Stampa tre colonne:
            solo in file1 | solo in file2 | in entrambi.
            -1 nasconde la colonna "solo in file1", -2 nasconde "solo in file2",
            -3 nasconde "in entrambi". Quindi -23 lascia solo "solo in file1":
            comm -23 servers_prod.txt servers_staging.txt > only_prod.txt
  - diff -r dir1 dir2:  confronta ricorsivamente due directory, elencando i file
            che differiscono:
            diff -r release_v1 release_v2 > release_diff.txt

VERIFY
  lab check 10-file-comparison

NOTE
  comm si aspetta input ordinato: i due file di questo lab lo sono gia',
  ma su dati reali va sempre passato prima da 'sort'.
  Valori di riferimento:
  - config.diff deve contenere le righe "-port=8080" e "+port=8443".
  - report_check.txt = "identici" (report_a.txt e report_b.txt sono uguali).
  - only_prod.txt = "host-a" e "host-d" (gli host non presenti in staging).
  - release_diff.txt deve citare "app.conf" (l'unico file cambiato tra le due release).
