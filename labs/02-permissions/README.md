LAB 02 — permissions

OBIETTIVO
  Bit eseguibile, file privati, directory condivise.

WORKDIR
  cd ${LAB_TRAINING_ROOT:-/workspace/training}/@V_DIR@
  (il reset crea @V_SCRIPTS@/@V_SCRIPT@ e @V_PRIVATE@: lab start 02-permissions)

DATI — struttura iniziale
  @V_SCRIPTS@/@V_SCRIPT@    uno script (testo) creato senza permesso di esecuzione
  @V_PRIVATE@       un file con dati segreti (da proteggere a 600)

AVVIO
  Avvia il lab e vai nel WORKDIR:
    lab start 02-permissions
    cd ${LAB_TRAINING_ROOT:-/workspace/training}/@V_DIR@

TASK
  1. Rendi eseguibile @V_SCRIPTS@/@V_SCRIPT@ per owner, group e others
  2. Imposta @V_PRIVATE@ a 600 (solo owner legge/scrive)
  3. Crea la directory @V_DROPBOX@
  4. Imposta @V_DROPBOX@ a 775
  5. Crea il file @V_DROPBOX@/@V_DBOX_README@ e scrivi DENTRO il file questo testo: "@V_TEXT@"

SUGGERIMENTI — il comando chmod e la notazione ottale
  Ogni file/directory ha 3 livelli di permessi: owner (u), group (g), others (o);
  ciascuno con i bit Read (r=4), Write (w=2), eXecute (x=1).
  I numeri come 600 o 775 scompongono questi bit in 3 cifre ottali (u/g/o):
    600 = rw-------  owner legge+scrive, nessun altro accesso.
    775 = rwxrwxr-x  owner e group accesso completo, others solo lettura+ingresso.
    755 = rwxr-xr-x  molto comune per script e programmi.
  Nota: su una DIRECTORY serve il bit x per potervi entrare.

  Il comando e'  chmod <modo> <bersaglio>
    - chmod a+x @V_SCRIPTS@/@V_SCRIPT@        aggiunge x per tutti (a = all): owner/group/others
    - chmod 600 @V_PRIVATE@           setta lettura/scrittura solo per l'owner
    - mkdir -p @V_DROPBOX@                crea la cartella (da fare PRIMA del chmod)
    - chmod 775 @V_DROPBOX@               setta i permessi della cartella condivisa

  Per scrivere testo in un file (redirect >):
    - printf '@V_TEXT@\n' > @V_DROPBOX@/@V_DBOX_README@
    - echo '@V_TEXT@' > @V_DROPBOX@/@V_DBOX_README@   (newline finale tollerato)

VERIFY
  lab check 02-permissions

NOTE
  @V_DROPBOX@/@V_DBOX_README@ e' un documento di TESTO: va creato e al suo interno va
  scritta la stringa "@V_TEXT@" (senza virgolette). Crearlo vuoto
  (touch) NON basta: il check controlla il contenuto del file.
  Controlla sempre il percorso con pwd e ls; NON usare chmod -R in questo lab.
  Per ispezionare i permessi:  stat -c '%a %A %n' @V_SCRIPTS@/@V_SCRIPT@ @V_PRIVATE@ @V_DROPBOX@
