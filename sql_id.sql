/*
Traz SQL_TEXT e informacoes de execucao de um SQL_ID
*/
@set
set long 999999999

select s.EXECUTIONS EXEC, s.INST_ID INST, PLSQL_EXEC_TIME PLSQL_TIME, s.SQL_FULLTEXT, PLAN_HASH_VALUE from gv$sqlarea s
where sql_id='&&1';

col av for 9999999
col mx for 9999999
col mn for 9999999

select
   sql_id,
   count(*),
   round(min(delta),0) mn,
   round(avg(delta),0) av,
   round(max(delta),0) mx,
   substr(max(times),12) max_run_time
from (
   select
        sql_id,
        sql_exec_id,
        max(delta) delta ,
        lpad(round(max(delta),0),10) || ' ' ||
        to_char(min(start_time),'YY-MM-DD HH24:MI:SS')  || ' ' ||
        to_char(max(end_time),'YY-MM-DD HH24:MI:SS')  times
   from ( select
                                            sql_id,
                                            sql_exec_id,
              cast(sample_time as date)     end_time,
              cast(sql_exec_start as date)  start_time,
              ((cast(sample_time    as date)) -
               (cast(sql_exec_start as date))) * (3600*24) delta
           from
              dba_hist_active_sess_history
           where sql_exec_id is not null
           and sql_id='&1'
        )
   group by sql_id,sql_exec_id
)
group by sql_id
having count(*) > 10
order by mx
/



undef 1