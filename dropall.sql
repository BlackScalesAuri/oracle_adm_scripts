/*
Gera script para drop de todos os objetos de um owner
*/

@set

ACCEPT VAR_OWNER PROMPT 'INFORME O OWNER             : '
ACCEPT VAR_SPOOL PROMPT 'INFORME O DIRETORIO DE SPOOL: '

PROMPT SET ECHO ON
PROMPT SET FEEDBACK ON

SET HEADING OFF
set FEEDBACK OFF
SET VERIFY OFF
set trimspool on
set trim on
set pages 30000
set lines 5000


spool "&VAR_SPOOL/DROP_ALL_&VAR_OWNER..SQL"

select 'ALTER TABLE '||OWNER||'."'||TABLE_NAME||'" DROP CONSTRAINT "'||CONSTRAINT_NAME||'";' from dba_constraints where owner = upper('&VAR_OWNER') and constraint_type = 'R'
/
select DISTINCT 'DROP SEQUENCE '||SEQUENCE_OWNER||'."'||SEQUENCE_NAME||'";' from dba_sequences where sequence_owner = upper('&VAR_OWNER')
/
select DISTINCT 'DROP '||TYPE||' '||OWNER||'."'||NAME||'";' from dba_source where owner = upper('&VAR_OWNER')
/
select 'DROP VIEW '||OWNER||'."'|| VIEW_NAME||'";' from dba_views where owner = upper('&VAR_OWNER')
/
select 'DROP TABLE '||OWNER||'."'||TABLE_NAME||'" PURGE;' from dba_tables where owner = upper('&VAR_OWNER')
/
select 'DROP SYNONYM '||OWNER||'."'||SYNONYM_NAME||'";' from dba_synonyms where owner = upper('&VAR_OWNER')
/
select 'DROP TYPE '||OWNER||'."'||TYPE_NAME||'";' from dba_types where owner = upper('&VAR_OWNER')
/
select 'DROP MATERIALIZED VIEW '||OWNER||'."'||MVIEW_NAME||'";' from dba_mviews where owner = upper('&VAR_OWNER')
/
SELECT 'PURGE TABLE ' || OWNER || '."' || ORIGINAL_NAME  || '";' FROM dba_recyclebin  WHERE owner = upper('&VAR_OWNER') and type = 'TABLE'
/
select 'drop public synonym ' || synonym_name || ';' from dba_synonyms where table_owner = upper('&VAR_OWNER') and owner = 'PUBLIC' and db_link is null order by synonym_name
/
select 'drop synonym ' || owner || '.' || synonym_name || ';' from dba_synonyms where table_owner = upper('&VAR_OWNER') and owner != 'PUBLIC' and db_link is null order by owner, synonym_name
/
select 'exec sys.dbms_ijob.remove(' || job || ');' from dba_jobs where  log_user like '&VAR_OWNER' or priv_user like '&VAR_OWNER' or schema_user like '&VAR_OWNER'
/
select 'exec sys.DBMS_SCHEDULER.DROP_JOB(Job_name =>''' || OWNER || '.' || JOB_NAME || ''');' from dba_scheduler_jobs where owner like '&VAR_OWNER'
/

PROMPT select count(1), object_type from dba_objects where owner='&VAR_OWNER' group by object_type;;

PROMPT

SET HEADING ON
set FEEDBACK ON
SET VERIFY ON
SPOOL OFF

PROMPT "EXECUTE: @&VAR_SPOOL/DROP_ALL_&VAR_OWNER..SQL"