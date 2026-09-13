#!/usr/bin/env bash
set -euo pipefail
cd ${LAB_TRAINING_ROOT:-/workspace/training}/${V_DIR:-nav-lab}

pwd > ${V_OUT_CP:-current_path.txt}
ls -1 > ${V_OUT_RL:-root_listing.txt}
find ${V_EVID:-evidence} -type f -name "${V_INC_PAT:-incident-*.txt}" | sort > ${V_OUT_IF:-incident_files.txt}
tail -n 4 ${V_LOGS:-logs}/${V_APP:-app.log} > ${V_OUT_LE:-last_events.txt}
printf '%s\n' "${V_OWNER:-sre-oncall}" > ${V_OUT_OWN:-owner.txt}

lab check 06-navigation-search
