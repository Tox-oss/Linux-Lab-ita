LAB 08 - system administration signals

OBIETTIVO
  Raccogliere snapshot di sistema e installare una crontab di training.

WORKDIR
  cd ${LAB_TRAINING_ROOT:-/workspace/training}/admin-lab
  (L'utente auditor, il daemon di log e il file nightly.cron li crea il reset:
  lab start 08-system-admin)

DATI — cosa ti prepara il reset
  Il comando lab start 08-system-admin crea e prepara per te:
    - l'utente di sistema "auditor" (non devi crearlo tu)
    - il daemon di log (syslogd) attivo e un messaggio di sistema marcato
      "assisted-lab" scritto con logger (lo userai nel TASK 4)
    - il file nightly.cron nella cartella di lavoro:
        admin-lab/nightly.cron
        contenuto: 17 3 * * * /usr/local/bin/lab doctor >/tmp/lab-doctor.log 2>&1
  Tu dovrai installare nightly.cron nella tabella cron del sistema (vedi TASK 6).

AVVIO
  Avvia il lab e vai nel WORKDIR:
    lab start 08-system-admin
    cd ${LAB_TRAINING_ROOT:-/workspace/training}/admin-lab
  IMPORTANTE: questa e' una sessione unica. Esegui i comandi e subito dopo il
  lab check NELLA STESSA SESSIONE, senza chiudere il terminale (vedi NOTE).

TASK
  1. Salva uno snapshot batch di top in top_snapshot.txt
     IMPORTANTE: top di default e' interattivo e blocca il terminale.
     Usa:  top -b -n 1 > top_snapshot.txt
     (-b = modalita batch, -n 1 = un solo snapshot)
  2. Salva lo stato memoria leggibile in memory_report.txt
  3. Salva la prima riga di openrc --version in openrc_version.txt
     (openrc e' il sistema di init di questa immagine)
  4. Recupera dal log di sistema il messaggio inviato dal reset con logger e
     salva le righe che lo contengono in syslog_snapshot.txt
     Usa:  grep assisted-lab /var/log/messages > syslog_snapshot.txt
  5. Esegui whoami come utente auditor tramite sudo e salva l'output in sudo_user.txt
     (l'utente auditor esiste gia': te lo crea il reset)
  6. Installa offline il file nightly.cron nella tabella cron con:
       crontab nightly.cron
     poi salva la tabella appena installata in installed_cron.txt con:
       crontab -l > installed_cron.txt

SUGGERIMENTI — i comandi di questo lab
  La pipe | passa l'output di un comando all'input del successivo.
  - top -b -n 1:  snapshot del carico del sistema. In modalita batch (-b) non e'
            interattivo, quindi si puo' salvare in un file; -n 1 = un solo giro.
  - free -h:  mostra memoria e swap in formato leggibile.
            -h (human readable) = dimensioni in K/M/G invece di byte.
  - openrc --version:  stampa la versione dell'init OpenRC (una riga, tipo
            "openrc (OpenRC [DOCKER]) 0.63.2").
            | head -n 1   = tiene solo la prima riga di un output.
  - logger:  scrive un messaggio nel log di sistema. Il reset ne ha gia'
            inviato uno con l'etichetta -t assisted-lab; il daemon syslogd lo
            salva nel file /var/log/messages.
  - grep assisted-lab /var/log/messages:  filtra il log di sistema per
            trovare proprio quel messaggio. /var/log/messages e' il classico
            file di log di qualsiasi sistema Unix-like, anche senza systemd.
  - sudo -u auditor whoami:  esegue un comando come un altro utente.
            sudo = esegui come amministratore; -u auditor = come utente auditor;
            whoami = "chi sono io" (stampa il nome utente).
            Risultato atteso: auditor.
  - crontab <file>:  installa un file come tabella cron (comandi pianificati).
            crontab nightly.cron = registra le righe di nightly.cron.
  - crontab -l:  legge la tabella cron corrente (List).
            crontab -l > installed_cron.txt = salvala in un file per la verifica.

VERIFY
  lab check 08-system-admin

NOTE
  L'utente auditor NON devi crearlo tu a mano: te lo crea il reset (lab start
  08-system-admin). Se provi a fare 'useradd -m auditor' ricevi un errore
  "user 'auditor' already exists": non e' un problema, l'utente c'e' gia'.
  Valori di riferimento:
  - sudo_user.txt deve contenere esattamente "auditor".
  - openrc_version.txt deve iniziare con "openrc".
  - syslog_snapshot.txt deve contenere la riga con "assisted-lab".
  - installed_cron.txt deve contenere la riga "17 3 * * * /usr/local/bin/lab doctor...".
  In questa immagine l'init NON e' systemd: non esistono nede systemctl ne'
  journalctl. Il sistema di init e' OpenRC (comando: openrc) e i log passano
  per syslogd/logger col classico file /var/log/messages. Nel container non
  gestiamo servizi reali: il lab usa openrc e i log per riconoscere gli
  strumenti e leggere le informazioni.
  Attenzione: utente auditor, daemon di log e crontab sono STATO DI SISTEMA
  (transitorio). Esegui i comandi e subito dopo lab check 08-system-admin
  NELLA STESSA SESSIONE, senza chiudere il terminale. Se riavvii il container,
  auditor e crontab spariscono e il check fallisce su quei controlli (i file
  di output su /workspace invece restano).