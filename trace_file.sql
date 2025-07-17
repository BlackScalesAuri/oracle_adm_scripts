/*
Traz arquivo de trace de uma sessao
*/

col "USERNAME" format a30

--EXEC DBMS_MONITOR.session_trace_enable(session_id=>1234, serial_num=>1234);

ACCEPT VAR_SID PROMPT 'SID ORACLE: '

SELECT s.username "USERNAME",
	   s.sid "SID",
       s.serial# "SERIAL#",
       pa.value || '/' || LOWER(SYS_CONTEXT('userenv','instance_name')) ||   
       '_ora_' || p.spid || '.trc' AS "trace_file"
FROM   v$session s,
       v$process p,
       v$parameter pa
WHERE  pa.name = 'user_dump_dest'
AND    s.paddr = p.addr
and S.sid = &VAR_SID;

CLEAR COL
UNDEF VAR_SID