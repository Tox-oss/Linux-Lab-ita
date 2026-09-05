LAB 03 — users and groups

OBIETTIVO
  Gruppo, utente, ownership di una directory di team.

WORKDIR
  cd ${LAB_TRAINING_ROOT:-/workspace/training}/users-lab
  (il reset svuota la cartella di lavoro: lab start 03-users-groups)

DATI — stato di partenza
  Nessun file creato dal reset: la cartella users-lab e' vuota.
  Utente "learner" e gruppo "devops" NON esistono ancora: li crei tu.

AVVIO
  Avvia il lab e vai nel WORKDIR:
    lab start 03-users-groups
    cd ${LAB_TRAINING_ROOT:-/workspace/training}/users-lab

TASK
  1. Crea il gruppo devops
  2. Crea l'utente learner con home e shell /bin/bash
  3. Aggiungi learner al gruppo devops (senza togliere altri gruppi)
  4. Crea la directory team
  5. Owner/group di team: learner:devops
  6. Permessi di team: 770

SUGGERIMENTI — i comandi di questo lab
  - groupadd devops: registra il nuovo gruppo "devops" nel sistema.
  - useradd -m -s /bin/bash learner: crea l'account "learner".
      -m : crea fisicamente la home (/home/learner)
      -s /bin/bash : imposta la shell di login
  - usermod -aG devops learner: aggiunge "devops" ai gruppi secondari (-G)
      dell'utente. Il flag -a (append) e' FONDAMENTALE: senza -a i gruppi
      secondari esistenti verrebbero SOSTITUITI, non aggiunti.
  - chown learner:devops team: imposta contemporaneamente owner (learner)
      e group (devops) della directory.
  - chmod 770 team: 770 = rwxrwx---  accesso completo a owner e group devops,
      nessun accesso per others.

VERIFY
  lab check 03-users-groups

NOTE
  L'utente learner e il gruppo devops sono STATO DI SISTEMA (transitorio):
  vivono solo dentro il container, NON nel volume. Quindi:
  - esegui tutti i comandi e subito dopo lab check 03-users-groups NELLA
    STESSA SESSIONE, senza chiudere il terminale;
  - se chiudi e riavvii il container, utente e gruppo saranno spariti e il
    check fallira' su quei controlli (i file su /workspace restano invece intatti).
  Il check verifica lo stato di sistema con id / getent, non solo i file.
  Per verificare a mano:  id learner   •   getent group devops   •   stat -c '%n -> %U:%G | %a' team
