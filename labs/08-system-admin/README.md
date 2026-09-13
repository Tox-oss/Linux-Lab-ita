LAB 08 - system administration signals

OBIETTIVO
  Raccogliere snapshot di sistema e installare una crontab di training.

WORKDIR
  cd ${LAB_TRAINING_ROOT:-/workspace/training}/@V_DIR@
  (L'utente @V_USER@ e il daemon di log li prepara l'ambiente all'avvio;
  il file @V_CRON_FILE@ te lo crea il reset: lab start 08-system-admin)

DATI — cosa trovi gia' pronto
  All'avvio del container l'ambiente prepara per te:
    - l'utente di sistema "@V_USER@" (non devi crearlo tu)
    - il daemon di log (syslogd) attivo e un messaggio di sistema marcato
      "@V_LOG_TAG@" (lo userai nel TASK 4)
  Il comando lab start 08-system-admin crea per te:
    - la cartella di lavoro e il file @V_CRON_FILE@:
        @V_DIR@/@V_CRON_FILE@
        contenuto: @V_CRON_LINE@
  Tu dovrai installare @V_CRON_FILE@ nella tabella cron del sistema (vedi TASK 6).

AVVIO
  Avvia il lab e vai nel WORKDIR:
    lab start 08-system-admin
cd ${LAB_TRAINING_ROOT:-/workspace/training}/@V_DIR@
  IMPORTANTE: questa e' una sessione unica. Esegui i comandi e subito dopo il
  lab check NELLA STESSA SESSIONE, senza chiudere il terminale (vedi NOTE).

TASK
  1. Salva uno snapshot batch di top in @V_OUT_TOP@
     IMPORTANTE: top di default e' interattivo e blocca il terminale.
      Usa:  top -b -n 1 > @V_OUT_TOP@
      (-b = modalita batch, -n 1 = un solo snapshot)
  2. Salva lo stato memoria leggibile in @V_OUT_MEM@
  3. Salva la prima riga di openrc --version in @V_OUT_VER@
     (openrc e' il sistema di init di questa immagine)
  4. Recupera dal log di sistema il messaggio inviato dal reset con logger e
     salva le righe che lo contengono in @V_OUT_SYS@
     Usa:  grep @V_LOG_TAG@ /var/log/messages > @V_OUT_SYS@
  5. Esegui whoami come utente @V_USER@ tramite sudo e salva l'output in @V_OUT_SUDO@
     (l'utente @V_USER@ esiste gia': te lo crea il reset)
  6. Installa offline il file @V_CRON_FILE@ nella tabella cron con:
        sudo crontab @V_CRON_FILE@
      poi salva la tabella appena installata in @V_OUT_CRON@ con:
        sudo crontab -l > @V_OUT_CRON@
     (sudo serve perche' in questa immagine crontab e' busybox senza suid)

SUGGERIMENTI — i comandi di questo lab
  La pipe | passa l'output di un comando all'input del successivo.
  - top -b -n 1:  snapshot del carico del sistema. In modalita batch (-b) non e'
            interattivo, quindi si puo' salvare in un file; -n 1 = un solo giro.
  - free -h:  mostra memoria e swap in formato leggibile.
            -h (human readable) = dimensioni in K/M/G invece di byte.
  - openrc --version:  stampa la versione dell'init OpenRC (una riga, tipo
            "openrc (OpenRC [DOCKER]) 0.63.2").
            | head -n 1   = tiene solo la prima riga di un output.
  - logger:  scrive un messaggio nel log di sistema. L'ambiente ne ha gia'
            inviato uno all'avvio con l'etichetta -t @V_LOG_TAG@; il daemon
            syslogd lo salva nel file /var/log/messages.
  - grep @V_LOG_TAG@ /var/log/messages:  filtra il log di sistema per
            trovare proprio quel messaggio. /var/log/messages e' il classico
            file di log di qualsiasi sistema Unix-like, anche senza systemd.
  - sudo -u @V_USER@ whoami:  esegue un comando come un altro utente.
            sudo = esegui come amministratore; -u @V_USER@ = come utente @V_USER@;
            whoami = "chi sono io" (stampa il nome utente).
            Risultato atteso: @V_USER@.
  - crontab <file>:  installa un file come tabella cron (comandi pianificati).
            crontab @V_CRON_FILE@ = registra le righe di @V_CRON_FILE@.
  - crontab -l:  legge la tabella cron corrente (List).
            crontab -l > @V_OUT_CRON@ = salvala in un file per la verifica.
  (In questa immagine crontab e' busybox senza suid: per lo studente non-root
   serve 'sudo crontab' / 'sudo crontab -l', come nei TASK; la tabella
   installata con sudo e' quella di sistema e -l la rilegge identica.)

VERIFY
  lab check 08-system-admin

NOTE
  L'utente @V_USER@ NON devi crearlo tu a mano: e' gia' nell'immagine, pronto
  all'avvio del container. Se provi a fare 'useradd -m @V_USER@' ricevi un errore
  "user '@V_USER@' already exists": non e' un problema, l'utente c'e' gia'.
  Valori di riferimento:
  - @V_OUT_SUDO@ deve contenere esattamente "@V_USER@".
  - @V_OUT_VER@ deve iniziare con "openrc".
  - @V_OUT_SYS@ deve contenere la riga con "@V_LOG_TAG@".
  - @V_OUT_CRON@ deve contenere la riga "@V_CRON_LINE@".
  In questa immagine l'init NON e' systemd: non esistono nede systemctl ne'
  journalctl. Il sistema di init e' OpenRC (comando: openrc) e i log passano
  per syslogd/logger col classico file /var/log/messages. Nel container non
  gestiamo servizi reali: il lab usa openrc e i log per riconoscere gli
  strumenti e leggere le informazioni.
  Attenzione: utente @V_USER@, daemon di log e crontab sono STATO DI SISTEMA
  (transitorio). Esegui i comandi e subito dopo lab check 08-system-admin
  NELLA STESSA SESSIONE, senza chiudere il terminale. Se riavvii il container,
  @V_USER@ e crontab spariscono e il check fallisce su quei controlli (i file
  di output su /workspace invece restano).