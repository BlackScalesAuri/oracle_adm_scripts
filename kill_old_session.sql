spo /home/oracle/scripts/logs/kill_old_session.log append

set pages 900 lines 900 trimspo on head off serveroutput off feed off

select 'Encerrando sessão: sid - ' || sid || ' serial - ' || serial# || ' username - ' || username FROM v$session
      where username is not null
      and status ='INACTIVE'
      and username not in ('SYS', 'SYSMAN', 'DBSNMP')
      and last_call_et > 12400;
declare
cursor C1 is
select sid,serial# FROM v$session
      where username is not null
      and status ='INACTIVE'
      and username not in ('SYS', 'SYSMAN', 'DBSNMP')
      and last_call_et > 12400;
begin
for reg_C1 in C1 loop
   execute immediate 'alter system kill session'''||reg_C1.sid||','||reg_C1.serial#||'''immediate';
end loop;
end;
/
