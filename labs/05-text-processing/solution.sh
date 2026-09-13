#!/usr/bin/env bash
set -euo pipefail
cd ${LAB_TRAINING_ROOT:-/workspace/training}/${V_DIR:-text-lab}
grep 'ERROR' ${V_LOG:-access.log} | wc -l > ${V_OUT1:-error_count.txt}
awk '$4 == 500 { print $1 }' ${V_LOG:-access.log} | sort -u > ${V_OUT2:-failing_ips.txt}
awk -F, 'NR > 1 && $1 == "api" { total += $3 } END { print total }' ${V_CSV:-services.csv} > ${V_OUT3:-api_total.txt}
printf '%s\n' "${V_TEXT:-log analysis complete}" > ${V_OUT4:-summary.txt}
# alternativa (newline finale tollerato):  echo 'log analysis complete' > summary.txt
lab check 05-text-processing
