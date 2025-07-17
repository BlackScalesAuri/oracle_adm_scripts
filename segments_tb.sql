/*
Tras o tamanho das tabela de uma determinada tablespace
*/
col segment_name for a45
col segment_type for a45
col tablespace_name for a45
col GB for 999.999.999.999,999

select
    segment_name, segment_type, tablespace_name, sum(bytes)/1024/1024/1024 "GB"
from dba_segments
where tablespace_name='&1'
group by tablespace_name, segment_type, segment_name
order by 4;

undef 1