LAB 04 — processes

OBIETTIVO
  Processo in background, salvare il PID, verificarlo con ps.

WORKDIR
  cd ${LAB_TRAINING_ROOT:-/workspace/training}/@V_DIR@
  (il reset svuota la cartella di lavoro: lab start 04-processes)

DATI — stato di partenza
  Nessun file creato dal reset: la cartella @V_DIR@ e' vuota.
  Non esiste alcun processo: lo avvii tu (sleep @V_SLEEP@).

AVVIO
  Avvia il lab e vai nel WORKDIR:
    lab start 04-processes
cd ${LAB_TRAINING_ROOT:-/workspace/training}/@V_DIR@

TASK
  1. Avvia in background: sleep @V_SLEEP@
  2. Salva il PID in @V_PID@
  3. Crea il file @V_STATUS@ e scrivi DENTRO il file il testo: "@V_TEXT@"
  4. Controlla a mano con ps che il PID esista

SUGGERIMENTI — background, PID e ps
  - PID = Process ID: il numero univoco che il kernel assegna a ogni processo.
  - Il simbolo & a fine comando avvia il processo in BACKGROUND: la shell
    resta libera per i comandi successivi. Esempio:  sleep @V_SLEEP@ &
  - La variabile speciale $! contiene il PID dell'ultimo comando lanciato in
    background. Lo salvi in un file con la redirect:
      sleep @V_SLEEP@ &
      echo $! > @V_PID@
  - ps: mostra i processi. Per verificare che il PID salvato esista:
      ps -p "$(cat @V_PID@)" -o pid,comm,args
  - kill -0 PILOTA esistenza senza terminare:
      kill -0 "$(cat @V_PID@)" 2>/dev/null && echo "Attivo"
  - Per scrivere @V_STATUS@:  printf '@V_TEXT@\n' > @V_STATUS@   oppure   echo '@V_TEXT@' > @V_STATUS@

ATTENZIONE SUBSHELL
  Se scrivi:   cd ... && sleep @V_SLEEP@ &
  il & mette in background TUTTA la riga, quindi $! e' la subshell, non sleep.
  Il check fallira' con "PID non e' sleep".

  Effetto visibile subito: tutto quello che viene dopo il & sulla stessa riga
  (echo, printf, i file che crei) continua a girare NELLA CARTELLA DOVE ERI,
  non nella cartella del lab: se lo fai, @V_PID@ e @V_STATUS@ finiscono
  fuori posto (per es. in /workspace). Il check te lo segnala da solo e il
  recupero e' automatico, ma per evitarlo separa i comandi come sotto.

  CORRETTO (due righe separate):
    cd /workspace/training/@V_DIR@
    sleep @V_SLEEP@ &          # qui $! e' davvero sleep

  OPPURE (separando con ;):
    cd /workspace/training/@V_DIR@ ; sleep @V_SLEEP@ &

VERIFY
  lab check 04-processes

NOTE
  @V_STATUS@ e' un documento di TESTO: va creato e al suo interno va scritta
  la stringa "@V_TEXT@" (senza virgolette). Crearlo vuoto NON basta:
    echo '@V_TEXT@' > @V_STATUS@   oppure   printf '@V_TEXT@\n' > @V_STATUS@
  IMPORTANTE: il processo sleep @V_SLEEP@ e' STATO DI SISTEMA (transitorio).
  Lancia sleep in background e subito dopo lancia lab check 04-processes NELLA
  STESSA SESSIONE, senza chiudere il terminale: se riavvii il container il
  processo non esiste piu' (@V_PID@ resta, ma il check fallira' su "processo vivo").
  lab reset 04-processes uccide il sleep residuo.
  Il worker vive ~1 ora e muore col container: se un check successivo
  fallisce per "processo non vivo", rilancia: lab start 04-processes.
  ATTENZIONE al background: 'cd ... && sleep @V_SLEEP@ &' mette in background
  l'intera lista (cd && sleep), quindi $! e' la subshell, non sleep.
  Separa con ';' oppure lancia sleep da solo:
  cd ${LAB_TRAINING_ROOT:-/workspace/training}/@V_DIR@
  sleep @V_SLEEP@ &
  echo $! > @V_PID@
