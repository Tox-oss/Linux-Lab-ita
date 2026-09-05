LAB 09 - network and transfers

OBIETTIVO
  Ispezionare rete locale, verificare connettivita e copiare dati con strumenti comuni.

WORKDIR
  cd ${LAB_TRAINING_ROOT:-/workspace/training}/net-lab
  (I dati remote/ e il listener sulla porta 8088 te li crea il reset: lab start 09-network-transfer)

DATI — struttura del WORKDIR (dopo il reset)
  net-lab/
    remote/
      status.json      <- il file che copierai (via curl, scp, rsync)
      nested/info.txt  <- file dentro la sottocartella (per rsync)
  La porta locale 8088 e' in ascolto sull'indirizzo 127.0.0.1 (lo avvia il reset).

AVVIO
  Avvia il lab e vai nel WORKDIR:
    lab start 09-network-transfer
    cd ${LAB_TRAINING_ROOT:-/workspace/training}/net-lab
  IMPORTANTE: questa e' una sessione unica. Esegui i comandi e subito dopo il
  lab check NELLA STESSA SESSIONE, senza chiudere il terminale (vedi NOTE).

TASK
  1. Salva il CIDR IPv4 dell'interfaccia loopback in loopback_cidr.txt
  2. Usa ss per trovare la porta locale 8088 in ascolto e salva la riga in listening_8088.txt
  3. Esegui un ping singolo a 127.0.0.1 e salva l'output in ping_localhost.txt
  4. Usa curl per leggere remote/status.json via file:// e salva il risultato in fetched_status.json
  5. Salva la versione del client ssh in ssh_version.txt
  6. Copia remote/status.json in copies/status.scp.json usando scp
     (prima crea la cartella di destinazione:  mkdir -p copies)
  7. Sincronizza remote/ dentro mirror/ usando rsync
     (prima crea la cartella di destinazione:  mkdir -p mirror)

SUGGERIMENTI — i comandi di questo lab
  La pipe | passa l'output di un comando all'input del successivo.
  - ip -o -4 addr show lo:  mostra l'indirizzo IPv4 dell'interfaccia "lo"
            (loopback) in formato one-line (-o). Il campo CIDR e' la 4a colonna,
            quindi:  ip -o -4 addr show lo | awk '{print $4}'
            awk = strumento di analisi testo; '{print $4}' = stampa la 4a colonna.
            Risultato atteso: 127.0.0.1/8
  - ss -ltn:  elenca le porte in ascolto (listening). Insieme a grep filtra:
            ss -ltn | grep ':8088'
            -l = listening (in ascolto); -t = TCP; -n = numerico (no nomi);
            grep ':8088' = tiene solo la riga che contiene la porta 8088.
  - ping -c 1 127.0.0.1:  manda un singolo pacchetto all'indirizzo locale.
            (-c 1 = un solo pacchetto, poi esce)
  - curl -s "file://...":  legge un file locale con la stessa interfaccia delle URL.
            -s = silenzioso (niente barra di progresso). Le virgolette servono per il
            percorso assoluto. Esempio:
            curl -s "file://$PWD/remote/status.json" > fetched_status.json
  - scp sorgente destinazione:  copia un file (qui tra percorsi locali).
            scp remote/status.json copies/status.scp.json
  - rsync -a remote/ mirror/:  sincronizza una cartella in un'altra.
            -a (archive) = copia tutto il contenuto preservando attributi.
            La slash finale di remote/ indica "il contenuto della cartella", non la
            cartella stessa: mirror/ riceve status.json e nested/, non remote/.

NOTE RETE
  - ping su Linux non si ferma da solo (a differenza di Windows).
    Usa sempre:  ping -c 1 127.0.0.1
    (-c 1 = un solo pacchetto, poi esce)
  - ssh -V stampa la versione su STDERR (non stdout).
    Per salvarla in un file devi fare il redirect:
      ssh -V > ssh_version.txt 2>&1
    Senza 2>&1 il file resta vuoto (0 byte).

VERIFY
  lab check 09-network-transfer

NOTE
  IMPORTANTE: il listener sulla porta locale 8088 e' un PROCESSO (transitorio).
  Lo avvia da solo il reset (lab start 09-network-transfer), non devi crearlo tu.
  Pero' muore appena chiudi il container: esegui i comandi del punto 2 e subito
  dopo lab check 09-network-transfer NELLA STESSA SESSIONE, senza chiudere il
  terminale. Se riavvii il container la porta non e' piu' in ascolto e quindi
  il check fallira' sul controllo ":8088" (i file che hai generato su /workspace
  invece restano).
  Valori di riferimento:
  - loopback_cidr.txt = "127.0.0.1/8"
  - listening_8088.txt deve contenere "127.0.0.1:8088"
  - fetched_status.json deve essere identico a remote/status.json
    ({"service":"training-api","status":"ok","port":8088})
  - ssh_version.txt deve iniziare con "OpenSSH_"
  - copies/status.scp.json e mirror/status.json devono copiare remote/status.json
  Non serve Internet e non serve un server SSH remoto.
  ssh viene usato per riconoscere il client; scp e rsync lavorano su copie locali.
