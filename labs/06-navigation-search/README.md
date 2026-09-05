LAB 06 — navigation and search

OBIETTIVO
  Orientarsi nel filesystem, ispezionare file lunghi, cercare file e leggere log.

WORKDIR
  cd ${LAB_TRAINING_ROOT:-/workspace/training}/nav-lab
  (I dati docs/, evidence/ e logs/ li crea il reset: lab start 06-navigation-search)

DATI — struttura del WORKDIR (dopo il reset)
  nav-lab/
    docs/runbook.txt                  <- il runbook da aprire con less (task 5)
    evidence/2026/alpha/incident-001.txt
    evidence/2026/beta/incident-002.txt
    evidence/archive/incident-003.txt
    evidence/archive/readme.txt
    logs/app.log                      <- il file di log da cui estrarre le ultime righe

AVVIO
  Avvia il lab e vai nel WORKDIR:
    lab start 06-navigation-search
    cd ${LAB_TRAINING_ROOT:-/workspace/training}/nav-lab

TASK
  1. Entra nel WORKDIR indicato e salva il percorso assoluto corrente in current_path.txt
  2. Lista le voci di primo livello del WORKDIR, una per riga, in root_listing.txt
  3. Trova i file incident-*.txt sotto evidence e salva i percorsi ordinati in incident_files.txt
  4. Estrai le ultime 4 righe di logs/app.log in last_events.txt
  5. Apri docs/runbook.txt con less, trova l'owner di escalation e scrivilo in owner.txt

SUGGERIMENTI — i comandi di questo lab
  La redirezione > scrive l'output di un comando in un file.
  Esempio:   pwd > current_path.txt   # salva "dove sono" dentro current_path.txt
  La pipe | passa l'output di un comando all'input del successivo.
  Esempio:   find evidence -name '*.txt' | sort
  - cd:  cambia la directory corrente della shell (entra in una cartella).
  - pwd: stampa il percorso assoluto della directory in cui ti trovi.
  - ls -1: elenca le voci di primo livello di una cartella, UNA per riga.
           Resta nella cartella corrente e fotografa solo la sua prima "faccia":
           NON scende nelle sottocartelle.
  - find: attraversa una cartella (e le sue sottocartelle) cercando file.
           find evidence -type f -name 'incident-*.txt'
           -type f  = solo file (non cartelle)
           -name 'incident-*.txt'  = il nome matcha quel modello (l'* sostituisce
           qualsiasi parte del nome)
  - sort: ordina le righe in ordine alfabetico.
  - tail -n 4: mostra le ULTIME 4 righe di un file (tipico per i log, dove le
           righe piu' recenti stanno in fondo).
  - less: apre un file lungo senza stamparlo tutto a schermo. Dentro less:
           /testo  cerca "testo" nel file (premi n per il risultato successivo)
           q        esce e torna alla shell.

VERIFY
  lab check 06-navigation-search

NOTE
  - Task 5: apri il runbook e cerca la riga "Escalation owner:".
    Passi pratici dentro less (uno alla volta):
      less docs/runbook.txt   apri il file (resta in attesa di comandi)
      /                       premi il tasto slash
      Escalation              scrivi la parola da cercare
      invio                   esegui la ricerca
      n                       (opzionale) vai al risultato successivo
      q                       esci da less e torna alla shell
    Il valore da salvare in owner.txt e' tutto cio' che segue i due punti,
    senza il testo della voce, quindi:  sre-oncall
    Si scrive con printf oppure echo (newline finale tollerato):
      printf 'sre-oncall\n' > owner.txt
      oppure:  echo 'sre-oncall' > owner.txt
    (Il check non valida la TUA lettura, ma solo che owner.txt contenga esattamente
    sre-oncall come prima riga.)
  - Task 2: "ls -1 > root_listing.txt" fotografa la directory COSI' COME E'
    adesso. Se hai gia' creato altri file di output (es. current_path.txt) nello
    stesso WORKDIR, compaiono anche loro nella lista. Non e' un errore: il check
    verifica solo che ci siano docs, evidence e logs.
