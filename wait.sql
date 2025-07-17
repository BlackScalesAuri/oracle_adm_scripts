/*
Traz informacoes de sessoes em wait
*/
COL "USER"   FORMAT A18
COL "SID"    FORMAT 99999
COL "OS PID" FORMAT A8
COL "EVENTO" FORMAT A75
COL "TEMPO EM WAIT" FORMAT A20
COL "START SESSION" FORMAT A17
COL "MATAR A SESSÃO" FORMAT A200

ACCEPT VAR_USER PROMPT "INFORME O USER : "

SELECT 
    b.username  "USER",
    a.sid       "SID",
    c.spid      "OS PID",
    TO_CHAR(TRUNC(a.seconds_in_wait/3600),'FM9900') || 'h:' || TO_CHAR(TRUNC(MOD(a.seconds_in_wait,3600)/60),'FM00') || 'm:' ||  TO_CHAR(MOD(a.seconds_in_wait,60),'FM00') || 's' "TEMPO EM WAIT",
    b.status    "STATUS",
    TO_CHAR(b.logon_time, 'DD/MM/YYYY HH:MM') "START SESSION",
    b.program    "PROGRAMA",
    a.wait_time,
    b.sql_id,
    a.event      "EVENTO",
    CASE
        WHEN (TRUNC((&_O_RELEASE/100000000)) >= 12) THEN
            'ALTER SYSTEM KILL SESSION ' || CHR(39) || a.sid  ||','||b.SERIAL# ||', @'||b.INST_ID|| CHR(39) || ' IMMEDIATE ;'
        ELSE
            'ALTER SYSTEM DISCONNECT SESSION ' || CHR(39) || a.sid  ||','||b.SERIAL# || CHR(39) || ' IMMEDIATE ;'
    END "MATAR A SESSÃO"
FROM
    gv$session_wait a,
    gv$session b,
    gv$process c
WHERE a.event not in ('SQL*Net message from client','SQL*Net message to client')
    AND a.sid = b.sid
    AND decode(nvl(c.background, 0), 0, ' ', 'B') <> 'B'
    AND c.addr = b.paddr (+)
    AND c.spid IS NOT NULL
    AND b.username LIKE Upper('%&VAR_USER%')
ORDER BY a.seconds_in_wait DESC;

CLEAR COL
UNDEF VAR_USER