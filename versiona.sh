#!/usr/bin/env bash
# =============================================================================
# versiona.sh — Versionamento automatico Assisted Linux Labs
# =============================================================================
# 1. Rinomina cartelle vecchio formato → nuovo formato 4 cifre (0001, 0002...)
# 2. Tagga l'immagine Docker latest corrente col numero progressivo
# 3. Crea cartella snapshot numerata (versione precedente)
# 4. Ricostruisce latest con le modifiche
# 5. Salva il nuovo latest in "ver latest"
#
# Uso:
#   ./versiona.sh                snapshot + rebuild latest (nuova versione)
#   ./versiona.sh --overwrite    sovrascrive la versione numerata piu' alta
#                                (nessun nuovo numero/tag) invece di crearne una
#   ./versiona.sh --dry-run      anteprima senza modifiche
#   ./versiona.sh --restore-tag-storiche
#                                carica i tarball storici (0001-0005)
#                                e crea i tag Docker corrispondenti
#
#   Nota formato: ogni versione numerata e' salvata come UN SINGOLO archivio
#   `ver NNNN - mese gg.tar.gz` (contenente sorgenti+docker+volume+manifest).
#   `ver latest/` resta invece una cartella live (stato corrente non numerato).
# =============================================================================
set -euo pipefail

RESTORE_STORICHE=false
OVERWRITE=false
DRY_RUN=false
for arg in "$@"; do
    case "$arg" in
        --restore-tag-storiche) RESTORE_STORICHE=true ;;
        --overwrite)            OVERWRITE=true ;;
        --dry-run)              DRY_RUN=true ;;
    esac
done

VERSIONI_DIR="${HOME}/Assisted-Labs-Versioni"
LABS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_BASE="alpine-latest-assisted-labs"
VOLUME_NAME="Alpine_Latest"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
info()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok()    { printf '\033[1;32m  OK\033[0m %s\n' "$*"; }
warn()  { printf '\033[1;33m  !!\033[0m %s\n' "$*"; }
die()   { printf '\033[1;31m ERR\033[0m %s\n' "$*" >&2; exit 1; }

mese_italiano() {
    case "$1" in
        01) echo gen;; 02) echo feb;; 03) echo mar;; 04) echo apr;;
        05) echo mag;; 06) echo giu;; 07) echo lug;; 08) echo ago;;
        09) echo set;; 10) echo ott;; 11) echo nov;; 12) echo dic;;
        *)  echo "??";;
    esac
}

exe() {
    if [[ "$DRY_RUN" == "true" ]]; then
        info "  [DRY-RUN] $*"
    else
        "$@"
    fi
}

# Legge il riferimento "repo:tag" dell'immagine Docker salvata dentro un
# archivio di versione (index.json OCI, come quello prodotto da docker save).
# Stampa vuoto se non determinabile.
ref_name_of_archive() {
    local stage t ref
    stage=$(mktemp -d)
    tar xzf "$1" -C "$stage" 2>/dev/null || { rm -rf "$stage"; return 1; }
    for t in "$stage"/*.tar.gz; do
        if [[ -f "$t" ]] && tar tzf "$t" index.json >/dev/null 2>&1; then
            ref=$(tar xzOf "$t" index.json 2>/dev/null | python3 -c 'import json,sys
try:
    d = json.load(sys.stdin)
    print(d["manifests"][0]["annotations"].get("org.opencontainers.image.ref.name", ""))
except Exception:
    print("")' 2>/dev/null || true)
            rm -rf "$stage"
            [[ -n "$ref" ]] && printf '%s' "$ref"
            return 0
        fi
    done
    rm -rf "$stage"
    return 1
}

# ---------------------------------------------------------------------------
# Modalità: --restore-tag-storiche
# Carica i tarball Docker storici (nuova cartella della versione) e li tagga
# col numero progressivo, senza toccare :latest.
# ---------------------------------------------------------------------------
restore_tag_storiche() {
    info "Carico i tarball Docker storici e creo i tag corrispondenti..."

    CUR_ID=$(docker inspect --format '{{.Id}}' "${IMAGE_BASE}:latest" 2>/dev/null || true)
    [[ -z "$CUR_ID" ]] && die "Immagine ${IMAGE_BASE}:latest non trovata"

    RESTORED=0
    while IFS= read -r archive; do
        basename_arch=$(basename "$archive")
        if [[ "$basename_arch" =~ ^ver\ ([0-9]{4})\ -\ .*\.tar\.gz$ ]]; then
            num=${BASH_REMATCH[1]}

            # Se il tag esiste già, salta
            if docker image inspect "${IMAGE_BASE}:${num}" &>/dev/null; then
                ok "  Tag :${num} già presente, salto"
                continue
            fi

            # Estrae l'archivio di versione in una cartella temporanea e cerca
            # il tarball docker (in stile docker save: contiene manifest.json)
            STAGE_RESTORE=$(mktemp -d)
            tar xzf "$archive" -C "$STAGE_RESTORE" 2>/dev/null || true

            tarball=""
            while IFS= read -r f; do
                if tar tzf "$f" manifest.json &>/dev/null; then
                    tarball="$f"
                    break
                fi
            done < <(find "$STAGE_RESTORE" -maxdepth 3 -type f -name '*.tar.gz' 2>/dev/null)

            [[ -z "$tarball" ]] && { warn "  Ver ${num}: nessun tarball docker trovato, salto"; rm -rf "$STAGE_RESTORE"; continue; }

            info "  Ver ${num}: carico $(basename "$tarball")..."
            docker load -i "$tarball" >/dev/null 2>&1 || { warn "  Ver ${num}: load fallito, salto"; rm -rf "$STAGE_RESTORE"; continue; }

# ID immagine caricata = digest dal index.json (OCI) se presente,
            # altrimenti dal Config del manifest.json (docker save classico)
            if tar tzf "$tarball" index.json >/dev/null 2>&1; then
                LOADED_ID=$(tar xzOf "$tarball" index.json 2>/dev/null \
                    | python3 -c 'import json,sys; print(json.load(sys.stdin)["manifests"][0]["digest"])' 2>/dev/null || echo "")
            else
                LOADED_ID=$(tar xzOf "$tarball" manifest.json 2>/dev/null \
                    | python3 -c 'import json,sys; c=json.load(sys.stdin)[0]["Config"]; print("sha256:"+c.split("/")[-1])' 2>/dev/null || echo "")
            fi
            if [[ -n "$LOADED_ID" ]]; then
                if docker tag "$LOADED_ID" "${IMAGE_BASE}:${num}" 2>/dev/null; then
                    ok "  Tag :${num} creata"
                    RESTORED=$((RESTORED + 1))
                else
                    warn "  Ver ${num}: tag non riuscita"
                fi
                # Ripristina sempre latest al valore originale
                docker tag "$CUR_ID" "${IMAGE_BASE}:latest"
            else
                warn "  Ver ${num}: ID immagine non determinata, salto"
            fi
            rm -rf "$STAGE_RESTORE"
        fi
    done < <(find "$VERSIONI_DIR" -maxdepth 1 -mindepth 1 -type f -name 'ver *.tar.gz' 2>/dev/null | sort)

    if [[ $RESTORED -eq 0 ]]; then
        warn "Nessun nuovo tag creata (già tutte presenti o tarball non trovati)"
    else
        ok "Ripristinate ${RESTORED} tag storiche"
    fi

    echo ""
    docker images "${IMAGE_BASE}" --format "  {{.Tag}}  {{.ID}}  {{.CreatedSince}}"
    echo ""
    exit 0
}

# Dispatch: modalità restore tag storiche
if [[ "$RESTORE_STORICHE" == "true" ]]; then
    restore_tag_storiche
fi

# ---------------------------------------------------------------------------
# 1. Rinomina cartelle vecchio formato (ver 0.000NNNN → ver NNNN)
# ---------------------------------------------------------------------------
mkdir -p "$VERSIONI_DIR"   # incondizionato: la cartella nasce anche la prima volta

info "Fase 1: rinomina cartelle vecchio formato..."

COUNTER=1
RENAMED=0
while IFS= read -r dir; do
    basename_dir=$(basename "$dir")
    if [[ "$basename_dir" =~ ^ver\ 0\.000([0-9]+)\ -\ (.+)$ ]]; then
        OLD_DATE="${BASH_REMATCH[2]}"
        NEW_NUM=$(printf '%04d' $COUNTER)
        NEW_NAME="ver ${NEW_NUM} - ${OLD_DATE}"
        if [[ "$dir" != "${VERSIONI_DIR}/${NEW_NAME}" ]]; then
            info "  ${basename_dir} → ${NEW_NAME}"
            exe mv "$dir" "${VERSIONI_DIR}/${NEW_NAME}"
            RENAMED=$((RENAMED + 1))
        fi
        COUNTER=$((COUNTER + 1))
    fi
done < <(find "$VERSIONI_DIR" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | sort)
[[ $RENAMED -gt 0 ]] && ok "Rinominate ${RENAMED} cartelle" || info "  Nessuna cartella da rinominare"

# ---------------------------------------------------------------------------
# 2. Trova ultima versione numerica (4 cifre) dopo le rinomine
#    (sia nelle cartelle legacy che negli archivi .tar.gz attuali)
# ---------------------------------------------------------------------------
info "Fase 2: ricerca ultima versione..."

MAX_VER=0
if [[ -d "$VERSIONI_DIR" ]]; then
    # Cartelle legacy
    while IFS= read -r dir; do
        basename_dir=$(basename "$dir")
        if [[ "$basename_dir" =~ ^ver\ ([0-9]{4})\ -\  ]]; then
            num=$((10#${BASH_REMATCH[1]}))
            (( num > MAX_VER )) && MAX_VER=$num
        fi
    done < <(find "$VERSIONI_DIR" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | sort)
    # Archivi singolo .tar.gz (formato attuale)
    while IFS= read -r f; do
        basename_f=$(basename "$f")
        if [[ "$basename_f" =~ ^ver\ ([0-9]{4})\ -\ .*\.tar\.gz$ ]]; then
            num=$((10#${BASH_REMATCH[1]}))
            (( num > MAX_VER )) && MAX_VER=$num
        fi
    done < <(find "$VERSIONI_DIR" -maxdepth 1 -mindepth 1 -type f -name 'ver *.tar.gz' 2>/dev/null | sort)
fi

# ---------------------------------------------------------------------------
# GUARDIA ANTI-CROSSOVER: --overwrite e' vietato quando lo snapshot piu' alto
# contiene un'immagine Docker di base diversa da quella attuale (es. versione
# Ubuntu da non sovrascrivere con la nuova base Alpine). In tal caso si crea
# una nuova versione (senza --overwrite).
# ---------------------------------------------------------------------------
if [[ "$OVERWRITE" == "true" && "$MAX_VER" -gt 0 ]]; then
    guard_archive=""
    while IFS= read -r f; do
        if [[ "$(basename "$f")" =~ ^ver\ ([0-9]{4})\ -\ .*\.tar\.gz$ ]] \
           && [[ $((10#${BASH_REMATCH[1]})) -eq "$MAX_VER" ]]; then
            guard_archive="$f"
        fi
    done < <(find "$VERSIONI_DIR" -maxdepth 1 -type f -name 'ver *.tar.gz' 2>/dev/null | sort)
    if [[ -n "$guard_archive" ]]; then
        guard_ref=$(ref_name_of_archive "$guard_archive")
        if [[ -n "$guard_ref" && "${guard_ref%%:*}" != "$IMAGE_BASE" ]]; then
            die "Guardia anti-crossover: '$guard_archive' contiene l'immagine '${guard_ref%%:*}', diversa dalla base attuale '${IMAGE_BASE}'. Non sovrascrivere lo snapshot della base precedente: crea una nuova versione senza --overwrite."
        fi
    fi
fi

if [[ "$OVERWRITE" == "true" ]]; then
    NUOVA_VER=$MAX_VER
else
    NUOVA_VER=$((MAX_VER + 1))
fi
NUOVA_VER_STR=$(printf '%04d' $NUOVA_VER)

OGGI=$(date +%d)
MESE_IT=$(mese_italiano "$(date +%m)")
# Nome archivio: "ver NNNN - set 05.tar.gz"
CARTELLA_VER="ver ${NUOVA_VER_STR} - ${MESE_IT} ${OGGI}"
ARCHIVIO_VER="${CARTELLA_VER}.tar.gz"
ARCHIVIO_PATH="${VERSIONI_DIR}/${ARCHIVIO_VER}"

echo ""
info "Ultima versione trovata: $(printf '%04d' $MAX_VER)"
if [[ "$OVERWRITE" == "true" ]]; then
    info "Modo OVERWRITE:          sovrascrivo ${ARCHIVIO_VER}"
else
    info "Nuova versione:          ${NUOVA_VER_STR}"
fi
info "Data:                    ${MESE_IT} ${OGGI}"
echo ""

# ---------------------------------------------------------------------------
# 3. Verifica immagine latest esistente
# ---------------------------------------------------------------------------
if ! docker image inspect "${IMAGE_BASE}:latest" &>/dev/null; then
    die "Immagine ${IMAGE_BASE}:latest non trovata. Eseguire prima: make build"
fi

# Se --overwrite ma non esiste ancora una versione numerata, agisci come nuovo
if [[ "$OVERWRITE" == "true" && "$MAX_VER" -eq 0 ]]; then
    warn "Nessuna versione numerata da sovrascrivere, creo la prima (ver 0001)"
    OVERWRITE=false
    NUOVA_VER=1
    NUOVA_VER_STR="0001"
    CARTELLA_VER="ver 0001 - ${MESE_IT} ${OGGI}"
    ARCHIVIO_VER="${CARTELLA_VER}.tar.gz"
    ARCHIVIO_PATH="${VERSIONI_DIR}/${ARCHIVIO_VER}"
fi

# ---------------------------------------------------------------------------
# 4. Tagga latest corrente col numero (nuovo) o ri-taggala (overwrite)
# ---------------------------------------------------------------------------
info "Fase 4: taggo ${IMAGE_BASE}:latest → ${IMAGE_BASE}:${NUOVA_VER_STR}"
exe docker tag "${IMAGE_BASE}:latest" "${IMAGE_BASE}:${NUOVA_VER_STR}"
if [[ "$OVERWRITE" == "true" ]]; then
    ok "Tag :${NUOVA_VER_STR} riallineata a latest"
else
    ok "Tag :${NUOVA_VER_STR} creata"
fi

# ---------------------------------------------------------------------------
# 5. Crea snapshot in un'unica cartella staging, poi la comprime in
#    "ver NNNN - mese gg.tar.gz" (versione precedente = latest attuale).
#    In modalita' --overwrite sovrascrive l'archivio della versione piu' alta.
# ---------------------------------------------------------------------------
if [[ "$OVERWRITE" == "true" ]]; then
    info "Fase 5: sovrascrivo ${ARCHIVIO_VER} con lo stato corrente"
else
    info "Fase 5: snapshot della versione precedente → ${ARCHIVIO_VER}"
fi

if [[ -e "$ARCHIVIO_PATH" && "$OVERWRITE" == "false" ]]; then
    die "Archivio ${ARCHIVIO_VER} già esistente!"
fi

STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

# --- 5a. Sorgenti ---
info "  Export sorgenti..."
if [[ "$DRY_RUN" == "false" ]]; then
    tar czf "${STAGE}/assisted-labs-sorgenti.tar.gz" \
        --exclude='.git' \
        --exclude='node_modules' \
        --exclude='*.tar.gz' \
        --exclude='*.tar' \
        -C "${LABS_DIR}" .
fi
ok "Sorgenti salvati"

# --- 5b. Docker (latest attuale, prima del rebuild) ---
if docker image inspect "${IMAGE_BASE}:latest" &>/dev/null; then
    info "  Export immagine Docker (:${NUOVA_VER_STR})..."
    if [[ "$DRY_RUN" == "false" ]]; then
        docker save "${IMAGE_BASE}:latest" | gzip > "${STAGE}/assisted-labs-docker.tar.gz"
    fi
    ok "Immagine Docker salvata"
fi

# --- 5c. Volume Docker ---
if docker volume inspect "$VOLUME_NAME" &>/dev/null; then
    info "  Export volume Docker..."
    if [[ "$DRY_RUN" == "false" ]]; then
        docker run --rm \
            -v "${VOLUME_NAME}:/volume" \
            -v "${STAGE}:/backup" \
            alpine tar czf /backup/assisted-labs-volume.tar.gz -C /volume .
    fi
    ok "Volume salvato"
else
    warn "  Volume ${VOLUME_NAME} non trovato, salto export"
fi

# --- 5d. Diagramma ODT (se presente negli archivi precedenti) ---
if [[ "$DRY_RUN" == "false" ]]; then
    ODT_SRC=$(find "$VERSIONI_DIR" -maxdepth 2 -name 'assisted-labs-diagram.odt' -print -quit 2>/dev/null || true)
    if [[ -n "$ODT_SRC" ]]; then
        cp "$ODT_SRC" "${STAGE}/" 2>/dev/null || true
        ok "Diagramma ODT incluso"
    fi
fi

# --- 5e. Manifest ---
info "  Creo manifest..."
if [[ "$DRY_RUN" == "false" ]]; then
    {
        echo "========================================="
        echo "  Assisted Linux Labs — Snapshot"
        echo "========================================="
        echo ""
        echo "Versione:    ${NUOVA_VER_STR}"
        echo "Modo:        $([[ "$OVERWRITE" == "true" ]] && echo "sovrascrittura versione esistente" || echo "nuova versione")"
        echo "Data:        $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Hostname:    $(hostname)"
        echo "Utente:      $(whoami)"
        echo ""
        echo "--- Contenuto ---"
        echo "assisted-labs-sorgenti.tar.gz  Codice sorgente"
        echo "assisted-labs-docker.tar.gz    Immagine Docker (:${NUOVA_VER_STR})"
        echo "assisted-labs-volume.tar.gz    Volume di lavoro"
        echo "manifest.txt                   Questo file"
        echo ""
        echo "--- Docker images ---"
        docker images "${IMAGE_BASE}" --format "  {{.Tag}}  {{.Size}}  {{.CreatedSince}}" 2>/dev/null || echo "  (non disponibile)"
        echo ""
        echo "--- Sorgenti modificati di recente ---"
        find "${LABS_DIR}" -maxdepth 3 -type f \
            -not -path '*/.git/*' \
            -not -path '*/node_modules/*' \
            -not -name '*.tar.gz' \
            -not -name '*.tar' \
            -not -name '*.swp' \
            2>/dev/null | head -30 || true
    } > "${STAGE}/manifest.txt"
fi
ok "Manifest creato"

# --- 5f. Confeziona ARCHIVIO unico .tar.gz ---
info "  Confeziono ${ARCHIVIO_VER} ..."
if [[ "$DRY_RUN" == "false" ]]; then
    if [[ "$OVERWRITE" == "true" && -e "$ARCHIVIO_PATH" ]]; then
        rm -f "$ARCHIVIO_PATH"
    fi
    tar czf "$ARCHIVIO_PATH" -C "$STAGE" .
    # Se esisteva la cartella legacy con lo stesso numero, la converto
    # (rimuovo la cartella dopo aver creato l'archivio equivalente)
    if [[ "$OVERWRITE" == "true" && -d "${VERSIONI_DIR}/${CARTELLA_VER}" ]]; then
        warn "  Rimuovo la cartella legacy ${CARTELLA_VER}/ (convertita in archivio)"
        rm -rf "${VERSIONI_DIR}/${CARTELLA_VER}"
    fi
fi
ok "Archivio creato"

echo ""
info "Snapshot (versione ${NUOVA_VER_STR}): ${ARCHIVIO_PATH}"
echo ""

# ---------------------------------------------------------------------------
# 6. Ricostruisci latest
# ---------------------------------------------------------------------------
info "Fase 6: ricostruisco ${IMAGE_BASE}:latest..."
exe docker build -t "${IMAGE_BASE}:latest" "${LABS_DIR}"
ok "Latest ricostruita"

# ---------------------------------------------------------------------------
# 7. Salva il nuovo latest in "ver latest"
# ---------------------------------------------------------------------------
LATEST_CARTELLA="${VERSIONI_DIR}/ver latest"
info "Fase 7: salvo il nuovo latest in ver latest/"

exe mkdir -p "$LATEST_CARTELLA"

if [[ "$DRY_RUN" == "false" ]]; then
    # Aggiorna export Docker del latest ricostruito
    docker save "${IMAGE_BASE}:latest" | gzip > "${LATEST_CARTELLA}/assisted-labs-docker-latest.tar.gz"

    # Copia sorgenti correnti (sono le più recenti)
    tar czf "${LATEST_CARTELLA}/assisted-labs-sorgenti.tar.gz" \
        --exclude='.git' \
        --exclude='node_modules' \
        --exclude='*.tar.gz' \
        --exclude='*.tar' \
        -C "${LABS_DIR}" .

    # Manifest con stato attuale
    {
        echo "========================================="
        echo "  Assisted Linux Labs — LATEST"
        echo "========================================="
        echo ""
        echo "Ultimo aggiornamento: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Corrisponde alla versione appena ricostruita: :latest"
        echo "Ultima versione numerata precedente: ${NUOVA_VER_STR}"
        echo ""
        echo "--- Docker images ---"
        docker images "${IMAGE_BASE}" --format "  {{.Tag}}  {{.CreatedSince}}" 2>/dev/null || true
    } > "${LATEST_CARTELLA}/manifest.txt"
fi
ok "ver latest aggiornata"

# ---------------------------------------------------------------------------
# Riepilogo
# ---------------------------------------------------------------------------
echo ""
echo "========================================="
echo "  VERSIONE ${NUOVA_VER_STR} COMPLETATA"
echo "========================================="
echo ""
if [[ "$OVERWRITE" == "true" ]]; then
    echo "  Versione sovrascritta: ${ARCHIVIO_VER}"
else
    echo "  Versione precedente:   ${ARCHIVIO_VER}"
fi
echo "  Tag snapshot:         ${IMAGE_BASE}:${NUOVA_VER_STR}"
echo "  Latest ricostruita:   ${IMAGE_BASE}:latest"
echo "  Latest archiviata:    ver latest/"
echo ""
if [[ "$DRY_RUN" == "false" ]]; then
    echo "  Archivio ${ARCHIVIO_VER}:"
    ls -lh "${ARCHIVIO_PATH}"
    echo ""
    echo "  Docker images:"
    docker images "${IMAGE_BASE}" --format "  {{.Tag}}  {{.Size}}  {{.CreatedSince}}"
fi
echo ""