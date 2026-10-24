#!/bin/bash

export LOG_FILE=/backup-postgresql/migracao/rsync_check.log
export DIR_ORIGEM="mv@10.7.7.66:/pg_backup/fisico/*"
export DIR_DESTINO=/backup-postgresql/migracao/
export TAG_RSYNC="-Padr --size-only"

date >> $LOG_FILE
echo "Checando por processos em execucao" >> $LOG_FILE
COUNT=`ps ax | grep rsync | grep -v grep | grep -v rsync_check.sh | grep -v less | grep -v tail | wc -l`
echo "Existem $COUNT processos Rsync em execução" >> $LOG_FILE
if [ $COUNT -eq 0 ]
then
        echo "Sem Rsync em execucao, reiniciando processo" >> $LOG_FILE
        ##killall rsync  # Previne enfileiramento de processos, não usar em ambiente com rotina de rsync;
        rsync ${DIR_ORIGEM} ${DIR_DESTINO} ${TAG_RSYNC} >> $LOG_FILE
fi