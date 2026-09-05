LAB 04 — processes

OBIETTIVO
  Processo in background, salvare il PID, verificarlo con ps.

WORKDIR
  cd ${LAB_TRAINING_ROOT:-/workspace/training}/process-lab
  (il reset svuota la cartella di lavoro: lab start 04-processes)

DATI — stato di partenza
  Nessun file creato dal reset: la cartella process-lab e' vuota.
  Non esiste alcun processo: lo avvii tu (sleep 3600).

AVVIO
  Avvia il lab e vai nel WORKDIR:
    lab start 04-processes
    cd ${LAB_TRAINING_ROOT:-/workspace/training}/process-lab

TASK
  1. Avvia in background: sleep 3600
  2. Salva il PID in worker.pid
  3. Crea il file status.txt e scrivi DENTRO il file il testo: "running"
  4. Controlla a mano con ps che il PID esista

SUGGERIMENTI — background, PID e ps
  - PID = Process ID: il numero univoco che il kernel assegna a ogni processo.
  - Il simbolo & a fine comando avvia il processo in BACKGROUND: la shell
    resta libera per i comandi successivi. Esempio:  sleep 3600 &
  - La variabile speciale $! contiene il PID dell'ultimo comando lanciato in
    background. Lo salvi in un file con la redirect:
      sleep 3600 &
      echo $! > worker.pid
  - ps: mostra i processi. Per verificare che il PID salvato esista:
      ps -p "$(cat worker.pid)" -o pid,comm,args
  - kill -0 PILOTA esistenza senza terminare:
      kill -0 "$(cat worker.pid)" 2>/dev/null && echo "Attivo"
  - Per scrivere status.txt:  printf 'running\n' > status.txt   oppure   echo 'running' > status.txt

ATTENZIONE SUBSHELL
  Se scrivi:   cd ... && sleep 3600 &
  il & mette in background TUTTA la riga, quindi $! e' la subshell, non sleep.
  Il check fallira' con "PID non e sleep".

  CORRETTO (due righe separate):
    cd /workspace/training/process-lab
    sleep 3600 &          # qui $! e' davvero sleep

  OPPURE (separando con ;):
    cd /workspace/training/process-lab ; sleep 3600 &

VERIFY
  lab check 04-processes

NOTE
  status.txt e' un documento di TESTO: va creato e al suo interno va scritta
  la stringa "running" (senza virgolette). Crearlo vuoto NON basta:
    echo 'running' > status.txt   oppure   printf 'running\n' > status.txt
  IMPORTANTE: il processo sleep 3600 e' STATO DI SISTEMA (transitorio).
  Lancia sleep in background e subito dopo lancia lab check 04-processes NELLA
  STESSA SESSIONE, senza chiudere il terminale: se riavvii il container il
  processo non esiste piu' (worker.pid resta, ma il check fallira' su "processo vivo").
  lab reset 04-processes uccide il sleep residuo.
  Il worker vive ~1 ora e muore col container: se un check successivo
  fallisce per "processo non vivo", rilancia: lab start 04-processes.
  ATTENZIONE al background: 'cd ... && sleep 3600 &' mette in background
  l'intera lista (cd && sleep), quindi $! e' la subshell, non sleep.
  Separa con ';' oppure lancia sleep da solo:
  cd ${LAB_TRAINING_ROOT:-/workspace/training}/process-lab
  sleep 3600 &
  echo $! > worker.pid
