#!/usr/bin/env bash
set -euo pipefail
cd ${LAB_TRAINING_ROOT:-/workspace/training}/nav-lab

pwd > current_path.txt
ls -1 > root_listing.txt
find evidence -type f -name 'incident-*.txt' | sort > incident_files.txt
tail -n 4 logs/app.log > last_events.txt
printf 'sre-oncall\n' > owner.txt

lab check 06-navigation-search
