# Linux-Lab

Terminale grezzo. 10 laboratori Linux hands-on. Niente GUI.

Laboratorio pratico di Linux da eseguire in container Docker: esercizi
progressivi su filesystem, permessi, utenti e gruppi, processi, elaborazione
testo, navigazione e ricerca, archivi, amministrazione di sistema e reti.
Ogni lab ha una consegna, verifiche automatiche, suggerimenti graduali e una
soluzione di riferimento.

## Avvio veloce (con Docker)

```bash
# 1. esegui l'immagine (mounta un volume persistente per i tuoi progressi)
docker run --rm -it \
  --name assisted-labs \
  -v Alpine_Latest:/workspace \
  alpine-latest-assisted-labs:latest

# 2. dentro il container
lab list          # elenco dei 10 lab
lab start 01-filesystem
```

> L'immagine `assisted-labs` monta il volume `Alpine_Latest` su `/workspace`:
> i file che crei dentro `/workspace/training` restano tra una sessione e
> l'altra. I lab ufficiali vivono nell'immagine (`/opt`), non sul volume.

## Build locale

```bash
git clone https://github.com/Tox-oss/Linux-Lab.git
cd Linux-Lab
make build   # oppure: docker build -t alpine-latest-assisted-labs:latest .
make run     # sessione interattiva
make test    # esegue tutti i 10 lab in modalità anti-cheat
```

## I 10 laboratori

| id | tema |
|----|------|
| 01-filesystem | mkdir, mv, cp, rm |
| 02-permissions | chmod |
| 03-users-groups | useradd, groupadd, chown |
| 04-processes | background, PID, ps |
| 05-text-processing | grep, sort, awk |
| 06-navigation-search | ls, cd, pwd, find, less, tail |
| 07-storage-archives | df, du, tar |
| 08-system-admin | top, free, openrc, logger, sudo, crontab |
| 09-network-transfer | ip, ss, ping, curl, ssh, scp, rsync |
| 10-file-comparison | diff, cmp, comm |

- **Persistenti**: i lab 01, 02, 05, 06, 07 salvano tutto in `/workspace`.
- **Sistema (transitorio)**: i lab 03, 04, 08, 09 toccano lo stato del sistema
  (utenti, processi, servizi): esegui i comandi e `lab check` nella stessa
  sessione, senza chiudere il container.

## Comandi dentro il container

```text
lab                aiuto (lab help / lab --help)
lab list           elenco esercizi
lab start <id>     reset + consegna
lab task  <id>     rivedi consegna (no reset)
lab check <id>     valida il lavoro
lab hint <id>      indizio graduale (concetto → strategia → comando)
lab -h [<id>]      forma breve di hint; senza id usa il lab corrente
lab class <id>     lezione narrata interattiva sugli argomenti
lab solution <id>  soluzione di riferimento
lab reset <id>     azzera SOLO quel lab
lab status         avanzamento
lab mode <nome>    standard / arcade / hardcade  (-s / -a / -hc)
lab doctor         diagnosi dei tool
lab quit           chiudi la sessione
```

## Battitura dei testi

Le consegne, gli hint e il messaggio di benvenuto scorrono con un effetto
"battitura" lettera per lettera a **0.04 secondi per carattere** (narrativa e
comandi). Se durante lo scorrimento premi **INVIO**, il messaggio viene
mostrato completo all'istante — non devi aspettare la fine. Nei casi in cui
il tempo conta (modalità arcade/hardcade: timer e vite in gioco) la stampa è
sempre istantanea. La velocità è regolabile con le variabili `LAB_TYPE_NARR`
e `LAB_TYPE_CMD` (vedi sotto).

### Evidenziazione dei comandi

Nelle consegne, i comandi Linux (es. `mkdir -p project/docs`, `chmod 600
private.txt`, `grep 'ERROR' access.log | wc -l`) vengono mostrati in **magenta
bold** ad alto contrasto, così risaltano subito rispetto al testo descrittivo
in chiaro. L'utente riconosce a colpo d'occhio cosa digitare nell'esercizio.

### Lezione narrata: `lab class <id>`

`lab class` apre una **lezione narrata interattiva** sugli argomenti del lab:
il testo scorre con la battitura (velocità dedicata `LAB_TYPE_CLASS`, default
**0.03** s/car). All'avvio compare una micro-guida: **INVIO** salta subito
alla frase successiva. Dopo ogni argomento la lezione chiede
**«Ci sono dubbi?»** e l'utente sceglie liberamente cosa approfondire:

- `[0]` → continua con l'argomento successivo (la lezione non è imposta);
- `[N]` → apre la **versione riassuntiva** dell'argomento scelto;
- il menu va in colonna quando le opzioni superano le 76 colonne, così resta
  leggibile anche su terminale 80-col.

Colori della lezione (regole colori del corso): titolo in **cyan** (1;36),
domanda «Ci sono dubbi?» in **giallo** (1;33), argomento corrente del menu in
**verde** (1;32), riassunto in **magenta** (1;35).

**Formato del file `labs/<id>/class.txt`**:

```text
ARGOMENTO: mkdir          ← i nomi non devono contenere virgole
NARRAZIONE: Il comando mkdir crea una directory. Il testo può
proseguire su più righe: vengono ricomposte in un'unica frase.
RIASSUNTO: mkdir [-p] percorso — crea directory.
                           ← riga vuota tra un argomento e il successivo
```

I blocchi `NARRAZIONE` e `RIASSUNTO` possono occupare **più righe** fino al
tag successivo (o alla riga vuota): il parser le ricompone in una frase unica.

## Solo per i test (override velocità battitura)

Chi sviluppa o testa il corso può accelerare o rallentare l'effetto battitura
con due variabili d'ambiente (secondi per carattere):

```bash
LAB_TYPE_NARR=0.01 LAB_TYPE_CMD=0.01 lab task 01-filesystem
```

- `LAB_TYPE_NARR` — velocità dei testi narrati (intro, consegne, hint). Default 0.04
- `LAB_TYPE_CMD` — velocità dei comandi mostrati nei footer e nei digest. Default 0.04
- `LAB_TYPE_CLASS` — velocità della lezione `lab class`. Default 0.03
- Un valore piccolo (es. `0.01`) rende il test praticamente istantaneo.
- Se il terminale non è interattivo (script, CI) la battitura è sempre istantanea.

## Modalità di gioco (easter egg)

La modalità **standard** è quella del corso (tentativi illimitati e indizi
gratuiti). **Arcade** e **hardcade** sono un gioco opzionale nascosto,
separato dallo studio: non servono per completare i 10 lab.

- **Arcade** — sfida a 3 vite (`lab mode arcade`). Ogni errore costa un
  cuore. Gli indizi sono limitati (3 lampadine per lab): **il primo indizio
  è gratuito, dal secondo in poi ogni `lab hint` costa 1 vita**.
- **HARDCADE** — seconda sfida segreta, sbloccata da una run ARCADE perfetta
  (tutti i 10 lab senza perdere cuori). 3 errori condivisi per sessione:
  ogni aiuto (`lab hint`/`lab solution`) consuma 1 errore e disabilita
  l'aiuto per quel lab; al terzo errore la sessione si chiude e il gioco
  riparte. Il salvataggio HARDCADE è separato da quello standard.
  A scopo dimostrativo si entra con `LAB_EH_UNLOCK=1 lab mode hardcade`
  oppure `lab mode hardcade --force`.
- **Uscita**: dentro HARDCADE non si cambia modalità dal menu, ma si esce
  sempre con `lab mode standard --exit` (i progressi STANDARD/ARCADE restano
  intatti). Dopo un Game Over, la prossima esecuzione di `lab` parte in
  modalità standard.

## Requisiti

- Docker (Linux, macOS, oppure Windows con WSL2)

## Manuale dettagliato

Guida estesa (persistenza vs transitorietà, hint, flusso di studio,
risoluzione dei problemi): [MANUALE.md](MANUALE.md)