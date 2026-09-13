LAB 10 — file comparison

OBIETTIVO
  Confrontare versioni di file, verificarne l'identita byte-per-byte e
  confrontare intere directory con diff, cmp e comm.

WORKDIR
  cd ${LAB_TRAINING_ROOT:-/workspace/training}/@V_DIR@
  (I dati li crea il reset: lab start 10-file-comparison)

DATI — struttura del WORKDIR (dopo il reset)
  @V_DIR@/
    @V_CFG_OLD@       <- versione precedente di un config (@V_CFG_OLD@ cambia la porta)
    @V_CFG_NEW@       <- versione nuova dello stesso config (porta aggiornata)
    @V_REP_A@          <- un report di build
    @V_REP_B@          <- copia dello stesso report (dovrebbero essere identici)
    @V_PROD@      <- lista ORDINATA di host in produzione
    @V_STAG@   <- lista ORDINATA di host in staging
    @V_REL_A@/           <- release precedente (3 file)
    @V_REL_B@/           <- release nuova (1 solo file cambiato: @V_APP_CONF@)
    @V_DEPRECATED@        <- file da eliminare

AVVIO
  Avvia il lab e vai nel WORKDIR:
    lab start 10-file-comparison
    cd ${LAB_TRAINING_ROOT:-/workspace/training}/@V_DIR@

TASK
  1. Confronta @V_CFG_OLD@ e @V_CFG_NEW@ con diff -u, salva il risultato in @V_OUT_DIFF@
  2. Verifica se @V_REP_A@ e @V_REP_B@ sono identici byte-per-byte con cmp; scrivi "identici" oppure "diversi" in @V_OUT_CHECK@
  3. @V_PROD@ e @V_STAG@ sono liste ORDINATE: trova con comm gli host presenti SOLO in produzione, salvali in @V_OUT_ONLY@
  4. Confronta ricorsivamente @V_REL_A@/ e @V_REL_B@/ con diff -r, salva l'output completo in @V_OUT_REL@
  5. Elimina @V_DEPRECATED@

SUGGERIMENTI — i comandi di questo lab
  - diff -u vecchio nuovo:  mostra le differenze in formato "unified" (lo stesso
            usato da git diff). Le righe rimosse iniziano con -, quelle aggiunte con +.
            Esempio:  diff -u @V_CFG_OLD@ @V_CFG_NEW@ > @V_OUT_DIFF@
            ATTENZIONE: diff termina con stato diverso da zero se i file
            differiscono. Non e' un errore: e' cosi' che diff segnala "ho
            trovato differenze" — la redirezione > funziona comunque.
  - cmp file1 file2:  confronta due file byte per byte. Nessun output = identici.
            Con -s (silent) non stampa nulla, restituisce solo lo stato di uscita:
            cmp -s @V_REP_A@ @V_REP_B@ && echo identici || echo diversi
  - comm file1 file2:  richiede DUE file gia' ordinati (sort). Stampa tre colonne:
            solo in file1 | solo in file2 | in entrambi.
            -1 nasconde la colonna "solo in file1", -2 nasconde "solo in file2",
            -3 nasconde "in entrambi". Quindi -23 lascia solo "solo in file1":
            comm -23 @V_PROD@ @V_STAG@ > @V_OUT_ONLY@
  - diff -r dir1 dir2:  confronta ricorsivamente due directory, elencando i file
            che differiscono:
            diff -r @V_REL_A@ @V_REL_B@ > @V_OUT_REL@

VERIFY
  lab check 10-file-comparison

NOTE
  comm si aspetta input ordinato: i due file di questo lab lo sono gia',
  ma su dati reali va sempre passato prima da 'sort'.
  Valori di riferimento:
  - @V_OUT_DIFF@ deve contenere la riga "-<riga di @V_CFG_OLD@>" e "+<riga di @V_CFG_NEW@>"
    (nel reset base: "-port=8080" e "+port=8443").
  - @V_OUT_CHECK@ = "identici" (@V_REP_A@ e @V_REP_B@ sono uguali).
  - @V_OUT_ONLY@ = gli host presenti in @V_PROD@ ma non in @V_STAG@
    (nel reset base: "host-a" e "host-d").
  - @V_OUT_REL@ deve citare "@V_APP_CONF@" (l'unico file cambiato tra le due release).
