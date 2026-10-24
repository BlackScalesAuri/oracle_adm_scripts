
@?/rdbms/admin/spdrop

create tablespace PERFSTAT datafile  size 300M autoextend on next 8M maxsize 16G;
define default_tablespace='perfstat'
define temporary_tablespace='temp'
@?/rdbms/admin/spcreate


exec dbms_scheduler.create_program(program_name => 'SP_SNAP_PROG', program_type => 'STORED_PROCEDURE', program_action => 'PERFSTAT.statspack.snap', number_of_arguments => 0, enabled => FALSE);
exec dbms_scheduler.enable(name => 'SP_SNAP_PROG');
exec dbms_scheduler.create_schedule (schedule_name => 'SP_SNAP_SCHED', repeat_interval => 'freq=hourly; byminute=0; bysecond=0',end_date => null, comments => 'Schedule for Statspack snaps');
exec dbms_scheduler.create_job (job_name => 'SP_SNAP_JOB', program_name => 'SP_SNAP_PROG', schedule_name => 'SP_SNAP_SCHED',  enabled => TRUE, auto_drop => FALSE, comments => 'Statspack Job for snaps');

Exec dbms_scheduler.stop_job('SP_PURGE_JOB');
Exec dbms_scheduler.drop_job('STATSPACK_SNAPSHOT');
Exec dbms_scheduler.drop_schedule('SP_PURGE_SCHED');
Exec dbms_scheduler.drop_program('SP_PURGE_PROG');

create or replace procedure extended_purge(
num_days IN number
)
is
BEGIN
  statspack.purge(i_num_days => num_days, i_extended_purge => TRUE);
END extended_purge;
/

-- Test this procedure if needed
-- exec extended_purge(30);


-- Create snapshot job using scheduler - every Sunday at 0:20AM - keep 30 days of snapshots
exec dbms_scheduler.create_program(program_name => 'SP_PURGE_PROG', program_type => 'STORED_PROCEDURE', program_action => 'PERFSTAT.extended_purge', number_of_arguments => 1, enabled => FALSE);
exec DBMS_SCHEDULER.define_program_argument (program_name => 'SP_PURGE_PROG', argument_name => 'i_num_days', argument_position => 1, argument_type => 'NUMBER', default_value => 30);
exec dbms_scheduler.enable(name => 'SP_PURGE_PROG');
exec dbms_scheduler.create_schedule (schedule_name => 'SP_PURGE_SCHED', repeat_interval =>  'freq=weekly; byday=SUN; byhour=0; byminute=20',end_date => null, comments => 'Schedule for Statspack purge');
exec dbms_scheduler.create_job (job_name => 'SP_PURGE_JOB', program_name => 'SP_PURGE_PROG', schedule_name => 'SP_PURGE_SCHED',  enabled => TRUE, auto_drop => FALSE, comments => 'Statspack Job for purge');
