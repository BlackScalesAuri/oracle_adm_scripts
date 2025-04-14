/*
Lista Todas as sessões
*/
@set
SET WRAP ON
ACCEPT VAR_USER PROMPT 'INFORME O USUARIO (ORACLE): '
ACCEPT VAR_OS PROMPT   'INFORME O USUARIO (OS)    : '
ACCEPT VAR_PRGM PROMPT 'INFORME O PROGRAMA        : '
ACCEPT VAR_MCH PROMPT  'INFORME A MACHINE         : '
ACCEPT VAR_SID PROMPT  'INFORME O SID             : '

col USERNAME for a18 
col OSUSER for a18 TRU
col ACESSO for a11 
col LOGIN for a11
col TEMPO for a11
col PROGRAM for a30 TRU
col MACHINE for a20 TRU
col TERMINAL for a18 TRU

SELECT inst_id, SID, USERNAME,
    STATUS,
    OSUSER,
    PROGRAM,
    TO_CHAR(LOGON_TIME, 'DD/MM HH24:MI') "LOGIN",
    TO_CHAR(SYSDATE - (LAST_CALL_ET) / 86400,'DD/MM HH24:MI') ACESSO,
    LPAD(TRIM(TO_CHAR(FLOOR(((SYSDATE-LOGON_TIME)*86400)/(3600)), 900)) ||':'|| TRIM(TO_CHAR(FLOOR((((SYSDATE-LOGON_TIME)*86400) - (FLOOR(((SYSDATE-LOGON_TIME)*86400)/(3600))*3600))/60), 900)) ||':'||TRIM(TO_CHAR(MOD((((SYSDATE-LOGON_TIME)*86400) - (FLOOR(((SYSDATE-LOGON_TIME)*86400)/(3600))*3600)),60), 900)), 10, ' ') "TEMPO",
    LPAD(TRIM(TO_CHAR(FLOOR(LAST_CALL_ET/(3600)),900)||':'||TRIM(TO_CHAR(FLOOR((LAST_CALL_ET - (FLOOR(LAST_CALL_ET/(3600))*3600))/60),900))||':'||TRIM(TO_CHAR(MOD((LAST_CALL_ET - (FLOOR(LAST_CALL_ET/(3600))*3600)),60),900))), 10, ' ') " IDLE TIME",
    MACHINE,
    TERMINAL,
    SCHEMANAME,
    sql_id
FROM  GV$SESSION
WHERE UPPER(USERNAME)           LIKE UPPER('%&VAR_USER%')
AND   UPPER(NVL(OSUSER, '%'))   LIKE UPPER('%&VAR_OS%')
AND   UPPER(NVL(PROGRAM, '%'))  LIKE UPPER('%&VAR_PRGM%')
AND   UPPER(NVL(MACHINE, '%'))  LIKE UPPER('%&VAR_MCH%')
AND   SID like '%&VAR_SID%'
ORDER BY STATUS DESC, SYSDATE-LOGON_TIME, PROGRAM DESC;

select
    s.inst_id,
    count(1) qtd,
    s.status
from
    gv$session s,
    gv$process p
where
    s.username is not null
    and nvl(p.pname,'XYZABC') not like 'O%'
    and s.paddr = p.addr 
    and s.inst_id = p.inst_id
group by
    s.inst_id,
    s.status
order by 1;

CLEAR COL
UNDEF VAR_USER VAR_OS VAR_PRGM VAR_MCH VAR_SID
SET WRAP ON