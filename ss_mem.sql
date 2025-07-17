/*
Lista Sessões por UGA
*/
@set

select ss.sid,
    ss.serial#,
    ps.spid as "OS PID",
    ss.username,
    ss.module,
    ss.server,
    round(stat.value/1024/1024, 2) as "current_UGA_memory (in MB)"
from v$session  ss,
    v$sesstat  stat,
    v$statname name,
    v$process  ps
where ss.sid          = stat.sid
    and stat.statistic# = name.statistic#
    and name.name       = 'session uga memory'
    AND ss.paddr = ps.addr
    --and stat.value      >= 10485760   -- (All Session Usage > 10MB)
order by
    value;