/*
Traz log de execução dos ultimos scheduled jobs
*/
SET VERIFY OFF

COL "LOG_DATE"          FORMAT A40
COL "OWNER"             FORMAT A30
COL "JOB_NAME"          FORMAT A30
COL "RUN_DURATION"      FORMAT A15
COL "STATUS"            FORMAT A25
COL "REQ_START_DATE"    FORMAT A40
COL "ACTUAL_START_DATE" FORMAT A40

accept VAR_NOME prompt  'INFORME O NOME DO JOB: '
accept VAR_OWNER prompt 'INFORME O OWNER      : '

prompt == JOBs =====================================================================================================================================================================================================================================
select
    LOG_DATE,
    OWNER,
    JOB_NAME,
    RUN_DURATION,
    STATUS,
    ERROR#,
    REQ_START_DATE,
    ACTUAL_START_DATE
from
    DBA_SCHEDULER_JOB_RUN_DETAILS
where
    UPPER(JOB_NAME) LIKE(UPPER('%&VAR_NOME%')) AND
    UPPER(OWNER) LIKE(UPPER('%&VAR_OWNER%'))
order by
    LOG_DATE desc;


CLEAR COL
UNDEF VAR_OWNER VAR_NOME