LAB 02 — permissions

OBIETTIVO
  Bit eseguibile, file privati, directory condivise.

WORKDIR
  cd ${LAB_TRAINING_ROOT:-/workspace/training}/perms-lab
  (il reset crea scripts/run.sh e private.txt: lab start 02-permissions)

DATI — struttura iniziale
  scripts/run.sh    uno script (testo) creato senza permesso di esecuzione
  private.txt       un file con dati segreti (da proteggere a 600)

AVVIO
  Avvia il lab e vai nel WORKDIR:
    lab start 02-permissions
    cd ${LAB_TRAINING_ROOT:-/workspace/training}/perms-lab

TASK
  1. Rendi eseguibile scripts/run.sh per owner, group e others
  2. Imposta private.txt a 600 (solo owner legge/scrive)
  3. Crea la directory dropbox
  4. Imposta dropbox a 775
  5. Crea il file dropbox/README.txt e scrivi DENTRO il file questo testo: "permissions matter"

SUGGERIMENTI — il comando chmod e la notazione ottale
  Ogni file/directory ha 3 livelli di permessi: owner (u), group (g), others (o);
  ciascuno con i bit Read (r=4), Write (w=2), eXecute (x=1).
  I numeri come 600 o 775 scompongono questi bit in 3 cifre ottali (u/g/o):
    600 = rw-------  owner legge+scrive, nessun altro accesso.
    775 = rwxrwxr-x  owner e group accesso completo, others solo lettura+ingresso.
    755 = rwxr-xr-x  molto comune per script e programmi.
  Nota: su una DIRECTORY serve il bit x per potervi entrare.

  Il comando e'  chmod <modo> <bersaglio>
    - chmod a+x scripts/run.sh        aggiunge x per tutti (a = all): owner/group/others
    - chmod 600 private.txt           setta lettura/scrittura solo per l'owner
    - mkdir -p dropbox                crea la cartella (da fare PRIMA del chmod)
    - chmod 775 dropbox               setta i permessi della cartella condivisa

  Per scrivere testo in un file (redirect >):
    - printf 'permissions matter\n' > dropbox/README.txt
    - echo 'permissions matter' > dropbox/README.txt   (newline finale tollerato)

VERIFY
  lab check 02-permissions

NOTE
  dropbox/README.txt e' un documento di TESTO: va creato e al suo interno va
  scritta la stringa "permissions matter" (senza virgolette). Crearlo vuoto
  (touch) NON basta: il check controlla il contenuto del file.
  Controlla sempre il percorso con pwd e ls; NON usare chmod -R in questo lab.
  Per ispezionare i permessi:  stat -c '%a %A %n' scripts/run.sh private.txt dropbox
