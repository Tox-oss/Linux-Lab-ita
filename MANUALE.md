# Assisted Linux Labs

Terminale grezzo. Esercizi Linux hands-on. Niente GUI.

## Avvio (dall'host)

Per usare `lab quit` e chiudere anche la finestra GNOME Terminal:

```bash
./run-assisted-labs.sh
```

L'avvio diretto con `docker run` chiude il container, ma non può chiudere la
finestra del terminale dell'host.

```bash
# build
cd ~/assisted-labs
docker build -t alpine-latest-assisted-labs:latest .

# run interattivo con volume persistente
docker run --rm -it \
  --name assisted-labs \
  -v Alpine_Latest:/workspace \
  alpine-latest-assisted-labs:latest
```

Entri in una shell bash. Appare il banner di benvenuto.

**Prima azione**: digita `lab list` per vedere i laboratori disponibili.

> Nota: se digiti solo `lab` senza argomenti, si apre il menu di scelta della
> modalità (`standard` / `arcade` / ...). Per il corso ti basta la modalità
> **standard** (quella attiva di default): premi `invio` per confermarla e poi
> usa `lab list`.

Il volume `Alpine_Latest` monta `/workspace`: i file in
`/workspace/training` restano tra una sessione e l'altra.
I lab ufficiali stanno in `/opt/assisted-labs` (immagine), non sul volume.

## Persistente vs transitorio (leggilo prima di iniziare)

Dentro il container hai due tipi di "memoria": una **resiste**, l'altra **no**.

**PERSISTENTE — sopravvive quando chiudi e riapri il container (il volume):**
- Tutti i file e le cartelle che crei dentro `/workspace/training` (i WORKDIR dei lab).
  Es: `project/notes.txt`, `worker.pid`, `restore/`, ecc.
- Anche lo stato `lab` (quali lab sono DONE) vive lì sotto `.lab-state`.

**TRANSITORIO — si azzera appena chiudi il container:**
- Utenti e gruppi creati con `useradd`, `groupadd`, `usermod`.
- Processi in background avviati con `&` (es. `sleep 3600 &`).
- Crontab installate con `crontab` e modifiche a file di sistema (`/etc/*`).
- Listener/servizi di rete avviati dal reset (es. la porta 8088 del lab 09).

> **Regola d'oro**: nei lab che toccano lo stato di sistema (`03-users-groups`,
> `04-processes`, `08-system-admin`, `09-network-transfer`) esegui i comandi e
> subito dopo `lab check <id>` **nella stessa sessione**, senza chiudere il
> terminale. Se chiudi e riavvii, utenti/gruppi/processi/crontab sono spariti e
> il check fallirà su quei controlli — anche se i tuoi file su `/workspace`
> ci sono ancora. Non serve "ricreare" tutto ogni volta per errore: basta non
> chiudere la sessione prima della verifica.

## Dentro il container

```text
lab                 aiuto
lab list            elenco esercizi
lab start <id>      reset + consegna
lab task  <id>      rivedi consegna (no reset)
lab check <id>      valida  — NON cancella i tuoi file
lab hint  <id>      indizio uno alla volta
lab hint  <id> --all
lab solution <id>   soluzione di riferimento
lab reset <id>      azzera SOLO quel lab
lab status          avanzamento
lab mode <nome>     cambi/vedi modalita (standard/arcade/hardcade)
lab anim <nome>     anteprima animazioni (fireworks, rain, all)
lab doctor          diagnosi
lab quit            chiudi la sessione
```

> Questi comandi valgono per la **modalità apprendimento (standard)**,
> quella usata durante tutto il corso. Le modalità **arcade** e **hardcade**
> sono un **gioco/easter egg a parte** — vedi sotto "Modalità gioco".

## Flusso di studio

1. `lab list`  (colonna TEMA: capisci l'argomento di ogni lab)
2. `lab start 01-filesystem`
3. `cd` nel WORKDIR della consegna
4. Esegui i comandi a mano (usa `nano` se serve editare)
5. `lab check 01-filesystem`
6. Se fallisce: `lab hint 01-filesystem` — il lavoro resta
   (gli hint sono graduati: concetto → strategia → comando)
7. `lab solution` solo a fine corsa

## Dettagli utili

- **Hint a 4 livelli progressivi**: ogni esercizio offre almeno 3-4 indizi strutturati:
  1. `[CONCETTO]`: teoria e meccanismi interni di Linux.
  2. `[STRATEGIA & BEST PRACTICES]`: flusso logico e accorgimenti operativi.
  3. `[COMANDI GUIDATI]`: sintassi concreta con metodi equivalenti.
  4. `[VERIFICA MANUALE]`: comandi diagnostici per testare il lavoro prima del check.
  Usa `lab hint <id>` per avanzare di un livello o `lab hint <id> --all` per vederli tutti.
- **Rilevamento percorsi errati**: se crei accidentalmente file o cartelle nella directory sbagliata (es. `/workspace` invece del WORKDIR del lab), `lab check` te lo segnala con un avviso dettagliato senza rimuovere dati. Spostali o cancellali manualmente dopo aver verificato il percorso.
- **Commessa vs Mezzi**: i check validano lo stato finale del sistema con la massima flessibilità (tolleranza su spaziature, newline, comandi alternativi come `printf` vs `echo` vs `nano`).
- **Ripasso**: dopo un `lab check` OK appare il blocco `PERCHE FUNZIONA` con i concetti chiave del lab.
- **`lab status`** mostra tema, stato e data di completamento.
- **`lab doctor`** verifica tutti i tool usati dai lab (stat, sort, uniq, wc, cp, mv, rm, groupadd, useradd, usermod, getent, pgrep, sleep, ...).

## Regole per lo studio (modalità standard)

Questa è la modalità di **apprendimento** del corso: quella che usi per imparare
i lab in ordine (01 → 09).

- `check` non cancella il tuo lavoro valido. Solo `start` e `reset` azzerano un lab.
- Quando un check fallisce, `lab` ti mostra subito quale comando
  correggere (`X`) e come verificare il risultato (`Y`) per ogni controllo mancante, così
  impari sbagliando in scioltezza e senza frustrazione.
- I percorsi creati nel posto sbagliato NON vengono rimossi dal check: `lab check`
  li segnala con un avviso e ti mostra il comando `rm -rf` da eseguire a mano.
  Il check non cancella mai dati da solo.
- Non mettere copie dei lab sotto `/workspace/assisted-labs`: confondono. Runtime = solo `/opt/assisted-labs`.
- Se il cwd sparisce dopo un reset: `cd /workspace`.

## Modalità gioco (arcade / hardcade) — easter egg, NON è il corso

**Arcade** e **hardcade** sono un **gioco opzionale nascosto**, separato dallo
studio standard. Non serve giocarci per completare il corso: è un divertimento
per chi, dopo aver finito i 9 lab, vuole mettersi alla prova.

- **`lab mode arcade`** — sfida a 3 vite (❤️ ❤️ ❤️): ogni errore costa un cuore;
  se finisci le vite parte il "Game Over". Mette alla prova le conoscenze già
  apprese, non insegna materiale nuovo.
- **HARDCADE è un secondo easter egg, ancora più nascosto**: si sblocca solo
  completando **tutti i 9 lab in modalità ARCADE senza mai perdere un cuore**
  (run perfetta). Al primo accesso appare un'intro ASCII "matrix rain".
  Puoi sbloccarlo in ogni momento a scopo dimostrativo con
  `LAB_EH_UNLOCK=1 lab mode hardcade` oppure `lab mode hardcade --force`.
- `hardcade` usa un salvataggio separato `/workspace/training/.hardcade-state`
  e la sua area di lavoro `/workspace/hardcade-training` (non tocca i tuoi lab
  standard). Una volta entrati non è possibile tornare a standard o arcade nella
  stessa sessione; al terzo errore i progressi Hardcade vengono azzerati e il
  terminale viene chiuso.
- **Riepilogo**: `standard` = imparare · `arcade` = sfida · `hardcade` = easter egg.
  Si cambia modalità con `lab mode <nome>` (es. `lab mode arcade`), ma per seguire
  il corso ti basta e ti avanza la modalità **standard**.

## Effetto di fine corso (9 su 9)

Quando completi tutti i 9 lab, il `lab check` dell'ultimo esercizio mostra
l'effetto di fine corso: **fuochi d'artificio ASCII multicolore** (razzi che
salgono dal basso ed esplodono in raggiere radiali + pioggia di confetti) e il
banner **"COMPLETATI 9/9 LABORATORI!"**,
seguiti dalla schermata di **congratulazioni** con la scelta di ripartire da
zero o continuare.

- Per vedere gli effetti in anteprima senza doverli sbloccare: `lab anim`
  (`lab anim fireworks`, `lab anim rain`, `lab anim all`).
- Le animazioni richiedono un **terminale (TTY)**: su output reindirizzati
  (es. `make test`) vengono saltate per non intralciare.
- L'effetto di fine corso è pensato per la modalità **standard**; arcade e
  hardcade hanno il loro flusso (Game Over / reset dedicato).

## Lab

| id | tema | stato |
|----|------|-------|
| 01-filesystem | mkdir, mv, cp, rm | persistente |
| 02-permissions | chmod | persistente |
| 03-users-groups | useradd, groupadd, chown | ⚠️ sistema (transitorio) |
| 04-processes | background, PID, ps | ⚠️ sistema (transitorio) |
| 05-text-processing | grep, sort, awk | persistente |
| 06-navigation-search | ls, cd, pwd, find, less, tail | persistente |
| 07-storage-archives | df, du, tar | persistente |
| 08-system-admin | top, free, openrc, logger, sudo, crontab | ⚠️ sistema (transitorio) |
| 09-network-transfer | ip, ss, ping, curl, ssh, scp, rsync | ⚠️ sistema (transitorio) |

> **⚠️** = lab che toccano lo **stato di sistema (transitorio)**: applica la
> **Regola d'oro** (esegui i comandi e `lab check <id>` **nella stessa sessione**).
> Per i lab "persistente" puoi chiudere e riaprire quando vuoi: i tuoi file su
> `/workspace` restano.
