#!/usr/bin/env bash
set -euo pipefail
cd ${LAB_TRAINING_ROOT:-/workspace/training}/${V_DIR:-diff-lab}

diff -u ${V_CFG_OLD:-config.old.conf} ${V_CFG_NEW:-config.new.conf} > ${V_OUT_DIFF:-config.diff} || true

if cmp -s ${V_REP_A:-report_a.txt} ${V_REP_B:-report_b.txt}; then
  printf '%s\n' "${V_VERD:-identici}" > ${V_OUT_CHECK:-report_check.txt}
else
  printf 'diversi\n' > ${V_OUT_CHECK:-report_check.txt}
fi

comm -23 ${V_PROD:-servers_prod.txt} ${V_STAG:-servers_staging.txt} > ${V_OUT_ONLY:-only_prod.txt}

diff -r ${V_REL_A:-release_v1} ${V_REL_B:-release_v2} > ${V_OUT_REL:-release_diff.txt} || true

rm -f ${V_DEPRECATED:-deprecated.old}

lab check 10-file-comparison
