/*
Lista e mata sessão de datapump
*/

@set

select * from dba_datapump_jobs;

DECLARE
h1 NUMBER;
BEGIN
-- Format: DBMS_DATAPUMP.ATTACH('[job_name]','[owner_name]');
h1:= DBMS_DATAPUMP.ATTACH('&NOME_DO_JOB','&OWNER');
DBMS_DATAPUMP.STOP_JOB (h1,1,0);
END;
/

undef NOME_DO_JOB, OWNER