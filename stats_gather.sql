/*
    Gera script de coleta de staticas por owner
*/

@set
set trimspo on

ACCEPT VAR_OWNER PROMPT 'INFORME O OWNER: '
ACCEPT VAR_SPO PROMPT   'INFORME O LOCAL: '

spo &VAR_SPO/GATHER_STATS_&VAR_OWNER..sql

select 'exec DBMS_STATS.GATHER_TABLE_STATS(''' || owner || ''',''' || table_name|| ''');'
from dba_tables
where owner not in ('SYS','SYSTEM')
and owner like upper('%&VAR_OWNER%')
order by owner, table_name
/

prompt "execute:"
prompt "&VAR_SPO/GATHER_STATS_&VAR_OWNER..sql"

undef VAR_SPO, VAR_OWNER