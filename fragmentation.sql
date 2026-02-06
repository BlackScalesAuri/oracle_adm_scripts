col table_name for a40
col avg_row_len for 99999
col TOTAL_SIZE for a20
col ACTUAL_SIZE for a20
col FRAGMENTED_SPACE for a40
col owner for a25

select
    owner, table_name,avg_row_len,round(((blocks*8/1024)),2)||'MB' "TOTAL_SIZE",
    round((num_rows*avg_row_len/1024/1024),2)||'Mb' "ACTUAL_SIZE",
    round(((blocks*8/1024)-(num_rows*avg_row_len/1024/1024)),2) ||'MB' "FRAGMENTED_SPACE",
    (round(((blocks*8/1024)-(num_rows*avg_row_len/1024/1024)),2)/round(((blocks*8/1024)),2))*100 "percentage"
from dba_tables
where owner not like '%SYS%' and blocks > (1024*8) order by 7;