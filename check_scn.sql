ALTER SESSION SET NLS_DATE_FORMAT = 'DD/MM/YYYY HH24:MI:SS';
set pages 400
set lines 300
col tablespace_name for a20
col space_header for a12
col name for a90
col checkpoint_time for a22
select file#, status, tablespace_name, 
CREATION_TIME,to_char(checkpoint_change#,9999999999999999999999999999) SCN,checkpoint_time ,
name,bytes/1024/1024/1024 as "TAMANHO DATAFILE",space_header from v$datafile_header
order by 6;