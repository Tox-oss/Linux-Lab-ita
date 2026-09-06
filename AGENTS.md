# Istruzioni per Agenti e Subagent — Assisted Linux Labs

> Questo file viene **iniettato automaticamente nel contesto di ogni agente** che lavora dentro `~/assisted-labs`. È il contesto condiviso del corso: struttura, convenzioni e staffetta QA. Le procedure operative dettagliate vivono nelle **skill** (vedi indice in basso).

## Contesto Corso

### Struttura del progetto

| Percorso | Contenuto |
|----------|-----------|
| `labs/01-filesystem` … `09-network-transfer` | I 9 lab: ogni cartella ha `README.md` (consegna con AVVIO/DATI/SUGGERIMENTI), `check.sh` (verifica), `reset.sh`, `solution.sh`, `hint.txt`, `theme.txt`, `why.txt` |
| `bin/lab` | CLI del corso (`lab start`, `lab check`, `lab reset`, `lab list`, ...) |
| `lib/common.sh` | Helper condivisi per i check |
| `startup-banner.sh` | Banner di benvenuto nella shell interattiva |
| `Dockerfile` | Immagine riproducibile: Alpine Linux + tool del corso + CLI |
| `Makefile`, `compose.yaml` | Build/run/test |
| `reports/` | Report QA di Lim, Graph e Nux (convenzione nomi in basso) |
| `contexto/` | Contesto compresso in punti chiave della staffetta (permanenza tra le sessioni) |
| `.opencode/skills/` | Skill specializzate degli agenti (indice in basso) |

### Convenzione nomi report

| Tipo report | Nome file |
|-------------|-----------|
| Test Lim (singolo lab) | `reports/<lab>-lim-report.md` |
| Test Lim (giro completo) | `reports/giro-completo-lim-report.md` |
| QA Grafico Graph | `reports/<task>-graph-report.md` |
| Correzione Nux | `reports/<task>-nux-correzione.md` |
| Ritest Lim post-correzione | `reports/<task>-report-ritest.md` |
| Audit comportamentale (effimero) | `reports/<task>-audit-report.md` |

### Memoria di lavoro (Cronista)

Per dare **permanenza e coerenza** tra le sessioni separate della staffetta, l'agente **Cronista**
salva in `contexto/<task>.md` il contesto compresso in punti chiave (obiettivo, stato, criticità,
correzioni, prossimi passi). File:
- `contexto/<task>.md` (es. `contexto/lab-03-users-groups.md`, `contexto/giro-completo.md`)
- Usato per riprendere il lavoro senza rileggere i report completi.
- Cronista è definito come subagent in `.opencode/agent/cronista.md` e **si attiva
  automaticamente** a fine fase Lim, a fine fase Graph e a fine correzione Nux (vedi staffetta).

### Nota transitorietà (lab 03/04/08/09)

Per i lab 03-users-groups, 04-processes, 08-system-admin e 09-network-transfer eseguire i comandi e `lab check` nella **stessa sessione** (lo stato vive nel container).

## Staffetta Lim → Graph → Nux

Ciclo di QA del corso. Orchestrazione completa nella skill `staffetta-lim-gra-nux`.

| Fase | Agente | Skill da caricare | Output |
|------|--------|-------------------|--------|
| 1. Test | Lim | `lim-qa` | Report Qualità |
| — registrazione automatica | **Cronista** | — | `contexto/<task>.md` aggiornato |
| 2. QA grafico | Graph | `graph-qa` | Report QA Grafico |
| — registrazione automatica | **Cronista** | — | `contexto/<task>.md` aggiornato |
| 3. Correzione | Nux | `nux-fix` | Correzioni + Report Correzione |
| — registrazione automatica | **Cronista** | — | `contexto/<task>.md` aggiornato |
| 4. Ritest | Lim | `lim-qa` | Report di ritest |
| — registrazione automatica | **Cronista** | — | `contexto/<task>.md` aggiornato |
| 5. Audit | Auditor | `audit-staffetta` | Audit comportamentale (effimero) |

Il **Cronista** è un subagent che **entra in azione automaticamente a ogni confine di fase**:
non appena Lim salva il report, non appena Graph salva il report, e quando Nux ha finito le
correzioni (e dopo il ritest), il coordinatore invoca il subagent `cronista` per salvare o
aggiornare il contesto compresso in `contexto/` prima di passare alla fase successiva. Offre
permanenza e coerenza tra le sessioni separate della staffetta. Definizione dell'agente in
`.opencode/agent/cronista.md`; sequenza operativa nella skill `staffetta-lim-gra-nux`.

L'**Auditor** (subagent in `.opencode/agent/auditor.md`, skill `audit-staffetta`) chiude il
giro: a staffetta conclusa raccoglie i report degli agenti, estrae i segnali di comportamento
(aderenza alle skill di riferimento, errori procedurali, qualità dei report) e **propone**
miglioramenti alle skill `lim-qa`/`graph-qa`/`nux-fix`. Le proposte non vengono applicate
automaticamente: decide l'utente. Il report `reports/<task>-audit-report.md` è **effimero**:
viene eliminato all'avvio del giro successivo.

## Indice Skill

Le skill vivono in `.opencode/skills/<nome>/SKILL.md`. Ogni agente le carica con il tool `skill` **prima di iniziare il task**:

| Skill | Per chi | Quando |
|-------|---------|--------|
| `staffetta-lim-gra-nux` | coordinatore | per orchestrare il ciclo completo Lim → Graph → Nux |
| `lim-qa` | Lim | prima di testare un lab / giro rapido / ritest |
| `graph-qa` | Graph | prima di analizzare Dockerfile e output CLI |
| `nux-fix` | Nux | prima di prendere in carico i report e correggere |
| `audit-staffetta` | Auditor | a fine staffetta (dopo il ritest, prima del versionamento) per l'audit comportamentale degli agenti |

## Versionamento automatico

**Ogni volta che vengono effettuate modifiche al codice del corso**, eseguire:

```bash
cd ~/assisted-labs && ./versiona.sh
```

Questo script:
1. Tagga l'immagine Docker `latest` corrente con il numero progressivo (0001, 0002...)
2. Crea una cartella snapshot completa in `~/Assisted-Labs-Versioni/`
3. Ricostruisce `latest` con le modifiche più recenti

### Formato versioni
- **Archivi numerati**: ogni versione è un **unico file compresso** `ver NNNN - mese gg.tar.gz` (es. `ver 0014 - set 05.tar.gz`) che contiene al suo interno sorgenti, Docker, volume e manifest.
- **Cartella live**: `ver latest/` è lo stato corrente non numerato (aggiornata a ogni versione).
- **Docker tag**: `alpine-latest-assisted-labs:0001`, `:0002`, ...
- **Latest**: `alpine-latest-assisted-labs:latest` = sempre l'ultima versione

### Sovrascrittura della versione più recente
Per aggiornare lo snapshot della versione numerata con numero più alto (senza crearne una nuova):
```bash
cd ~/assisted-labs && ./versiona.sh --overwrite
```

### Tag funzionali (separate)
Le tag `hardcade`, `arcade`, `standard` restano indipendenti dalla numerazione.

### Contenuto snapshot
Ogni archivio di versione contiene:
- `assisted-labs-sorgenti.tar.gz` — codice sorgente
- `assisted-labs-docker.tar.gz` — immagine Docker esportata
- `assisted-labs-volume.tar.gz` — volume di lavoro
- `manifest.txt` — log delle modifiche

## Build Docker

Dopo ogni versione, l'immagine `latest` viene ricostruita automaticamente.
Per rebuild manuale:

```bash
cd ~/assisted-labs && make build
```

## Comandi rapidi

| Comando | Descrizione |
|---------|-------------|
| `./versiona.sh` | Crea nuova versione (archivio `ver NNNN - mese gg.tar.gz`) + ricostruisce latest |
| `./versiona.sh --overwrite` | Sovrascrive la versione numerata più alta (nessun nuovo numero) |
| `./versiona.sh --dry-run` | Anteprima senza modifiche |
| `make version` | Stessa cosa di `./versiona.sh` |
| `make build` | Ricostruisce latest |
| `make run` | Avvia sessione interattiva |
| `make test` | Testa tutti i 9 lab |

## Regole per agenti
- Dopo aver completato modifiche al codice, eseguire sempre `./versiona.sh` (in staffetta: a fine giro, previa conferma dell'utente "nuovo documento o sovrascrivi il più recente?")
- Verificare che `latest` sia sempre l'ultima versione con `docker images alpine-latest-assisted-labs`
- Non modificare gli archivi in `~/Assisted-Labs-Versioni/` manualmente
- Usare `--dry-run` per verificare prima di eseguire

### Anti-cheat per i test (Lim)
`lab check` valida lo **stato finale** dei file, non il processo: consultando
`lab solution` (o `bash labs/<id>/solution.sh`) un test produrrebbe **falsi
positivi**. Per questo:
- Il CLI accetta `LAB_QA_MODE=1`: in questa modalità `lab solution` è **bloccato**
  (messaggio + `return 1`, nessuna soluzione mostrata).
- **Lim DEVE** anteporre `LAB_QA_MODE=1` a ogni `lab ...` e non leggere/eseguire
  mai `solution.sh` durante un lab. La tracciabilità è obbligatoria nel report
  (`🔎 Tracciabilità: ... Solution consultata: Sì/No`).
- Cosa fa Lim quando si blocca: rilegge le istruzioni, riprova, e se non riesce
  → **finding di qualità del corso** (non una validazione dalla soluzione).
