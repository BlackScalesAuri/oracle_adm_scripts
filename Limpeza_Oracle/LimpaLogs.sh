#!/bin/sh

# Uso [COMO ROOT] LimpaLogs.sh <Caminho Log>
# */5 * * * * sh /home/oracle/flowti/scripts/LimpaLogs.sh /home/oracle/flowti/scripts/logs >> /dev/null

export LOG_FILE=$1/limpaLogs_`date '+%d%m%Y'`.log

## Apagar arquivos de Logs SGDB
# Listar arquivos
find /orabin01/app/oracle/diag/rdbms/*/*/cdump/core_*      -mtime +3 -type d -exec rm -frv {} \; >> $LOG_FILE
find /orabin01/app/oracle/diag/rdbms/*/*/incident/incdir_* -mtime +3 -type d -exec rm -frv {} \; >> $LOG_FILE
find /orabin01/app/oracle/diag/rdbms/*/*/trace/cdmp_*      -mtime +3 -type d -exec rm -frv {} \; >> $LOG_FILE
find /orabin01/app/oracle/diag/rdbms/*/*/alert/log_*.xml   -mtime +3 -type f -exec rm -frv {} \; >> $LOG_FILE

find /orabin01/app/oracle/diag/rdbms/*/*/trace/*.trm      -mtime +3 -type f -exec rm -frv {} \; >> $LOG_FILE
find /orabin01/app/oracle/diag/rdbms/*/*/trace/*.trc      -mtime +3 -type f -exec rm -frv {} \; >> $LOG_FILE

# Limpar arquivos ASM
find /orabin01/app/grid/diag/asm/*/*/trace/ -mtime +5 -type f -name '*ufg*' -exec rm -frv {} \; >> $LOG_FILE
find /orabin01/app/grid/diag/asm/*/*/trace/ -mtime +5 -type f -name '*nfg*' -exec rm -frv {} \; >> $LOG_FILE

# Limpar Logs
find $1 -type f -mtime +5 -name "limpaLogs_*.log" -exec rm -frv {} \; >> $LOG_FILE

# CONFIGURE ARCHIVELOG DELETION POLICY TO BACKED UP 1 TIMES TO DISK; # default

# adrci
# set control (SHORTP_POLICY = 168) — 7 days
# set control (LONGP_POLICY = 460) — 15 Days