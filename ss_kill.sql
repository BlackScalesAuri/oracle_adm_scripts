/*
Traz comando para killar as sessões
*/
@set

ACCEPT VAR_USER PROMPT 'USUARIO (ORACLE): '
ACCEPT VAR_OS PROMPT   'USUARIO (OS)    : '
ACCEPT VAR_PRGM PROMPT 'PROGRAMA        : '
ACCEPT VAR_SRV PROMPT  'SERVIDOR        : '
ACCEPT VAR_SID PROMPT  'SID             : '

SELECT 
    'ALTER SYSTEM KILL SESSION ' || CHR(39) || SID ||','||SERIAL# ||', @'||INST_ID|| CHR(39) || ' IMMEDIATE ;'
FROM  GV$SESSION
WHERE UPPER(USERNAME)           LIKE UPPER('%&VAR_USER%')
AND   UPPER(NVL(OSUSER, '%'))   LIKE UPPER('%&VAR_OS%')
AND   UPPER(NVL(PROGRAM, '%'))  LIKE UPPER('%&VAR_PRGM%')
AND   UPPER(NVL(MACHINE, '%'))  LIKE UPPER('%&VAR_SRV%')
AND   SID like '%&VAR_SID%'
ORDER BY INST_ID, SID;

select count(1) qtd, username, status from gv$session where username is not null group by username, status;

CLEAR COL
UNDEF VAR_USER VAR_OS VAR_PRGM VAR_SRV VAR_SID