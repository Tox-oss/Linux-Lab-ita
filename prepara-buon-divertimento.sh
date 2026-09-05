#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="alpine-latest-assisted-labs:latest"
VOLUME_NAME="Alpine_Latest"

# Cartella di destinazione richiesta
OUTPUT_DIR="$HOME/Assisted-Labs-Versioni/Buon Divertimento"

echo "====================================================="
echo "  PREPARAZIONE CONDIVISIONE - Buon Divertimento"
echo "====================================================="

echo "==> [1/5] Verifica cartella di destinazione: $OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

echo "==> [2/5] Esportazione immagine Docker ($IMAGE_NAME)..."
docker save "$IMAGE_NAME" | gzip > "$OUTPUT_DIR/alpine-latest-assisted-labs.tar.gz"
echo "    - Immagine esportata."

echo "==> [3/5] Esportazione volume /workspace ($VOLUME_NAME)..."
docker run --rm \
  -v "$VOLUME_NAME":/workspace \
  -v "$OUTPUT_DIR":/backup \
  alpine:latest \
  tar czf /backup/Alpine_Latest-volume.tar.gz -C /workspace .
echo "    - Volume esportato."

echo "==> [4/5] Creazione script di avvio e guida per il collega..."
cat << 'INNER_EOF' > "$OUTPUT_DIR/avvia.sh"
#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="alpine-latest-assisted-labs:latest"
VOLUME_NAME="Alpine_Latest"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=================================================="
echo "    AVVIO ASSISTED LINUX LABS (Setup automatico)  "
echo "=================================================="

# 1. Carica l'immagine se non è già presente
if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
    echo "==> Caricamento immagine Docker in corso (richiede pochi secondi)..."
    if [ -f "$SCRIPT_DIR/alpine-latest-assisted-labs.tar.gz" ]; then
        docker load -i "$SCRIPT_DIR/alpine-latest-assisted-labs.tar.gz"
    elif [ -f "$SCRIPT_DIR/alpine-latest-assisted-labs.tar" ]; then
        docker load -i "$SCRIPT_DIR/alpine-latest-assisted-labs.tar"
    else
        echo "ERRORE: File immagine non trovato in $SCRIPT_DIR!"
        exit 1
    fi
    echo "==> Immagine caricata con successo."
else
    echo "==> Immagine Docker già presente."
fi

# 2. Crea il volume se non esiste
if ! docker volume inspect "$VOLUME_NAME" >/dev/null 2>&1; then
    echo "==> Creazione volume persistente '$VOLUME_NAME'..."
    docker volume create "$VOLUME_NAME"

    # Se presente il backup del volume, ripristinalo
    if [ -f "$SCRIPT_DIR/Alpine_Latest-volume.tar.gz" ]; then
        echo "==> Ripristino dati iniziali del laboratorio..."
        docker run --rm \
          -v "$VOLUME_NAME":/workspace \
          -v "$SCRIPT_DIR":/backup \
          alpine:latest \
          tar xzf /backup/Alpine_Latest-volume.tar.gz -C /workspace
    fi
    echo "==> Volume inizializzato."
fi

echo "==> Avvio della sessione interattiva..."
echo "--------------------------------------------------"
exec docker run --rm -it \
  --name assisted-labs \
  -v "$VOLUME_NAME":/workspace \
  "$IMAGE_NAME"
INNER_EOF
chmod +x "$OUTPUT_DIR/avvia.sh"

cat << 'INNER_EOF' > "$OUTPUT_DIR/ISTRUZIONI-COLLEGA.md"
# Assisted Linux Labs - Istruzioni per il Collega

Benvenuto! Questo pacchetto contiene tutto il necessario per eseguire il laboratorio pratico Linux sul tuo computer via Docker.

## Prerequisiti
- Aver installato **Docker** sul proprio PC (Linux, macOS o Windows con WSL2).

---

## Metodo 1: Avvio Automatico a 1 Click (Consigliato)

1. Apri il terminale nella cartella estratta.
2. Esegui lo script:
   ```bash
   ./avvia.sh
   ```
*Lo script caricherà automaticamente l'immagine, creerà il volume persistente e avvierà direttamente il laboratorio.*

---

## Metodo 2: Comandi Manuali

Se preferisci eseguire i passaggi manualmente:

### 1. Importa l'immagine Docker
```bash
docker load -i alpine-latest-assisted-labs.tar.gz
```

### 2. Crea il volume persistente e ripristina i file
```bash
docker volume create Alpine_Latest
docker run --rm -v Alpine_Latest:/workspace -v "$PWD":/backup alpine:latest tar xzf /backup/Alpine_Latest-volume.tar.gz -C /workspace
```

### 3. Avvia il laboratorio
```bash
docker run --rm -it --name assisted-labs -v Alpine_Latest:/workspace alpine-latest-assisted-labs:latest
```

---

## Comandi utili dentro il container
- `lab` : Mostra la guida dei comandi
- `lab list` : Elenco di tutti i laboratori
- `lab start <id>` : Avvia un esercizio (es. `lab start 01-filesystem`)
- `lab check <id>` : Verifica la soluzione svolta
- `lab hint <id>` : Suggerimenti progressivi
- `lab solution <id>` : Mostra la soluzione
- `lab status` : Mostra lo stato di avanzamento
- `lab quit` : Esci dal laboratorio

---

## Novità di questa versione

### Feedback didattico in modalità STANDARD
Quando un `lab check` fallisce in modalità standard, il laboratorio ti
mostra subito, per ogni controllo mancante, il **comando correttivo** da
digitare e come **verificarne il risultato**. Niente frustrazione: impari
sbagliando.

### Easter egg: modalità HARDCADE
HARDCADE è una modalità **nascosta**. Si sblocca solo completando tutti i
9 lab in modalità **ARCADE senza mai perdere un cuore** (run perfetta).
Al primo accesso appare una cascata di caratteri ASCII ("matrix rain").

Bypass dimostrativo (se vuoi vederla subito):
```bash
lab mode standard
LAB_EH_UNLOCK=1 lab mode hardcade
# oppure
lab mode hardcade --force
```
INNER_EOF

echo "==> [5/5] Copia dei sorgenti del corso..."
if [ -d "$HOME/assisted-labs" ]; then
    tar -czf "$OUTPUT_DIR/assisted-labs-sorgenti.tar.gz" -C "$HOME" assisted-labs
    echo "    - Sorgenti copiati."
fi

echo ""
echo "====================================================="
echo "  COMPLETATO!"
echo "  Pacchetto pronto nella cartella:"
echo "    $OUTPUT_DIR"
echo ""
echo "  Contenuto:"
ls -lh "$OUTPUT_DIR"
echo "====================================================="
