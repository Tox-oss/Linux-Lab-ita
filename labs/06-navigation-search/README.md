LAB 06 — navigation and search

OBIETTIVO
  Orientarsi nel filesystem, ispezionare file lunghi, cercare file e leggere log.

WORKDIR
  cd ${LAB_TRAINING_ROOT:-/workspace/training}/@V_DIR@
  (I dati @V_DOCS@/, @V_EVID@/ e @V_LOGS@/ li crea il reset: lab start 06-navigation-search)

DATI — struttura del WORKDIR (dopo il reset)
  @V_DIR@/
    @V_DOCS@/@V_RUNBOOK@                  <- il runbook da aprire con less (task 5)
    @V_EVID@/@V_YR@/@V_A@/@V_INC_PAT@
    @V_EVID@/@V_YR@/@V_B@/@V_INC_PAT@
    @V_EVID@/@V_ARC@/@V_INC_PAT@
    @V_EVID@/@V_ARC@/readme.txt
    @V_LOGS@/@V_APP@                      <- il file di log da cui estrarre le ultime righe

AVVIO
  Avvia il lab e vai nel WORKDIR:
    lab start 06-navigation-search
    cd ${LAB_TRAINING_ROOT:-/workspace/training}/@V_DIR@

TASK
  1. Entra nel WORKDIR indicato e salva il percorso assoluto corrente in @V_OUT_CP@
  2. Lista le voci di primo livello del WORKDIR, una per riga, in @V_OUT_RL@
  3. Trova i file @V_INC_PAT@ sotto @V_EVID@ e salva i percorsi ordinati in @V_OUT_IF@
  4. Estrai le ultime 4 righe di @V_LOGS@/@V_APP@ in @V_OUT_LE@
  5. Apri @V_DOCS@/@V_RUNBOOK@ con less, trova l'owner di escalation e scrivilo in @V_OUT_OWN@

SUGGERIMENTI — i comandi di questo lab
  La redirezione > scrive l'output di un comando in un file.
  Esempio:   pwd > @V_OUT_CP@   # salva "dove sono" dentro @V_OUT_CP@
  La pipe | passa l'output di un comando all'input del successivo.
  Esempio:   find @V_EVID@ -name '*.txt' | sort
  - cd:  cambia la directory corrente della shell (entra in una cartella).
  - pwd: stampa il percorso assoluto della directory in cui ti trovi.
  - ls -1: elenca le voci di primo livello di una cartella, UNA per riga.
           Resta nella cartella corrente e fotografa solo la sua prima "faccia":
           NON scende nelle sottocartelle.
  - find: attraversa una cartella (e le sue sottocartelle) cercando file.
           find @V_EVID@ -type f -name '@V_INC_PAT@'
           -type f  = solo file (non cartelle)
           -name '@V_INC_PAT@'  = il nome matcha quel modello (l'* sostituisce
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
      less @V_DOCS@/@V_RUNBOOK@   apri il file (resta in attesa di comandi)
      /                       premi il tasto slash
      Escalation              scrivi la parola da cercare
      invio                   esegui la ricerca
      n                       (opzionale) vai al risultato successivo
      q                       esci da less e torna alla shell
    Il valore da salvare in @V_OUT_OWN@ e' tutto cio' che segue i due punti,
    senza il testo della voce, quindi:  @V_OWNER@
    Si scrive con printf oppure echo (newline finale tollerato):
      printf '@V_OWNER@\n' > @V_OUT_OWN@
      oppure:  echo '@V_OWNER@' > @V_OUT_OWN@
    (Il check non valida la TUA lettura, ma solo che @V_OUT_OWN@ contenga esattamente
    @V_OWNER@ come prima riga.)
  - In un terminale NON interattivo (senza TTY, es. CI o pipe) less non si puo'
    usare come descritto sopra. Alternativa che da' la stessa riga:
      grep "Escalation owner" @V_DOCS@/@V_RUNBOOK@
    (stampa la riga 6 con il valore @V_OWNER@). Puoi anche estrarre il valore
    direttamente:
      grep "Escalation owner" @V_DOCS@/@V_RUNBOOK@ | sed "s/^Escalation owner: //"
    Il risultato negli esempi qui sopra e' sempre @V_OWNER@.
  - Task 2: "ls -1 > @V_OUT_RL@" fotografa la directory COSI' COME E'
    adesso. Se hai gia' creato altri file di output (es. @V_OUT_CP@) nello
    stesso WORKDIR, compaiono anche loro nella lista. Non e' un errore: il check
    verifica solo che ci siano @V_DOCS@, @V_EVID@ e @V_LOGS@.
