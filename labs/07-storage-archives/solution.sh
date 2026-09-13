#!/usr/bin/env bash
set -euo pipefail
cd ${LAB_TRAINING_ROOT:-/workspace/training}/${V_DIR:-storage-lab}

df -h . > ${V_OUT_FS:-filesystem_report.txt}
du -sh ${V_DS:-datasets} > ${V_OUT_SIZE:-dataset_size.txt}
find ${V_DS:-datasets} -type f -exec du -h {} + | sort -h | tail -n 1 > ${V_OUT_ITEM:-largest_item.txt}
tar -czf ${V_ARC:-service-a.tar.gz} ${V_DS:-datasets}/${V_A:-service-a}
mkdir -p ${V_RESTORE:-restore}
tar -xzf ${V_ARC:-service-a.tar.gz} -C ${V_RESTORE:-restore}

lab check 07-storage-archives
