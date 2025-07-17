/*
Lista Sessões por I/O
*/
@set

select ss.sid,
    ss.serial#,
    ps.spid as "OS PID",
    ss.username,
    ss.module,
    round(100 * total_user_io / total_io, 2) tot_io_pct
from (select b.sid sid,
             b.paddr,
             nvl(b.username, p.name) username,
             b.module,
             b.serial#,
             sum(value) total_user_io
      from sys.v_$statname  c,
             sys.v_$sesstat   a,
             sys.v_$session   b,
             sys.v_$bgprocess p
      where a.statistic# = c.statistic#
             and p.paddr(+) = b.paddr
             and b.sid = a.sid
             and c.name in ('physical reads',
                            'physical writes',
                            'physical writes direct',
                            'physical reads direct',
                            'physical writes direct (lob)',
                            'physical reads direct (lob)')
      group by b.sid, nvl(b.username, p.name), b.paddr, b.serial#, b.module) ss,
      (select sum(value) total_io
       from sys.v_$statname c, sys.v_$sesstat a
       where a.statistic# = c.statistic#
            and c.name in ('physical reads',
                           'physical writes',
                           'physical writes direct',
                           'physical reads direct',
                           'physical writes direct (lob)',
                           'physical reads direct (lob)')),
      v$process ps
  where ss.paddr = ps.addr 
 order by tot_io_pct ASC;