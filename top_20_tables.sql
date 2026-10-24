col owner for a30
col table_name for a40

with segment_rollup as (
  select owner, table_name, owner segment_owner, table_name segment_name from dba_tables
    union all
  select table_owner, table_name, owner segment_owner, index_name segment_name from dba_indexes
    union all
  select owner, table_name, owner segment_owner, segment_name from dba_lobs
    union all
  select owner, table_name, owner segment_owner, index_name segment_name from dba_lobs
), ranked_tables as (
  select rank() over (order by sum(blocks) desc) rank, sum(blocks) blocks, r.owner, r.table_name
  from segment_rollup r, dba_segments s
  where s.owner=r.segment_owner and s.segment_name=r.segment_name
  group by r.owner, r.table_name
)
select rank, owner, table_name, round(blocks*8/1024/1024, 2) gb
from ranked_tables
where rank<=20;