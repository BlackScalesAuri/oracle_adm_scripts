/*
    Lista info. de jobs cadastrados 
    Lista Jobs e Scheduled jobs em execucao
*/
@set
SET VERIFY OFF

COL "WHAT"             FORMAT A80
COL "LAST"             FORMAT A20
COL "LOG_USER"         FORMAT A20
COL "owner"            FORMAT A15
COL "job_name"             FORMAT A30
COL "enabled"           FORMAT A7
COL "fail"         FORMAT 9999
COL "last_start_date"         FORMAT A36
COL "next_run_date"         FORMAT A36

accept VAR_OWNER prompt 'INFORME O OWNER: '


prompt == DBA_JOBS(Deprecated) ==================================================================================================================================================================================================
prompt
SELECT 
    LOG_USER,
    JOB,
    'EXEC ' || UPPER(WHAT) WHAT,
    BROKEN,
    FAILURES,
    TO_CHAR(LAST_DATE, 'DD/MM/YYYY HH24:MI:SS') LAST,
    TO_CHAR(NEXT_DATE, 'DD/MM/YYYY HH24:MI:SS') NEXT
FROM
    DBA_JOBS
WHERE 
    LOG_USER LIKE UPPER('%&VAR_OWNER%')
ORDER BY WHAT;

prompt == Scheduled Jobs ========================================================================================================================================================================================================

SELECT 
    j.owner,
    j.enabled,
    NVL(f.failures, 0) AS fail,
    j.job_name,
    COALESCE(j.program_name, j.job_action) AS WHAT,
    j.last_start_date,
    j.next_run_date
FROM 
    dba_scheduler_jobs j
LEFT JOIN (
    /* conta quantas execucoes falharam */
    SELECT 
        job_name,
        COUNT(*) AS failures
    FROM 
        dba_scheduler_job_run_details
    WHERE 
        status != 'SUCCEEDED'
    GROUP BY 
        job_name
) f 
  ON j.job_name = f.job_name
ORDER BY 
    j.owner, j.job_name;


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

CLEAR COL
UNDEF VAR_OWNER