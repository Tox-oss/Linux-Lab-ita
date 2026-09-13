#!/usr/bin/env bash
# Assisted Linux Labs — motore delle VARIANTI HARDCADE.
#
# Ogni lab ha 5 varianti (numeri 1..5) + la variante 0 = BASE canonica.
# Ogni variante e' una tupla di valori per i token V_*. Il CLI, in modalita
# HARDCADE, pesca una variante per lab (a caso, una sola volta a run), esporta
# le V_* e quindi:
#   - check.sh / reset.sh / solution.sh usano ${V_CAMPO:-<base>} nei percorsi;
#   - i TESTI (README / hint / why) usano @V_CAMPO@, sostituiti da
#     variant_render() in bin/lab prima della stampa.
# Con le V_* non settate (o settate alla variante 0) ogni lab resta il base
# canonico: standard, arcade e la suite di test restano identici a prima.

VAR_COUNT=5

# hcv_values <lab-id> <num> — stampa righe "export V_X='valore'" (eval-able).
# num=0 → valori BASE del lab.
hcv_values() {
  local lab="$1" num="$2"
  case "$lab:$num" in

  # ------------------------------------------------------------------ LAB 01
  01-filesystem:0) cat <<'EOF'
export V_DIR='fs-lab'
export V_MAIN='project'
export V_DOCS='docs'
export V_NOTES='notes.txt'
export V_DATA='data.txt'
export V_BACKUP='data.backup'
export V_INBOX='inbox'
export V_RAW='raw.txt'
export V_TEMP='temp.tmp'
export V_TEXT='filesystem lab'
EOF
 ;;
  01-filesystem:1) cat <<'EOF'
export V_DIR='storage'
export V_MAIN='workspace'
export V_DOCS='archive'
export V_NOTES='index.txt'
export V_DATA='payload.txt'
export V_BACKUP='payload.backup'
export V_INBOX='incoming'
export V_RAW='input.dat'
export V_TEMP='sweep.tmp'
export V_TEXT='catalog entry'
EOF
 ;;
  01-filesystem:2) cat <<'EOF'
export V_DIR='lab-repo'
export V_MAIN='research'
export V_DOCS='backups'
export V_NOTES='summary.txt'
export V_DATA='result.txt'
export V_BACKUP='result.backup'
export V_INBOX='uploads'
export V_RAW='seed.dat'
export V_TEMP='junk.tmp'
export V_TEXT='research notes'
EOF
 ;;
  01-filesystem:3) cat <<'EOF'
export V_DIR='bunker'
export V_MAIN='mission'
export V_DOCS='reports'
export V_NOTES='logfile.txt'
export V_DATA='manifest.txt'
export V_BACKUP='manifest.backup'
export V_INBOX='intake'
export V_RAW='raw.dat'
export V_TEMP='scratch.tmp'
export V_TEXT='mission log'
EOF
 ;;
  01-filesystem:4) cat <<'EOF'
export V_DIR='vault'
export V_MAIN='records'
export V_DOCS='archives'
export V_NOTES='ledger.txt'
export V_DATA='entries.txt'
export V_BACKUP='entries.backup'
export V_INBOX='dropbox'
export V_RAW='in.dat'
export V_TEMP='trash.tmp'
export V_TEXT='ledger entry'
EOF
 ;;
  01-filesystem:5) cat <<'EOF'
export V_DIR='sq-lab'
export V_MAIN='teams'
export V_DOCS='docs_backup'
export V_NOTES='members.txt'
export V_DATA='members.dat'
export V_BACKUP='members.bak'
export V_INBOX='pending'
export V_RAW='new.dat'
export V_TEMP='obsolete.tmp'
export V_TEXT='team roster'
EOF
 ;;

  # ------------------------------------------------------------------ LAB 02
  02-permissions:0) cat <<'EOF'
export V_DIR='perms-lab'
export V_SCRIPTS='scripts'
export V_SCRIPT='run.sh'
export V_PRIVATE='private.txt'
export V_DROPBOX='dropbox'
export V_DBOX_README='README.txt'
export V_TEXT='permissions matter'
EOF
 ;;
  02-permissions:1) cat <<'EOF'
export V_DIR='sessione'
export V_SCRIPTS='bin'
export V_SCRIPT='deploy.sh'
export V_PRIVATE='key.txt'
export V_DROPBOX='shared'
export V_DBOX_README='note.txt'
export V_TEXT='access granted'
EOF
 ;;
  02-permissions:2) cat <<'EOF'
export V_DIR='area-lavoro'
export V_SCRIPTS='tools'
export V_SCRIPT='build.sh'
export V_PRIVATE='token.txt'
export V_DROPBOX='intake'
export V_DBOX_README='info.txt'
export V_TEXT='unauthorized denied'
EOF
 ;;
  02-permissions:3) cat <<'EOF'
export V_DIR='clearing'
export V_SCRIPTS='ops'
export V_SCRIPT='start.sh'
export V_PRIVATE='secret.txt'
export V_DROPBOX='deliveries'
export V_DBOX_README='guide.txt'
export V_TEXT='restricted access'
EOF
 ;;
  02-permissions:4) cat <<'EOF'
export V_DIR='osservatorio'
export V_SCRIPTS='utility'
export V_SCRIPT='task.sh'
export V_PRIVATE='note.txt'
export V_DROPBOX='warehouse'
export V_DBOX_README='guidelines.txt'
export V_TEXT='restricted area'
EOF
 ;;
  02-permissions:5) cat <<'EOF'
export V_DIR='cliente'
export V_SCRIPTS='sbin'
export V_SCRIPT='runme.sh'
export V_PRIVATE='password.txt'
export V_DROPBOX='trash'
export V_DBOX_README='instructions.txt'
export V_TEXT='keep out'
EOF
 ;;

  # ------------------------------------------------------------------ LAB 03
  03-users-groups:0) cat <<'EOF'
export V_DIR='users-lab'
export V_USER='learner'
export V_GROUP='devops'
export V_TEAM='team'
export V_TEAM_MODE='770'
EOF
 ;;
  03-users-groups:1) cat <<'EOF'
export V_DIR='utenti-sprint'
export V_USER='maria'
export V_GROUP='ops'
export V_TEAM='squadra'
export V_TEAM_MODE='770'
EOF
 ;;
  03-users-groups:2) cat <<'EOF'
export V_DIR='identita-box'
export V_USER='giulia'
export V_GROUP='platform'
export V_TEAM='guild'
export V_TEAM_MODE='750'
EOF
 ;;
  03-users-groups:3) cat <<'EOF'
export V_DIR='rubrica-lab'
export V_USER='paolo'
export V_GROUP='infra'
export V_TEAM='cell'
export V_TEAM_MODE='770'
EOF
 ;;
  03-users-groups:4) cat <<'EOF'
export V_DIR='utenti-qa'
export V_USER='anna'
export V_GROUP='delivery'
export V_TEAM='crew'
export V_TEAM_MODE='760'
EOF
 ;;
  03-users-groups:5) cat <<'EOF'
export V_DIR='persone-lab'
export V_USER='marco'
export V_GROUP='core'
export V_TEAM='squad'
export V_TEAM_MODE='750'
EOF
 ;;

  # ------------------------------------------------------------------ LAB 04
  04-processes:0) cat <<'EOF'
export V_DIR='process-lab'
export V_PID='worker.pid'
export V_STATUS='status.txt'
export V_SLEEP='3600'
export V_TEXT='running'
EOF
 ;;
  04-processes:1) cat <<'EOF'
export V_DIR='proc-sess'
export V_PID='daemon.pid'
export V_STATUS='state.txt'
export V_SLEEP='7200'
export V_TEXT='running'
EOF
 ;;
  04-processes:2) cat <<'EOF'
export V_DIR='tasks'
export V_PID='job.pid'
export V_STATUS='node.txt'
export V_SLEEP='1800'
export V_TEXT='active'
EOF
 ;;
  04-processes:3) cat <<'EOF'
export V_DIR='workers'
export V_PID='agent.pid'
export V_STATUS='signal.txt'
export V_SLEEP='5400'
export V_TEXT='running'
EOF
 ;;
  04-processes:4) cat <<'EOF'
export V_DIR='overcloud'
export V_PID='service.pid'
export V_STATUS='health.txt'
export V_SLEEP='9000'
export V_TEXT='active'
EOF
 ;;
  04-processes:5) cat <<'EOF'
export V_DIR='vault-office'
export V_PID='engine.pid'
export V_STATUS='marker.txt'
export V_SLEEP='2400'
export V_TEXT='running'
EOF
 ;;

  # ------------------------------------------------------------------ LAB 05
  05-text-processing:0) cat <<'EOF'
export V_DIR='text-lab'
export V_LOG='access.log'
export V_LOG_DATA='10.0.0.1 INFO /health 200
10.0.0.2 ERROR /api/users 500
10.0.0.3 INFO /api/orders 201
10.0.0.2 ERROR /api/payments 500
10.0.0.4 WARN /login 401
10.0.0.5 ERROR /api/users 503
10.0.0.6 INFO /assets/app.js 200
10.0.0.7 ERROR /api/orders 500'
export V_CSV='services.csv'
export V_CSV_DATA='service,region,requests
api,eu,120
web,eu,80
api,us,150
worker,eu,30
api,apac,70'
export V_OUT1='error_count.txt'
export V_OUT2='failing_ips.txt'
export V_OUT3='api_total.txt'
export V_OUT4='summary.txt'
export V_TEXT='log analysis complete'
EOF
 ;;
  05-text-processing:1) cat <<'EOF'
export V_DIR='text-sprint'
export V_LOG='requests.log'
export V_LOG_DATA='172.16.0.10 INFO /health 200
172.16.0.11 ERROR /api/users 500
172.16.0.12 WARN /login 401
172.16.0.11 ERROR /api/payments 500
172.16.0.13 INFO /api/orders 201
172.16.0.14 ERROR /api/users 503
172.16.0.11 WARN /jobs 400
172.16.0.15 ERROR /api/orders 500'
export V_CSV='services.txt'
export V_CSV_DATA='service,region,requests
api,eu,110
web,na,70
api,us,160
worker,eu,25
api,apac,90'
export V_OUT1='error_total.txt'
export V_OUT2='failed_ips.txt'
export V_OUT3='api_sum.txt'
export V_OUT4='concluding.txt'
export V_TEXT='analysis done'
EOF
 ;;
  05-text-processing:2) cat <<'EOF'
export V_DIR='logs-east'
export V_LOG='nginx.log'
export V_LOG_DATA='192.168.1.10 ERROR /upload 500
192.168.1.11 INFO /index 200
192.168.1.12 ERROR /api/auth 503
192.168.1.13 WARN /login 401
192.168.1.10 ERROR /api/auth 500
192.168.1.14 INFO /assets/x.js 200
192.168.1.10 WARN /jobs 400
192.168.1.12 ERROR /api/auth 500'
export V_CSV='services.dat'
export V_CSV_DATA='service,region,requests
api,eu,200
web,eu,40
api,us,50
worker,na,60
api,apac,80'
export V_OUT1='errs.txt'
export V_OUT2='bad_ips.txt'
export V_OUT3='api_summary.txt'
export V_OUT4='end.txt'
export V_TEXT='review ok'
EOF
 ;;
  05-text-processing:3) cat <<'EOF'
export V_DIR='logs-west'
export V_LOG='app.log'
export V_LOG_DATA='10.1.0.1 INFO /ping 200
10.1.0.2 ERROR /api/db 500
10.1.0.3 INFO /ping 200
10.1.0.2 ERROR /jobs 500
10.1.0.4 WARN /hooks 404
10.1.0.5 ERROR /api/db 503
10.1.0.6 INFO /health 200
10.1.0.7 ERROR /api/db 500'
export V_CSV='services.csv'
export V_CSV_DATA='service,region,requests
api,eu,180
db,eu,20
api,us,90
worker,eu,10
api,apac,110'
export V_OUT1='error_n.txt'
export V_OUT2='ip_fails.txt'
export V_OUT3='api_service.txt'
export V_OUT4='final.txt'
export V_TEXT='complete'
EOF
 ;;
  05-text-processing:4) cat <<'EOF'
export V_DIR='logs-north'
export V_LOG='gateway.log'
export V_LOG_DATA='192.168.10.1 INFO /status 200
192.168.10.2 ERROR /api/login 500
192.168.10.3 INFO /status 200
192.168.10.4 ERROR /api/login 503
192.168.10.2 ERROR /api/login 500
192.168.10.5 WARN /metrics 404
192.168.10.6 INFO /health 200
192.168.10.7 ERROR /metrics 500'
export V_CSV='services.txt'
export V_CSV_DATA='service,region,requests
api,eu,90
web,eu,110
api,us,60
worker,eu,35
api,apac,20'
export V_OUT1='err_total.txt'
export V_OUT2='fail_ip.txt'
export V_OUT3='api_req.txt'
export V_OUT4='verdict.txt'
export V_TEXT='done off'
EOF
 ;;
  05-text-processing:5) cat <<'EOF'
export V_DIR='logs-south'
export V_LOG='proxy.log'
export V_LOG_DATA='10.50.0.1 INFO /heartbeat 200
10.50.0.2 ERROR /api/pay 500
10.50.0.3 WARN /hooks 404
10.50.0.2 ERROR /api/pay 500
10.50.0.4 ERROR /api/pay 503
10.50.0.5 INFO /index 200
10.50.0.2 WARN /queue 400
10.50.0.6 ERROR /api/status 500'
export V_CSV='services.txt'
export V_CSV_DATA='service,region,requests
api,eu,150
web,eu,30
api,us,120
worker,eu,45
api,apac,25'
export V_OUT1='errors_total.txt'
export V_OUT2='ips_fail.txt'
export V_OUT3='api_summary.txt'
export V_OUT4='done.txt'
export V_TEXT='ok complete'
EOF
 ;;

  # ------------------------------------------------------------------ LAB 06
  06-navigation-search:0) cat <<'EOF'
export V_DIR='nav-lab'
export V_DOCS='docs'
export V_EVID='evidence'
export V_LOGS='logs'
export V_APP='app.log'
export V_RUNBOOK='runbook.txt'
export V_YR='2026'
export V_A='alpha'
export V_B='beta'
export V_ARC='archive'
export V_INC_PAT='incident-*.txt'
export V_OUT_CP='current_path.txt'
export V_OUT_RL='root_listing.txt'
export V_OUT_IF='incident_files.txt'
export V_OUT_LE='last_events.txt'
export V_OUT_OWN='owner.txt'
export V_OWNER='sre-oncall'
export V_SERVICE='learner-api'
EOF
 ;;
  06-navigation-search:1) cat <<'EOF'
export V_DIR='nav-operations'
export V_DOCS='manual'
export V_EVID='trails'
export V_LOGS='journal'
export V_APP='gateway.log'
export V_RUNBOOK='ops.txt'
export V_YR='2025'
export V_A='qa'
export V_B='staging'
export V_ARC='old'
export V_INC_PAT='eq-*.txt'
export V_OUT_CP='cwd.txt'
export V_OUT_RL='top.txt'
export V_OUT_IF='cases.txt'
export V_OUT_LE='recent.txt'
export V_OUT_OWN='escalate.txt'
export V_OWNER='db-admin'
export V_SERVICE='catalog-api'
EOF
 ;;
  06-navigation-search:2) cat <<'EOF'
export V_DIR='nav-relay'
export V_DOCS='wiki'
export V_EVID='dossier'
export V_LOGS='traces'
export V_APP='relay.log'
export V_RUNBOOK='guide.txt'
export V_YR='2024'
export V_A='hq'
export V_B='hub'
export V_ARC='done'
export V_INC_PAT='case-*.txt'
export V_OUT_CP='here.txt'
export V_OUT_RL='listing.txt'
export V_OUT_IF='files.txt'
export V_OUT_LE='events.txt'
export V_OUT_OWN='contact.txt'
export V_OWNER='netops'
export V_SERVICE='gateway-api'
EOF
 ;;
  06-navigation-search:3) cat <<'EOF'
export V_DIR='nav-scope'
export V_DOCS='manuals'
export V_EVID='forensics'
export V_LOGS='events2'
export V_APP='scanner.log'
export V_RUNBOOK='handbook.txt'
export V_YR='2025'
export V_A='west'
export V_B='east'
export V_ARC='closed'
export V_INC_PAT='case-*.txt'
export V_OUT_CP='position.txt'
export V_OUT_RL='root.txt'
export V_OUT_IF='incs.txt'
export V_OUT_LE='logtail.txt'
export V_OUT_OWN='owner2.txt'
export V_OWNER='oncall-ops'
export V_SERVICE='metrics-api'
EOF
 ;;
  06-navigation-search:4) cat <<'EOF'
export V_DIR='nav-aurora'
export V_DOCS='docs2'
export V_EVID='archives2'
export V_LOGS='logs2'
export V_APP='stream.log'
export V_RUNBOOK='runbook2.txt'
export V_YR='2023'
export V_A='qa'
export V_B='preprod'
export V_ARC='archive2'
export V_INC_PAT='incident-*.txt'
export V_OUT_CP='current2.txt'
export V_OUT_RL='listing2.txt'
export V_OUT_IF='incident2.txt'
export V_OUT_LE='events2.txt'
export V_OUT_OWN='owner2.txt'
export V_OWNER='alerting'
export V_SERVICE='stream-api'
EOF
 ;;
  06-navigation-search:5) cat <<'EOF'
export V_DIR='nav-horizon'
export V_DOCS='rdocs'
export V_EVID='evidences'
export V_LOGS='logstream'
export V_APP='proxy.log'
export V_RUNBOOK='procedure.txt'
export V_YR='2026'
export V_A='alpha'
export V_B='beta'
export V_ARC='archeo'
export V_INC_PAT='c-*.txt'
export V_OUT_CP='current-path.txt'
export V_OUT_RL='top-list.txt'
export V_OUT_IF='incidents.txt'
export V_OUT_LE='tail.txt'
export V_OUT_OWN='oncall.txt'
export V_OWNER='incident-response'
export V_SERVICE='proxy-api'
EOF
 ;;

  # ------------------------------------------------------------------ LAB 07
  07-storage-archives:0) cat <<'EOF'
export V_DIR='storage-lab'
export V_DS='datasets'
export V_A='service-a'
export V_B='service-b'
export V_BIG='big'
export V_CFG='config.yml'
export V_APP='app.log'
export V_README='readme.txt'
export V_BLOB='blob.bin'
export V_ARC='service-a.tar.gz'
export V_RESTORE='restore'
export V_OUT_FS='filesystem_report.txt'
export V_OUT_SIZE='dataset_size.txt'
export V_OUT_ITEM='largest_item.txt'
export V_PORT='8080'
export V_MODE='training'
EOF
 ;;
  07-storage-archives:1) cat <<'EOF'
export V_DIR='storage-stats'
export V_DS='data'
export V_A='api-svc'
export V_B='job-svc'
export V_BIG='huge'
export V_CFG='settings.yaml'
export V_APP='events.log'
export V_README='notes.txt'
export V_BLOB='data.chunk'
export V_ARC='api-svc.tar.gz'
export V_RESTORE='recover'
export V_OUT_FS='fs-report.txt'
export V_OUT_SIZE='volume.txt'
export V_OUT_ITEM='bigger.txt'
export V_PORT='8443'
export V_MODE='test'
EOF
 ;;
  07-storage-archives:2) cat <<'EOF'
export V_DIR='storage-box'
export V_DS='collections'
export V_A='catalog'
export V_B='inventory'
export V_BIG='bunker'
export V_CFG='config.yaml'
export V_APP='access.log'
export V_README='info.txt'
export V_BLOB='payload.bin'
export V_ARC='catalog.tar.gz'
export V_RESTORE='unpack'
export V_OUT_FS='fs.txt'
export V_OUT_SIZE='sizes.txt'
export V_OUT_ITEM='largest.txt'
export V_PORT='9090'
export V_MODE='staging'
EOF
 ;;
  07-storage-archives:3) cat <<'EOF'
export V_DIR='storage-med'
export V_DS='records'
export V_A='clinic-a'
export V_B='clinic-b'
export V_BIG='immagini'
export V_CFG='settings.yml'
export V_APP='visits.log'
export V_README='guide.txt'
export V_BLOB='image.img'
export V_ARC='clinic-a.tar.gz'
export V_RESTORE='ripristina'
export V_OUT_FS='partition.txt'
export V_OUT_SIZE='usage.txt'
export V_OUT_ITEM='biggest.txt'
export V_PORT='8888'
export V_MODE='training'
EOF
 ;;
  07-storage-archives:4) cat <<'EOF'
export V_DIR='storage-edge'
export V_DS='nodes'
export V_A='node-a'
export V_B='node-b'
export V_BIG='raw'
export V_CFG='conf.yml'
export V_APP='node.log'
export V_README='readme2.txt'
export V_BLOB='binary.blob'
export V_ARC='node-a.tar.gz'
export V_RESTORE='restore2'
export V_OUT_FS='filesystems.txt'
export V_OUT_SIZE='blocks.txt'
export V_OUT_ITEM='huge-item.txt'
export V_PORT='7070'
export V_MODE='prod'
EOF
 ;;
  07-storage-archives:5) cat <<'EOF'
export V_DIR='storage-hq'
export V_DS='backups'
export V_A='web-a'
export V_B='db-b'
export V_BIG='store'
export V_CFG='app.yaml'
export V_APP='audit.log'
export V_README='readme.txt'
export V_BLOB='archive.dat'
export V_ARC='web-a.tar.gz'
export V_RESTORE='extract'
export V_OUT_FS='disk-report.txt'
export V_OUT_SIZE='total-size.txt'
export V_OUT_ITEM='max.txt'
export V_PORT='6000'
export V_MODE='training'
EOF
 ;;

  # ------------------------------------------------------------------ LAB 08
  08-system-admin:0) cat <<'EOF'
export V_DIR='admin-lab'
export V_USER='auditor'
export V_LOG_TAG='assisted-lab'
export V_LOG_MSG='ciao da assisted-lab'
export V_CRON_FILE='nightly.cron'
export V_CRON_LINE='17 3 * * * /usr/local/bin/lab doctor >/tmp/lab-doctor.log 2>&1'
export V_SYSLOG='/var/log/messages'
export V_OUT_TOP='top_snapshot.txt'
export V_OUT_MEM='memory_report.txt'
export V_OUT_VER='openrc_version.txt'
export V_OUT_SYS='syslog_snapshot.txt'
export V_OUT_SUDO='sudo_user.txt'
export V_OUT_CRON='installed_cron.txt'
EOF
 ;;
  08-system-admin:1) cat <<'EOF'
export V_DIR='admin-ops'
export V_USER='inspector'
export V_LOG_TAG='edu-lab'
export V_LOG_MSG='segnale da edu-lab'
export V_CRON_FILE='nightly-batch'
export V_CRON_LINE='23 4 * * * /opt/assisted-labs/bin/lab status >/tmp/lab-status.log 2>&1'
export V_SYSLOG='/var/log/messages'
export V_OUT_TOP='top.txt'
export V_OUT_MEM='memory.txt'
export V_OUT_VER='version.txt'
export V_OUT_SYS='syslog.txt'
export V_OUT_SUDO='who.txt'
export V_OUT_CRON='cron.txt'
EOF
 ;;
  08-system-admin:2) cat <<'EOF'
export V_DIR='admin-box'
export V_USER='sonda'
export V_LOG_TAG='probe'
export V_LOG_MSG='battito del probe'
export V_CRON_FILE='cleanup.cron'
export V_CRON_LINE='5 1 * * 0 /usr/bin/logrotate /etc/logrotate.conf >/dev/null 2>&1'
export V_SYSLOG='/var/log/messages'
export V_OUT_TOP='cpu.txt'
export V_OUT_MEM='ram.txt'
export V_OUT_VER='openrc.txt'
export V_OUT_SYS='blog.txt'
export V_OUT_SUDO='su-user.txt'
export V_OUT_CRON='crondump.txt'
EOF
 ;;
  08-system-admin:3) cat <<'EOF'
export V_DIR='admin-desk'
export V_USER='moderatore'
export V_LOG_TAG='module'
export V_LOG_MSG='startup compiuto'
export V_CRON_FILE='hourly.cron'
export V_CRON_LINE='42 6 * * * /usr/bin/logger -t state "daily report"'
export V_SYSLOG='/var/log/messages'
export V_OUT_TOP='proc_top.txt'
export V_OUT_MEM='mem_report.txt'
export V_OUT_VER='openrc2.txt'
export V_OUT_SYS='messages.txt'
export V_OUT_SUDO='sudo_user.txt'
export V_OUT_CRON='active_cron.txt'
EOF
 ;;
  08-system-admin:4) cat <<'EOF'
export V_DIR='admin-west'
export V_USER='qualificatore'
export V_LOG_TAG='westlab'
export V_LOG_MSG='westlab ok'
export V_CRON_FILE='schedule.cron'
export V_CRON_LINE='15 2 * * * /usr/bin/date >/tmp/day.log 2>&1'
export V_SYSLOG='/var/log/messages'
export V_OUT_TOP='tops.txt'
export V_OUT_MEM='freemem.txt'
export V_OUT_VER='release.txt'
export V_OUT_SYS='sys.txt'
export V_OUT_SUDO='userid.txt'
export V_OUT_CRON='listcron.txt'
EOF
 ;;
  08-system-admin:5) cat <<'EOF'
export V_DIR='admin-north'
export V_USER='monitor'
export V_LOG_TAG='north'
export V_LOG_MSG='north online'
export V_CRON_FILE='maintenance.cron'
export V_CRON_LINE='30 8 * * * /usr/local/bin/lab readme >/tmp/lab-read.log 2>&1'
export V_SYSLOG='/var/log/messages'
export V_OUT_TOP='proc_snap.txt'
export V_OUT_MEM='free.txt'
export V_OUT_VER='init.txt'
export V_OUT_SYS='syslog2.txt'
export V_OUT_SUDO='asses.txt'
export V_OUT_CRON='crons.txt'
EOF
 ;;

  # ------------------------------------------------------------------ LAB 09
  09-network-transfer:0) cat <<'EOF'
export V_DIR='net-lab'
export V_REMOTE='remote'
export V_NESTED='nested'
export V_COPIES='copies'
export V_MIRROR='mirror'
export V_JSON='status.json'
export V_INFO='info.txt'
export V_SCP='status.scp.json'
export V_PORT='8088'
export V_SVC='training-api'
export V_JSON_DATA='{"service":"training-api","status":"ok","port":8088}'
export V_OUT_CIDR='loopback_cidr.txt'
export V_OUT_LIS='listening_8088.txt'
export V_OUT_PING='ping_localhost.txt'
export V_OUT_FETCH='fetched_status.json'
export V_OUT_SSH='ssh_version.txt'
EOF
 ;;
  09-network-transfer:1) cat <<'EOF'
export V_DIR='net-bv'
export V_REMOTE='origin'
export V_NESTED='deep'
export V_COPIES='downloads'
export V_MIRROR='snapshot'
export V_JSON='data.json'
export V_INFO='notes.txt'
export V_SCP='data.scp.json'
export V_PORT='9091'
export V_SVC='inventory-api'
export V_JSON_DATA='{"service":"inventory-api","status":"ok","port":9091}'
export V_OUT_CIDR='cidr.txt'
export V_OUT_LIS='listening_9091.txt'
export V_OUT_PING='ping.txt'
export V_OUT_FETCH='fetched.json'
export V_OUT_SSH='ssh_ver.txt'
EOF
 ;;
  09-network-transfer:2) cat <<'EOF'
export V_DIR='net-gw'
export V_REMOTE='source'
export V_NESTED='inside'
export V_COPIES='backup'
export V_MIRROR='sync'
export V_JSON='health.json'
export V_INFO='meta.txt'
export V_SCP='health.scp.json'
export V_PORT='8443'
export V_SVC='frontend'
export V_JSON_DATA='{"service":"frontend","status":"ok","port":8443}'
export V_OUT_CIDR='loopback.txt'
export V_OUT_LIS='listen.txt'
export V_OUT_PING='ping_localhost.txt'
export V_OUT_FETCH='fetched_status.txt'
export V_OUT_SSH='ssh.txt'
EOF
 ;;
  09-network-transfer:3) cat <<'EOF'
export V_DIR='net-edge'
export V_REMOTE='upstream'
export V_NESTED='level2'
export V_COPIES='local'
export V_MIRROR='clone'
export V_JSON='state.json'
export V_INFO='data.txt'
export V_SCP='state.scp.json'
export V_PORT='7000'
export V_SVC='edge-api'
export V_JSON_DATA='{"service":"edge-api","status":"ok","port":7000}'
export V_OUT_CIDR='cidr.txt'
export V_OUT_LIS='listening.txt'
export V_OUT_PING='ping.txt'
export V_OUT_FETCH='fetched.json'
export V_OUT_SSH='version.txt'
EOF
 ;;
  09-network-transfer:4) cat <<'EOF'
export V_DIR='net-core'
export V_REMOTE='hub'
export V_NESTED='dir2'
export V_COPIES='locality'
export V_MIRROR='shadow'
export V_JSON='report.json'
export V_INFO='info2.txt'
export V_SCP='report.scp.json'
export V_PORT='5678'
export V_SVC='core-svc'
export V_JSON_DATA='{"service":"core-svc","status":"ok","port":5678}'
export V_OUT_CIDR='lo.txt'
export V_OUT_LIS='listen2.txt'
export V_OUT_PING='ping2.txt'
export V_OUT_FETCH='got.json'
export V_OUT_SSH='ver.txt'
EOF
 ;;
  09-network-transfer:5) cat <<'EOF'
export V_DIR='net-sandbox'
export V_REMOTE='farm'
export V_NESTED='sub'
export V_COPIES='dupes'
export V_MIRROR='clone2'
export V_JSON='probe.json'
export V_INFO='notes2.txt'
export V_SCP='probe.scp.json'
export V_PORT='1234'
export V_SVC='sandbox-api'
export V_JSON_DATA='{"service":"sandbox-api","status":"ok","port":1234}'
export V_OUT_CIDR='lo-back.txt'
export V_OUT_LIS='listener.txt'
export V_OUT_PING='ping3.txt'
export V_OUT_FETCH='probe.json'
export V_OUT_SSH='ssh_ver.txt'
EOF
 ;;

  # ------------------------------------------------------------------ LAB 10
  10-file-comparison:0) cat <<'EOF'
export V_DIR='diff-lab'
export V_CFG_OLD='config.old.conf'
export V_CFG_NEW='config.new.conf'
export V_CFG_OLD_DATA='port=8080
timeout=30
mode=production'
export V_CFG_NEW_DATA='port=8443
timeout=30
mode=production'
export V_REP_A='report_a.txt'
export V_REP_B='report_b.txt'
export V_REP_TXT='build 482 completato senza errori'
export V_PROD='servers_prod.txt'
export V_PROD_DATA='host-a
host-b
host-c
host-d'
export V_STAG='servers_staging.txt'
export V_STAG_DATA='host-b
host-c
host-e'
export V_REL_A='release_v1'
export V_REL_B='release_v2'
export V_APP_CONF='app.conf'
export V_VER_A='1.0.0'
export V_VER_B='1.1.0'
export V_DEPRECATED='deprecated.old'
export V_OUT_DIFF='config.diff'
export V_OUT_CHECK='report_check.txt'
export V_OUT_ONLY='only_prod.txt'
export V_OUT_REL='release_diff.txt'
export V_VERD="identici"
EOF
 ;;
  10-file-comparison:1) cat <<'EOF'
export V_DIR='diff-prod'
export V_CFG_OLD='app.old.conf'
export V_CFG_NEW='app.new.conf'
export V_CFG_OLD_DATA='port=7000
timeout=45
mode=production'
export V_CFG_NEW_DATA='port=7777
timeout=45
mode=production'
export V_REP_A='bu1.txt'
export V_REP_B='bu2.txt'
export V_REP_TXT='job 991 completato con esito ok'
export V_PROD='live_hosts.txt'
export V_PROD_DATA='srv-a
srv-b
srv-d
srv-f'
export V_STAG='stage_hosts.txt'
export V_STAG_DATA='srv-b
srv-c
srv-f'
export V_REL_A='gen_v1'
export V_REL_B='gen_v2'
export V_APP_CONF='app.conf'
export V_VER_A='1.0.0'
export V_VER_B='2.0.0'
export V_DEPRECATED='legacy.old'
export V_OUT_DIFF='config.diff'
export V_OUT_CHECK='report_check.txt'
export V_OUT_ONLY='only_prod.txt'
export V_OUT_REL='release_diff.txt'
export V_VERD="identici"
EOF
 ;;
  10-file-comparison:2) cat <<'EOF'
export V_DIR='diff-set'
export V_CFG_OLD='old.cnf'
export V_CFG_NEW='new.cnf'
export V_CFG_OLD_DATA='port=4444
workers=2
mode=dev'
export V_CFG_NEW_DATA='port=5555
workers=2
mode=dev'
export V_REP_A='left.txt'
export V_REP_B='right.txt'
export V_REP_TXT='check 55 passa'
export V_PROD='prod_list.txt'
export V_PROD_DATA='n1
n2
n3'
export V_STAG='stage_list.txt'
export V_STAG_DATA='n2
n4'
export V_REL_A='drop_v1'
export V_REL_B='drop_v2'
export V_APP_CONF='app.conf'
export V_VER_A='0.9.0'
export V_VER_B='1.1.0'
export V_DEPRECATED='old.tmp'
export V_OUT_DIFF='config.diff'
export V_OUT_CHECK='report_check.txt'
export V_OUT_ONLY='only_prod.txt'
export V_OUT_REL='release_diff.txt'
export V_VERD="identici"
EOF
 ;;
  10-file-comparison:3) cat <<'EOF'
export V_DIR='diff-trade'
export V_CFG_OLD='ops.old'
export V_CFG_NEW='ops.new'
export V_CFG_OLD_DATA='port=3333
region=eu-central
pool=small'
export V_CFG_NEW_DATA='port=4444
region=eu-central
pool=small'
export V_REP_A='snapshot_a.txt'
export V_REP_B='snapshot_b.txt'
export V_REP_TXT='report 7 valido'
export V_PROD='prod_nodes.txt'
export V_PROD_DATA='p1
p2
p3
p4'
export V_STAG='stage_nodes.txt'
export V_STAG_DATA='p2
p3
p5'
export V_REL_A='rel-31'
export V_REL_B='rel-32'
export V_APP_CONF='app.conf'
export V_VER_A='3.1.0'
export V_VER_B='3.2.0'
export V_DEPRECATED='obsolete.old'
export V_OUT_DIFF='config.diff'
export V_OUT_CHECK='report_check.txt'
export V_OUT_ONLY='only_prod.txt'
export V_OUT_REL='release_diff.txt'
export V_VERD="identici"
EOF
 ;;
  10-file-comparison:4) cat <<'EOF'
export V_DIR='diff-qa'
export V_CFG_OLD='config.old'
export V_CFG_NEW='config.new'
export V_CFG_OLD_DATA='port=8443
debug=true'
export V_CFG_NEW_DATA='port=9000
debug=true'
export V_REP_A='res_a.txt'
export V_REP_B='res_b.txt'
export V_REP_TXT='conclusione con successo'
export V_PROD='hosts.lst'
export V_PROD_DATA='alpha
beta
delta
gamma'
export V_STAG='staging.lst'
export V_STAG_DATA='beta
epsilon
gamma'
export V_REL_A='canary_v1'
export V_REL_B='canary_v2'
export V_APP_CONF='app.conf'
export V_VER_A='0.1.1'
export V_VER_B='0.1.2'
export V_DEPRECATED='stale.conf'
export V_OUT_DIFF='config.diff'
export V_OUT_CHECK='report_check.txt'
export V_OUT_ONLY='only_prod.txt'
export V_OUT_REL='release_diff.txt'
export V_VERD="identici"
EOF
 ;;
  10-file-comparison:5) cat <<'EOF'
export V_DIR='diff-wg'
export V_CFG_OLD='wg.old'
export V_CFG_NEW='wg.new'
export V_CFG_OLD_DATA='port=2222
mode=sandbox
limit=10'
export V_CFG_NEW_DATA='port=3333
mode=sandbox
limit=10'
export V_REP_A='check_a.txt'
export V_REP_B='check_b.txt'
export V_REP_TXT='tutti i controlli ok'
export V_PROD='prod.hosts'
export V_PROD_DATA='mx1
mx2
mx3
mx4'
export V_STAG='staging.hosts'
export V_STAG_DATA='mx2
mx3
mx5'
export V_REL_A='branch_a'
export V_REL_B='branch_b'
export V_APP_CONF='app.conf'
export V_VER_A='1.4.0'
export V_VER_B='1.5.0'
export V_DEPRECATED='dead.txt'
export V_OUT_DIFF='config.diff'
export V_OUT_CHECK='report_check.txt'
export V_OUT_ONLY='only_prod.txt'
export V_OUT_REL='release_diff.txt'
export V_VERD="identici"
EOF
 ;;
  esac
}

# hcv_labs — lab supportati dal motore (in ordine).
hcv_labs() {
  find "${LABS:-/opt/assisted-labs/labs}" -mindepth 1 -maxdepth 1 -type d \
    -printf '%f\n' 2>/dev/null | sort
}

# hcv_set_base — esporta per ogni lab i valori BASE (variante 0).
# Chiamata all'avvio del CLI: in STANDARD/ARCADE le V_* restano i base.
hcv_set_base() {
  local id
  for id in $(hcv_labs); do
    eval "$(hcv_values "$id" 0)"
  done
}

# hcv_count <lab-id> — stampa il numero di varianti (default VAR_COUNT).
hcv_count() {
  printf '%s' "$VAR_COUNT"
}

# hcv_pick <lab-id> — stampa un numero di variante valido (1..N).
hcv_pick() {
  local lab="$1" n
  n=$(( RANDOM % VAR_COUNT + 1 ))
  printf '%s' "$n"
}