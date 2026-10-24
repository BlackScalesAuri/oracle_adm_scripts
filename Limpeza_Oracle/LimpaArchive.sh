#!/bin/sh

# Uso: LimpaArchive.sh <SID> <Caminho Log>
# 30 1 * * * sh /home/oracle/flowti/LimpaArchive.sh CDB1 /home/oracle/flowti/LogsLimpaArchive

export ORACLE_HOME=/u01/app/oracle/product/12.1.0.2/dbhome_1/
export PATH=/usr/lib64/qt-3.3/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/u01/app/oracle/product/12.1.0.2/dbhome_1/bin:/home/oracle/.local/bin:/home/oracle/bin
export ORACLE_SID=$1
export LOG_FILE=$2/limpaArchive_${ORACLE_SID}_`date '+%d%m%Y_%H%M'`.log

rman target / <<EOF >> ${LOG_FILE}
DELETE NOPROMPT ARCHIVELOG ALL BACKED UP 1 TIMES TO SBT_TAPE;
exit;
EOF

echo
echo "Limpando Logs" >> $LOG_FILE
echo
find $2 -type f -mtime +5 -name "limpaArchive_*.log" -exec rm -fv {} \; >> $LOG_FILE