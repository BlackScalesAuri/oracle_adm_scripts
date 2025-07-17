/*
    Lista Jobs e Scheduled jobs em execucao
*/
@set
SET VERIFY OFF

prompt == DBA_JOBS(Deprecated) em execucao ======================================================================================================================================================================================

SELECT 
    LOWNER,V.SID, V.ID2 JOB, J.FAILURES,
    LAST_DATE, SUBSTR(TO_CHAR(LAST_DATE,'HH24:MI:SS'),1,8) LAST_SEC,
    THIS_DATE, SUBSTR(TO_CHAR(THIS_DATE,'HH24:MI:SS'),1,8) THIS_SEC,
    V.INST_ID INSTANCE
FROM 
    SYS.JOB$ J, GV$LOCK V
WHERE
    V.TYPE = 'JQ' AND J.JOB(+) = V.ID2; 

prompt == Scheduled Jobs em execucao ============================================================================================================================================================================================

SELECT
    OWNER,
    JOB_NAME,
    SESSION_ID "SID",
    'exec DBMS_SCHEDULER.STOP_JOB('''|| OWNER || '.' || JOB_NAME || ''', force=>true);'
FROM
    dba_scheduler_running_jobs;