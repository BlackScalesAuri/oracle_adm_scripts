/*
Script para copiar grants de um usuario
*/
@set
set trimspo on
set head off
set feedback off
SET VERIFY OFF

ACCEPT VAR_USER_O PROMPT 'INFORME O USER ORIGEM    : '
ACCEPT VAR_USER_D PROMPT 'INFORME O USER A RECEBER : '
ACCEPT VAR_SPOOL  PROMPT 'INFORME O SPOOL PATH     : '

spo &VAR_SPOOL
select 'grant '||granted_role||' to "&VAR_USER_D";'
from DBA_ROLE_PRIVS where grantee = upper('&VAR_USER_O');

select 'grant '||privilege||' to "&VAR_USER_D";'
from DBA_SYS_PRIVS where grantee = upper('&VAR_USER_O');

select 'grant '||privilege||' on "'||owner||'"."'||table_name||'" to "&VAR_USER_D";'
from DBA_TAB_PRIVS where grantee = upper('&VAR_USER_O');

select 'grant '||privilege||' ('||column_name||') '||' on "'||owner||'"."'||table_name||'" to "&VAR_USER_D";'
from DBA_COL_PRIVS where grantee = upper('&VAR_USER_O');

SPO off
set head on
set feedback on

UNDEF VAR_USER_O VAR_USER_D VAR_SPOOL
