/*
Checa sessoes ativas no banco
*/

set pagesize 100 linesize 400 pause off verify off

col username       format a12
col inst_id        format 9999999
col os_pid         format 9999999
col sessao         format a15
col machine        format a8
col programa       format a15 truncate
col machine_osuser format a20 truncate heading "MACHINE: OSUSER"
col log_time       format a10 heading 'HORARIO|DO LOGIN' justify right
col inicio_ult_cmd format a14 heading 'TEMPO ATIVO|OU INATIVO' justify right
col module         format a15 truncate
col event          format a25 truncate
col SERVICE_NAME   format a20 truncate heading 'SERVICE|NAME' justify left
col sec_wait       format 999999

select s.username,
       s.inst_id,
       --s.con_id, 
       to_number(p.spid) as os_pid,
       p.pname, 
       '''' || to_char(s.sid) || ',' || to_char(s.serial#) || '''' as sessao,
       s.machine || ': ' || s.osuser as machine_osuser,
       SUBSTR(SUBSTR(s.program,INSTR(s.program,'\',-1)+1),1,30) as programa,
       decode( trunc(sysdate-s.logon_time),            -- dias conectado
               0, to_char(s.logon_time,'hh24:mi:ss'),  -- se menos de um dia
                  to_char(trunc(sysdate-s.logon_time, 1), 'fm99.0') || ' dias'
             ) as log_time,
       decode( trunc(last_call_et/86400),  -- 86400 seg = 1 dia
               0, '     ',                 -- se 0 dias, coloca brancos
                  to_char(trunc(last_call_et/60/60/24), '0') || 'd, ')
       || to_char( to_date(mod(last_call_et, 86400), 'SSSSS'),
                              'hh24"h"MI"m"SS"s"'
                 ) as inicio_ult_cmd, 
       SUBSTR(SUBSTR(s.module,INSTR(s.module,'\',-1)+1),1,30)   as module,
	   CASE WHEN s.state = 'WAITING' THEN 
	             s.event 
		    ELSE 'ON CPU' END event,
	   s.seconds_in_wait sec_wait,
      SUBSTR(s.service_name, 1, 20),
	   s.sql_id
from gv$session s, gv$process p
where s.username is not null
and s.paddr = p.addr
and s.status = 'ACTIVE'
and s.inst_id = p.inst_id
and nvl(p.pname,'XYZABC') not like 'O%'
order by inicio_ult_cmd, status, s.username;

set feedback 6