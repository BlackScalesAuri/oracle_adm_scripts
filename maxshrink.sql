/*
 Filename      : maxshrink.sql
 Author        : Craig Richards - originally from Asktom.oracle.com
 Created       :
 Version       : 1.0

 Description   : Displays the size your datafiles can be shrunk to, it also generates the commands for you
 Examples      : @maxshrink
                 @maxshrink d3%
 */
SET VERIFY OFF

DEFINE PCT_THRES = 25 -- Minimum free space in percentage

COLUMN file_name FORMAT a100 word_wrapped
COLUMN smallest  FORMAT 999,990 HEADING "Smallest|Size|Poss."
COLUMN currsize  FORMAT 999,990 HEADING "Current|Size"
COLUMN savings   FORMAT 999,990 HEADING "Poss.|Savings"

BREAK ON report

COMPUTE sum of savings on report

COLUMN value new_val blksize noprint
COLUMN exec_dt new_val dt noprint

set feed off
SELECT value FROM v$parameter WHERE name = 'db_block_size'
/
SELECT to_char(sysdate, 'YYYYMMDDHH24MISS') exec_dt FROM dual
/
set feed on

-- Defines first parameter's default value
set feed off term off
col p1 new_value 1
select null p1 from dual where  1=2;
select nvl('&1','%') p1 from dual;
set feed on term on

prompt creating snapshot of dba_extents (it might take a few minutes)...

create table my_ext_&_USER._&dt
as  
SELECT file_id, max(block_id+blocks-1) hwm
   FROM dba_extents
WHERE lower(tablespace_name) like lower('&1')
group by file_id;

SELECT file_name,
       CASE WHEN CEIL( blocks*&&blksize/1024/1024 ) < (NVL(hwm,1)*&&blksize)/1024/1024 / (1-&PCT_THRES/100.0)
           THEN blocks*&&blksize/1024/1024
           ELSE (NVL(hwm,1)*&&blksize)/1024/1024 / (1-&PCT_THRES/100.0)
       END smallest,
       CEIL( blocks*&&blksize/1024/1024 ) currsize,
       CASE WHEN (blocks*&&blksize/1024/1024) < (NVL(hwm,1)*&&blksize)/1024/1024 / (1-&PCT_THRES/100.0)
           THEN 0
           ELSE CEIL( blocks*&&blksize/1024/1024) -
                CEIL( (NVL(hwm,1)*&&blksize)/1024/1024 / (1-&PCT_THRES/100.0) )
       END savings
FROM dba_data_files a,
     ( SELECT file_id, hwm
         FROM my_ext_&_USER._&dt ) b
WHERE a.file_id = b.file_id(+)
  AND lower(a.tablespace_name) like lower('&1')
ORDER BY savings desc
/

COLUMN cmd FORMAT a150 word_wrapped

SELECT 'alter database datafile '''||file_name||''' resize ' ||
       CEIL( (NVL(hwm,1)*&&blksize)/1024/1024 / (1-&PCT_THRES/100.0) )  || 'm;' cmd
FROM dba_data_files a,
     ( SELECT file_id, hwm
         FROM my_ext_&_USER._&dt ) b
WHERE a.file_id = b.file_id(+)
  AND CEIL( blocks*&&blksize/1024/1024) -
      CEIL( (NVL(hwm,1)*&&blksize)/1024/1024 / (1-&PCT_THRES/100.0) ) > 0
  AND lower(a.tablespace_name) like lower('&1')
ORDER BY file_name      
/

drop table my_ext_&_USER._&dt purge;

CLEAR COL
CLEAR COMPUTE

UNDEF 1 P1 PCT_THRES