/*
Lista sessões por tempo de CPU
*/
@set

SELECT ss.sid,
    ss.serial#,
    ps.spid as "OS PID",
    ss.username,
    ss.module,
    st.value/100 as "CPU sec"
FROM v$sesstat st,
    v$statname sn,
    v$session ss,
    v$process ps
WHERE sn.name = 'CPU used by this session' 
    AND st.statistic# = sn.statistic# 
    AND st.sid = ss.sid AND ss.paddr = ps.addr AND ss.last_call_et < 1800
    AND ss.logon_time > (SYSDATE-(240/1440)) ORDER BY st.value desc;