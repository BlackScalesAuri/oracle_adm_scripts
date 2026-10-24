/*
Verifica porcentagem de completitude do rman (por canais, não total.)
*/
set pages 900 lines 900

select
  sid,
  to_char(start_time,'YYYY-MM-DD HH24:MI:SS'),
  start_time,
  totalwork,
  sofar,
  (sofar/totalwork) * 100 pct_done
from
   v$session_longops
where
   totalwork > sofar
AND
   opname NOT LIKE '%aggregate%'
AND
   opname like 'RMAN%';