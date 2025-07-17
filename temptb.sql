/*
Traz info. da tbs temp
*/
set heading off
set feedback off
select sysdate from dual;

set heading on
set feedback on

-- SELECT * FROM DBA_TEMP_FILES;
-- ALTER TABLESPACE TEMP ADD TEMPFILE '/u02/oradata/dbprod/temp03.dbf' SIZE 2048M REUSE;
-- ALTER DATABASE TEMPFILE '/u02/oradata/dbprod/temp03.dbf' RESIZE 4096M;

select 
	a.tablespace_name tablespace,
	d.TEMP_TOTAL_MB / 1024 "TOTAL GB",
	round((sum(a.used_blocks * d.block_size) / 1024 / 1024) / 1024, 2)  "USADO GB",
	round((d.TEMP_TOTAL_MB - sum (a.used_blocks * d.block_size) / 1024 / 1024) / 1024, 2) "GB LIVRE"
from 
	v$sort_segment a,
	(
		select
	  		b.name,
			c.block_size,
			sum (c.bytes) / 1024 / 1024 TEMP_TOTAL_MB
		from
			v$tablespace b,
			v$tempfile c
		where
			b.ts#= c.ts#
		group by
			b.name,
			c.block_size
	) d
where
	a.tablespace_name = d.name
group by
	a.tablespace_name,
	d.TEMP_TOTAL_MB;