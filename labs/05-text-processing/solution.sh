#!/usr/bin/env bash
set -euo pipefail
cd ${LAB_TRAINING_ROOT:-/workspace/training}/text-lab
grep 'ERROR' access.log | wc -l > error_count.txt
awk '$4 == 500 { print $1 }' access.log | sort -u > failing_ips.txt
awk -F, 'NR > 1 && $1 == "api" { total += $3 } END { print total }' services.csv > api_total.txt
printf 'log analysis complete\n' > summary.txt
# alternativa (newline finale tollerato):  echo 'log analysis complete' > summary.txt
lab check 05-text-processing
