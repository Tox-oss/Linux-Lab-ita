# Assisted Linux Labs — Guida alla Valutazione per Sistemisti

Questo documento è pensato per i sistemisti, docenti e DevOps engineer che desiderano valutare l'architettura, la didattica e la robustezza di **Assisted Linux Labs**.

---

## 🎯 Obiettivo del Progetto
Creare un ambiente di apprendimento Linux hands-on minimale, puro da terminale (senza browser o interfacce web), riproducibile e non punitivo, pensato per principianti e tecnici junior.

---

## 🏗️ Scelte Architetturali Chiave

1. **Isolamento Runtime vs Workspace**:
   * I laboratori ufficiali e la CLI risiedono nell'immagine Docker in `/opt/assisted-labs` (immutabili dall'utente).
   * L'ambiente di lavoro dell'utente vive nel volume persistente `/workspace/training`.
2. **Validazione Non Distruttiva (`lab check`)**:
   * `lab check` non cancella i file dell'utente in caso di fallimento. Solo `lab start` o `lab reset` effettuano il ripristino.
3. **Approccio "Commessa vs Mezzi"**:
   * I test verificano lo stato finale a livello di kernel e filesystem (permessi POSIX effettivi, appartenenza ai gruppi in `/etc/group`, processi in esecuzione in `/proc`, integrità dati) piuttosto che forzare una specifica combinazione di flag o comandi.
4. **Rilevamento Percorsi Errati (`warn_misplaced`)**:
   * Se un novizio esegue i comandi fuori dalla cartella di lavoro (es. in `/workspace` o nella cartella genitore), il checker rileva gli elementi fuori posto e avvisa l'utente senza rimuoverli. Solo `start` e `reset` sono operazioni distruttive esplicite.
5. **Hint Strutturati a 4 Livelli**:
   * Concetto Teorico $\to$ Strategia & Best Practice $\to$ Comandi Guidati $\to$ Verifica Manuale Autonoma.
6. **Ripasso Post-Completamento (`PERCHE FUNZIONA`)**:
   * Dopo ogni `check` superato con successo, viene visualizzato un riassunto dei concetti di sistema consolidati dall'esercizio.

---

## 🧪 Come Valutare il Laboratorio

### 1. Avvio Rapido
```bash
# Tramite Docker Compose:
docker compose run --rm lab

# Oppure con Make:
make run

# Oppure comando Docker diretto:
docker run --rm -it -v Alpine_Latest:/workspace alpine-latest-assisted-labs:latest
```

### 2. Suite di Test Automatizzata
Per eseguire un collaudo end-to-end su tutti i laboratori:
```bash
make test
```

### 3. Casi di Test Consigliati per il Sistemista

| Scenario di Test | Come Eseguirlo | Comportamento Atteso |
| :--- | :--- | :--- |
| **Flusso Regolare** | `lab start 01-filesystem` $\to$ comandi $\to$ `lab check 01-filesystem` | Superamento e visualizzazione del blocco `PERCHE FUNZIONA`. |
| **Percorso Errato** | `cd /workspace && mkdir -p project/docs` $\to$ `lab check 01-filesystem` | Warning dettagliato con il comando `rm -rf` da eseguire a mano; nessun dato viene rimosso dal check. |
| **Tolleranza Spazi/Newline** | Creare file con `nano`, `printf` o `echo` (con newline) | Tutti i metodi vengono accettati equamente. |
| **Idempotenza Soluzioni** | Lanciare la soluzione 2 volte consecutive | Nessun errore, stato consistente. |
| **Isolamento Reset** | Lanciare `lab reset 04-processes` | Termina solo il processo `sleep 3600` del lab, non tocca altri processi. |

---

## 📝 Griglia di Valutazione (Feedback Rubric)

Ti chiediamo cortesemente un parere sui seguenti aspetti:

1. **Rigore Tecnico**: I concetti esposti (FHS, permessi ottali/simbolici, usermod, stream Unix, segnali di processo) sono allineati ai moderni standard sistemistici?
2. **Pedagogia & Ergonomia**: Il sistema di hint a 4 livelli lascia sufficiente "respiro" all'allievo prima di mostrare il comando finale?
3. **Robustezza dei Check**: Ci sono edge case in cui un comando valido fallisce o un comando scorretto viene erroneamente validato?
4. **Espandibilità**: La struttura modulare `labs/<id>/` risulta intuitiva per aggiungere nuovi moduli (es. networking, cron, ssh, init basics via OpenRC)?
