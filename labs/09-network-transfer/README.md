LAB 09 - network and transfers

OBIETTIVO
  Ispezionare rete locale, verificare connettivita e copiare dati con strumenti comuni.

WORKDIR
  cd ${LAB_TRAINING_ROOT:-/workspace/training}/@V_DIR@
  (I dati @V_REMOTE@/ e il listener sulla porta @V_PORT@ te li crea il reset: lab start 09-network-transfer)

DATI — struttura del WORKDIR (dopo il reset)
  @V_DIR@/
    @V_REMOTE@/
      @V_JSON@      <- il file che copierai (via curl, scp, rsync)
      @V_NESTED@/@V_INFO@  <- file dentro la sottocartella (per rsync)
  La porta locale @V_PORT@ e' in ascolto sull'indirizzo 127.0.0.1 (lo avvia il reset).

AVVIO
  Avvia il lab e vai nel WORKDIR:
    lab start 09-network-transfer
    cd ${LAB_TRAINING_ROOT:-/workspace/training}/@V_DIR@
  IMPORTANTE: questa e' una sessione unica. Esegui i comandi e subito dopo il
  lab check NELLA STESSA SESSIONE, senza chiudere il terminale (vedi NOTE).

TASK
  1. Salva il CIDR IPv4 dell'interfaccia loopback in @V_OUT_CIDR@
  2. Usa ss per trovare la porta locale @V_PORT@ in ascolto e salva la riga in @V_OUT_LIS@
  3. Esegui un ping singolo a 127.0.0.1 e salva l'output in @V_OUT_PING@
  4. Usa curl per leggere @V_REMOTE@/@V_JSON@ via file:// e salva il risultato in @V_OUT_FETCH@
  5. Salva la versione del client ssh in @V_OUT_SSH@
  6. Copia @V_REMOTE@/@V_JSON@ in @V_COPIES@/@V_SCP@ usando scp
     (prima crea la cartella di destinazione:  mkdir -p @V_COPIES@)
  7. Sincronizza @V_REMOTE@/ dentro @V_MIRROR@/ usando rsync
     (prima crea la cartella di destinazione:  mkdir -p @V_MIRROR@)

SUGGERIMENTI — i comandi di questo lab
  La pipe | passa l'output di un comando all'input del successivo.
  - ip -o -4 addr show lo:  mostra l'indirizzo IPv4 dell'interfaccia "lo"
            (loopback) in formato one-line (-o). Il campo CIDR e' la 4a colonna,
            quindi:  ip -o -4 addr show lo | awk '{print $4}'
            awk = strumento di analisi testo; '{print $4}' = stampa la 4a colonna.
            Risultato atteso: 127.0.0.1/8
  - ss -ltn:  elenca le porte in ascolto (listening). Insieme a grep filtra:
            ss -ltn | grep ':@V_PORT@'
            -l = listening (in ascolto); -t = TCP; -n = numerico (no nomi);
            grep ':@V_PORT@' = tiene solo la riga che contiene la porta @V_PORT@.
  - ping -c 1 127.0.0.1:  manda un singolo pacchetto all'indirizzo locale.
            (-c 1 = un solo pacchetto, poi esce)
  - curl -s "file://...":  legge un file locale con la stessa interfaccia delle URL.
            -s = silenzioso (niente barra di progresso). Le virgolette servono per il
            percorso assoluto. Esempio:
            curl -s "file://$PWD/@V_REMOTE@/@V_JSON@" > @V_OUT_FETCH@
  - scp sorgente destinazione:  copia un file (qui tra percorsi locali).
            scp @V_REMOTE@/@V_JSON@ @V_COPIES@/@V_SCP@
  - rsync -a @V_REMOTE@/ @V_MIRROR@/:  sincronizza una cartella in un'altra.
            -a (archive) = copia tutto il contenuto preservando attributi.
            La slash finale di @V_REMOTE@/ indica "il contenuto della cartella", non la
            cartella stessa: @V_MIRROR@/ riceve @V_JSON@ e @V_NESTED@/, non @V_REMOTE@/.

NOTE RETE
  - ping su Linux non si ferma da solo (a differenza di Windows).
    Usa sempre:  ping -c 1 127.0.0.1
    (-c 1 = un solo pacchetto, poi esce)
  - ssh -V stampa la versione su STDERR (non stdout).
    Per salvarla in un file devi fare il redirect:
      ssh -V > @V_OUT_SSH@ 2>&1
    Senza 2>&1 il file resta vuoto (0 byte).

VERIFY
  lab check 09-network-transfer

NOTE
  IMPORTANTE: il listener sulla porta locale @V_PORT@ e' un PROCESSO (transitorio).
  Lo avvia da solo il reset (lab start 09-network-transfer), non devi crearlo tu.
  Pero' muore appena chiudi il container: esegui i comandi del punto 2 e subito
  dopo lab check 09-network-transfer NELLA STESSA SESSIONE, senza chiudere il
  terminale. Se riavvii il container la porta non e' piu' in ascolto e quindi
  il check fallira' sul controllo ":@V_PORT@" (i file che hai generato su /workspace
  invece restano).
  Valori di riferimento:
  - @V_OUT_CIDR@ = "127.0.0.1/8"
  - @V_OUT_LIS@ deve contenere "127.0.0.1:@V_PORT@"
  - @V_OUT_FETCH@ deve essere identico a @V_REMOTE@/@V_JSON@
    ({"service":"@V_SVC@","status":"ok","port":@V_PORT@})
  - @V_OUT_SSH@ deve iniziare con "OpenSSH_"
  - @V_COPIES@/@V_SCP@ e @V_MIRROR@/@V_JSON@ devono copiare @V_REMOTE@/@V_JSON@
  Non serve Internet e non serve un server SSH remoto.
  ssh viene usato per riconoscere il client; scp e rsync lavorano su copie locali.
