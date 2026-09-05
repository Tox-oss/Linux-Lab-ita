#!/usr/bin/env bash
set -euo pipefail

# Avvia il container in una finestra GNOME Terminal dedicata.
# Quando lab quit termina Docker, termina anche questa shell e GNOME chiude la finestra.
IMAGE="${1:-alpine-latest-assisted-labs:latest}"

exec gnome-terminal -- bash -lc \
  "docker run --rm -it -v Alpine_Latest:/workspace '$IMAGE'; exit"
