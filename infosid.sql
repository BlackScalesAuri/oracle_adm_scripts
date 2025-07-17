/*
Traz informacoes da sessao por SID e Instancia.
*/
@set
SET VERIFY OFF

COL "COMMAND" FORMAT A120

SET FEEDBACK OFF
SET TERMOUT OFF

COLUMN 2 NEW_VALUE 2
SELECT '' "2" FROM DUAL WHERE ROWNUM = 0;
SELECT decode('&2', '', INSTANCE_NUMBER, '&2') "2" FROM v$instance;

SET FEEDBACK ON
SET TERMOUT ON

SELECT UNIQUE
    'Kill        : ALTER SYSTEM KILL SESSION ''' || gs.SID || ','|| gs.SERIAL# || ',@' || gs.INST_ID || ''' IMMEDIATE ;' || chr(10) ||
    'Disconnect  : ALTER SYSTEM DISCONNECT SESSION ''' || gs.SID ||','|| gs.SERIAL# || ''' IMMEDIATE;'                   || chr(10) ||
    'Trace ON    : EXEC SYS.DBMS_SYSTEM.SET_SQL_TRACE_IN_SESSION ('|| gs.SID ||', '|| gs.SERIAL# ||', TRUE)'             || chr(10) ||
    'Trace OFF   : EXEC SYS.DBMS_SYSTEM.SET_SQL_TRACE_IN_SESSION ('|| gs.SID ||', '|| gs.SERIAL# ||', FALSE)'            || chr(10) ||
    'Explain     : select * from table(dbms_xplan.display_cursor('''||SQL_HASH_VALUE||''',null,''ADVANCED''));'          || chr(10) ||
    'SID,SERIAL# : '''|| gs.SID || ',' || gs.SERIAL# || ',@' || gs.INST_ID || ''' | Process ID Unix: ' || SPID     || chr(10) ||
    'Machine     : '|| gs.machine    || chr(10) ||
    'Terminal    : '|| gs.terminal   || chr(10) ||
    'User S.O    : '|| OSUSER                || chr(10) ||
    'User Oracle : '|| gs.USERNAME   || chr(10) ||
    'Status      : '|| STATUS                || chr(10) ||
    'Schema      : '|| SCHEMANAME            || chr(10) ||
    'Program     : '|| gs.PROGRAM    || chr(10) ||
    'Conectado   : '|| gs.logon_time || chr(10) ||
    'Tempo Conn  : '|| lpad(floor(((sysdate-logon_time)*86400)/(3600)) ||':'|| lpad(floor((((sysdate-logon_time)*86400) - (floor(((sysdate-logon_time)*86400)/(3600))*3600))/60), 2, '0') ||':'||lpad(mod((((sysdate-logon_time)*86400) - (floor(((sysdate-logon_time)*86400)/(3600))*3600)),60), 2, '0'), 10, ' ')  || chr(10) ||
    'Last Call   : '|| lpad(trim(to_char(floor(last_call_et/(3600)),9000)||':'||trim(to_char(floor((last_call_et - (floor(last_call_et/(3600))*3600))/60),900))||':'||trim(to_char(mod((last_call_et - (floor(last_call_et/(3600))*3600)),60),900))), 10, ' ') COMMAND
FROM  GV$SESSION gs, GV$PROCESS
WHERE ADDR = PADDR
AND   gs.SID = &1 AND
      gs.INST_ID = &2;

CLEAR COL
UNDEF 1 2