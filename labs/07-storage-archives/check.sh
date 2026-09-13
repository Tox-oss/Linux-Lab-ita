#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../../lib/common.sh"
BASE=${LAB_TRAINING_ROOT:-/workspace/training}/${V_DIR:-storage-lab}

printf 'check 07-storage-archives\n'

for f in ${V_OUT_FS:-filesystem_report.txt} ${V_OUT_SIZE:-dataset_size.txt} ${V_OUT_ITEM:-largest_item.txt} ${V_ARC:-service-a.tar.gz}; do
  warn_misplaced "/workspace/$f" "$BASE/$f"
  warn_misplaced "${LAB_TRAINING_ROOT:-/workspace/training}/$f" "$BASE/$f"
done
warn_misplaced "/workspace/${V_RESTORE:-restore}" "$BASE/${V_RESTORE:-restore}"
warn_misplaced "${LAB_TRAINING_ROOT:-/workspace/training}/${V_RESTORE:-restore}" "$BASE/${V_RESTORE:-restore}"

if [ -f "$BASE/${V_OUT_FS:-filesystem_report.txt}" ] && grep -q 'Filesystem' "$BASE/${V_OUT_FS:-filesystem_report.txt}"; then
  pass "${V_OUT_FS:-filesystem_report.txt} contiene un report df"
else
  miss "${V_OUT_FS:-filesystem_report.txt} errato o assente" "punto 1: df -h . > ${V_OUT_FS:-filesystem_report.txt}" "cat ${V_OUT_FS:-filesystem_report.txt}"
fi

if [ -f "$BASE/${V_OUT_SIZE:-dataset_size.txt}" ] && grep -q "${V_DS:-datasets}" "$BASE/${V_OUT_SIZE:-dataset_size.txt}"; then
  pass "${V_OUT_SIZE:-dataset_size.txt} misura ${V_DS:-datasets}"
else
  miss "${V_OUT_SIZE:-dataset_size.txt} errato o assente" "punto 2: du -sh ${V_DS:-datasets} > ${V_OUT_SIZE:-dataset_size.txt}" "cat ${V_OUT_SIZE:-dataset_size.txt}"
fi

if [ -f "$BASE/${V_OUT_ITEM:-largest_item.txt}" ] && grep -q "${V_DS:-datasets}/${V_BIG:-big}/${V_BLOB:-blob.bin}" "$BASE/${V_OUT_ITEM:-largest_item.txt}"; then
  pass "${V_OUT_ITEM:-largest_item.txt} identifica il file piu grande"
else
  miss "${V_OUT_ITEM:-largest_item.txt} errato o assente" "punto 3: find ${V_DS:-datasets} -type f -exec du -h {} + | sort -h | tail -n 1 > ${V_OUT_ITEM:-largest_item.txt}" "cat ${V_OUT_ITEM:-largest_item.txt}"
fi

if [ -f "$BASE/${V_ARC:-service-a.tar.gz}" ] && tar -tzf "$BASE/${V_ARC:-service-a.tar.gz}" | grep -qx "${V_DS:-datasets}/${V_A:-service-a}/${V_CFG:-config.yml}"; then
  pass "${V_ARC:-service-a.tar.gz} contiene ${V_CFG:-config.yml}"
else
  miss "${V_ARC:-service-a.tar.gz} assente o incompleto" "punto 4: tar -czf ${V_ARC:-service-a.tar.gz} ${V_DS:-datasets}/${V_A:-service-a}" "tar -tzf ${V_ARC:-service-a.tar.gz}"
fi

if [ -f "$BASE/${V_RESTORE:-restore}/${V_DS:-datasets}/${V_A:-service-a}/${V_CFG:-config.yml}" ] && cmp -s "$BASE/${V_DS:-datasets}/${V_A:-service-a}/${V_CFG:-config.yml}" "$BASE/${V_RESTORE:-restore}/${V_DS:-datasets}/${V_A:-service-a}/${V_CFG:-config.yml}"; then
  pass "${V_RESTORE:-restore} contiene ${V_CFG:-config.yml} estratto e identico"
else
  miss "${V_RESTORE:-restore} incompleto o diverso" "punto 5: mkdir -p ${V_RESTORE:-restore}; tar -xzf ${V_ARC:-service-a.tar.gz} -C ${V_RESTORE:-restore}" "ls -R ${V_RESTORE:-restore}"
fi

[ "$fail" -eq 0 ]
