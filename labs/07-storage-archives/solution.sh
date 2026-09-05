#!/usr/bin/env bash
set -euo pipefail
cd ${LAB_TRAINING_ROOT:-/workspace/training}/storage-lab

df -h . > filesystem_report.txt
du -sh datasets > dataset_size.txt
find datasets -type f -exec du -h {} + | sort -h | tail -n 1 > largest_item.txt
tar -czf service-a.tar.gz datasets/service-a
mkdir -p restore
tar -xzf service-a.tar.gz -C restore

lab check 07-storage-archives
