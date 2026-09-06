#!/usr/bin/env bash
set -euo pipefail
cd ${LAB_TRAINING_ROOT:-/workspace/training}/diff-lab

diff -u config.old.conf config.new.conf > config.diff || true

if cmp -s report_a.txt report_b.txt; then
  printf 'identici\n' > report_check.txt
else
  printf 'diversi\n' > report_check.txt
fi

comm -23 servers_prod.txt servers_staging.txt > only_prod.txt

diff -r release_v1 release_v2 > release_diff.txt || true

rm -f deprecated.old

lab check 10-file-comparison
