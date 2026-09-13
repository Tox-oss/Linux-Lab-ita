LAB 03 — users and groups

OBIETTIVO
  Gruppo, utente, ownership di una directory di team.

WORKDIR
  cd ${LAB_TRAINING_ROOT:-/workspace/training}/@V_DIR@
  (il reset svuota la cartella di lavoro: lab start 03-users-groups)

DATI — stato di partenza
  Nessun file creato dal reset: la cartella @V_DIR@ e' vuota.
  Utente "@V_USER@" e gruppo "@V_GROUP@" NON esistono ancora: li crei tu.

AVVIO
  Avvia il lab e vai nel WORKDIR:
    lab start 03-users-groups
    cd ${LAB_TRAINING_ROOT:-/workspace/training}/@V_DIR@

TASK
  1. Crea il gruppo @V_GROUP@
  2. Crea l'utente @V_USER@ con home e shell /bin/bash
  3. Aggiungi @V_USER@ al gruppo @V_GROUP@ (senza togliere altri gruppi)
  4. Crea la directory @V_TEAM@
  5. Owner/group di @V_TEAM@: @V_USER@:@V_GROUP@
  6. Permessi di @V_TEAM@: @V_TEAM_MODE@

SUGGERIMENTI — i comandi di questo lab
  I punti 1, 2, 3 e 5 toccano il sistema: partono con 'sudo'.
  sudo comando = esegui UNA riga con i pieni poteri di root (ti chiede la
  password del TUO profilo, quella che ti ha dato l'intro). I punti 4 e 6
  (mkdir e chmod su file tuoi) vanno senza 'sudo'.
  - sudo groupadd @V_GROUP@: registra il nuovo gruppo "@V_GROUP@" nel sistema.
  - sudo useradd -m -s /bin/bash @V_USER@: crea l'account "@V_USER@".
      -m : crea fisicamente la home (/home/@V_USER@)
      -s /bin/bash : imposta la shell di login
  - sudo usermod -aG @V_GROUP@ @V_USER@: aggiunge "@V_GROUP@" ai gruppi secondari (-G)
      dell'utente. Il flag -a (append) e' FONDAMENTALE: senza -a i gruppi
      secondari esistenti verrebbero SOSTITUITI, non aggiunti.
  - sudo chown @V_USER@:@V_GROUP@ @V_TEAM@: imposta contemporaneamente owner (@V_USER@)
      e group (@V_GROUP@) della directory.
  - chmod @V_TEAM_MODE@ @V_TEAM@: @V_TEAM_MODE@ = rwxrwx---  accesso completo a owner e group @V_GROUP@,
      nessun accesso per others.

VERIFY
  lab check 03-users-groups

NOTE
  L'utente @V_USER@ e il gruppo @V_GROUP@ sono STATO DI SISTEMA (transitorio):
  vivono solo dentro il container, NON nel volume. Quindi:
  - esegui tutti i comandi e subito dopo lab check 03-users-groups NELLA
    STESSA SESSIONE, senza chiudere il terminale;
  - se chiudi e riavvii il container, utente e gruppo saranno spariti e il
    check fallira' su quei controlli (i file su /workspace restano invece intatti).
  Il check verifica lo stato di sistema con id / getent, non solo i file.
  Per verificare a mano:  id @V_USER@   •   getent group @V_GROUP@   •   stat -c '%n -> %U:%G | %a' @V_TEAM@
