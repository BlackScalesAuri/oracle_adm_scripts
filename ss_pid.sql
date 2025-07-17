/*
Traz o PID ou o SID por SID ou PID
*/
@set

SELECT ss.sid,
       ss.serial#,
       ps.spid as "OS PID",
       ss.username,
       ss.module,
       ss.osuser
FROM v$session ss, v$process ps
WHERE ss.paddr = ps.addr
  AND (ps.spid = '&&1' OR  ss.sid = '&1')
ORDER BY ps.spid;

undef 1