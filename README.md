# Linux-Lab

Terminale grezzo. 9 laboratori Linux hands-on. Niente GUI.

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
lab list          # elenco dei 9 lab
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
make test    # esegue tutti i 9 lab in modalità anti-cheat
```

## I 9 laboratori

| id | tema |
|----|------|
| 01-filesystem | mkdir, mv, cp, rm |
| 02-permissions | chmod |
| 03-users-groups | useradd, groupadd, chown |
| 04-processes | background, PID, ps |
| 05-text-processing | grep, sort, awk |
| 06-navigation-search | ls, cd, pwd, find, less, tail |
| 07-storage-archives | df, du, tar |
| 08-system-admin | top, free, systemctl, journalctl, sudo, crontab |
| 09-network-transfer | ip, ss, ping, curl, ssh, scp, rsync |

- **Persistenti**: i lab 01, 02, 05, 06, 07 salvano tutto in `/workspace`.
- **Sistema (transitorio)**: i lab 03, 04, 08, 09 toccano lo stato del sistema
  (utenti, processi, servizi): esegui i comandi e `lab check` nella stessa
  sessione, senza chiudere il container.

## Comandi dentro il container

```text
lab                aiuto
lab list           elenco esercizi
lab start <id>     reset + consegna
lab task  <id>     rivedi consegna (no reset)
lab check <id>     valida il lavoro
lab hint  <id>     indizio graduale (concetto → strategia → comando)
lab solution <id>  soluzione di riferimento
lab reset <id>     azzera SOLO quel lab
lab status         avanzamento
lab mode <nome>    standard / arcade / hardcade
lab doctor         diagnosi dei tool
lab quit           chiudi la sessione
```

## Modalità di gioco (easter egg)

La modalità **standard** è quella del corso (tentativi illimitati e indizi
gratuiti). **Arcade** e **hardcade** sono un gioco opzionale nascosto,
separato dallo studio: non servono per completare i 9 lab.

- **Arcade** — sfida a 3 vite (`lab mode arcade`). Ogni errore costa un
  cuore. Gli indizi sono limitati (3 lampadine per lab): **il primo indizio
  è gratuito, dal secondo in poi ogni `lab hint` costa 1 vita**.
- **HARDCADE** — seconda sfida segreta, sbloccata da una run ARCADE perfetta
  (tutti i 9 lab senza perdere cuori). 3 errori condivisi per sessione:
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