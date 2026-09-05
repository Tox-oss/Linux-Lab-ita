#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
BASE=${LAB_TRAINING_ROOT:-/workspace/training}/storage-lab

printf 'check 07-storage-archives\n'

for f in filesystem_report.txt dataset_size.txt largest_item.txt service-a.tar.gz; do
  warn_misplaced "/workspace/$f" "$BASE/$f"
  warn_misplaced "${LAB_TRAINING_ROOT:-/workspace/training}/$f" "$BASE/$f"
done
warn_misplaced "/workspace/restore" "$BASE/restore"
warn_misplaced "${LAB_TRAINING_ROOT:-/workspace/training}/restore" "$BASE/restore"

if [ -f "$BASE/filesystem_report.txt" ] && grep -q 'Filesystem' "$BASE/filesystem_report.txt"; then
  pass "filesystem_report.txt contiene un report df"
else
  miss "filesystem_report.txt errato o assente" "punto 1: df -h . > filesystem_report.txt" "cat filesystem_report.txt"
fi

if [ -f "$BASE/dataset_size.txt" ] && grep -q 'datasets' "$BASE/dataset_size.txt"; then
  pass "dataset_size.txt misura datasets"
else
  miss "dataset_size.txt errato o assente" "punto 2: du -sh datasets > dataset_size.txt" "cat dataset_size.txt"
fi

if [ -f "$BASE/largest_item.txt" ] && grep -q 'datasets/big/blob.bin' "$BASE/largest_item.txt"; then
  pass "largest_item.txt identifica il file piu grande"
else
  miss "largest_item.txt errato o assente" "punto 3: find datasets -type f -exec du -h {} + | sort -h | tail -n 1 > largest_item.txt" "cat largest_item.txt"
fi

if [ -f "$BASE/service-a.tar.gz" ] && tar -tzf "$BASE/service-a.tar.gz" | grep -qx 'datasets/service-a/config.yml'; then
  pass "service-a.tar.gz contiene config.yml"
else
  miss "service-a.tar.gz assente o incompleto" "punto 4: tar -czf service-a.tar.gz datasets/service-a" "tar -tzf service-a.tar.gz"
fi

if [ -f "$BASE/restore/datasets/service-a/config.yml" ] && cmp -s "$BASE/datasets/service-a/config.yml" "$BASE/restore/datasets/service-a/config.yml"; then
  pass "restore contiene config.yml estratto e identico"
else
  miss "restore incompleto o diverso" "punto 5: mkdir -p restore; tar -xzf service-a.tar.gz -C restore" "ls -R restore"
fi

[ "$fail" -eq 0 ]
