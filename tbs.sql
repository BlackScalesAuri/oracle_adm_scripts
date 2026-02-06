rem #################################################################################################
rem # Autor      : Renato Freitas (renato@questinfo.com.br)
rem # Script     : vtbs.sql
rem # Finalidade : Lista os detalhes dos tablespaces do banco de dados
rem # Criacao    : 01/11/2004
rem #################################################################################################
rem

set echo off
set feedback off verify off pagesize 100 linesize 130     
clear breaks
clear computes
col database_name noprint new_value db_name
col TODAY noprint NEW_VALUE _DATE
set termout off
select to_char(SYSDATE,'fmMonth DD, YYYY HH24:MI:SS') TODAY from DUAL;
set termout on
TTITLE OFF
select name database_name from v$database;
TTITLE left _DATE CENTER "Tablespaces usados pelo Banco de Dados " db_name Skip 1 -
CENTER "-----------------------------------------------" skip 2
col tablespace_name format a20 heading 'Nome|Tablespace'
col initial_extent_size format 9,999,999 heading 'Initial|Extent|em (KB)'
col next_extent_size format 9,999,999 heading 'Next|Extent|em (KB)'
col min_extents format 99 heading 'Min|Extent'
col max_extents heading 'Max|Extent'
col status format a8 heading 'Status'
col contents format a9 heading 'Tipo'
col avail format 9,999,990.90 heading 'Tamanho|Total|(em MB)'
col free format 9,999,990.90 heading 'Total|Livre|(em MB)'
col percent_used format a10 heading 'Usado|(%)'
col used format 9,999,990.90 heading 'Total|Usado|(em MB)'
col extent_management format a10 heading 'Tipo|(Extent|Mgmnt)'
SELECT 
	dts.tablespace_name,
	initial_extent/1024 initial_extent_size,
	next_extent/1024 next_extent_size,
	NVL(ddf.bytes / 1024 / 1024, 0) avail,
	NVL(ddf.bytes - NVL(dfs.bytes, 0), 0)/1024/1024 used,
	NVL(dfs.bytes / 1024 / 1024, 0) free,
	TO_CHAR(NVL((ddf.bytes - NVL(dfs.bytes, 0)) / ddf.bytes * 100, 0), '990.00') percent_used, 
	dts.contents,
	dts.extent_management, 
	dts.status
FROM 
	sys.dba_tablespaces dts, 
	(select tablespace_name, sum(bytes) bytes 
		from dba_data_files group by tablespace_name) ddf, 
			(select tablespace_name, sum(bytes) bytes 
				from dba_free_space group by tablespace_name) dfs 
				WHERE 
					dts.tablespace_name = ddf.tablespace_name(+) 
				AND dts.tablespace_name = dfs.tablespace_name(+) 
				AND NOT (dts.extent_management like 'LOCAL' 
				AND dts.contents like 'TEMPORARY') 
				UNION ALL 
				SELECT dts.tablespace_name,
					initial_extent/1024 initial_extent_size,
					next_extent/1024 next_extent_size,
					NVL(dtf.bytes / 1024 / 1024, 0) avail,
					NVL(t.bytes, 0)/1024/1024 used, 
					NVL(dtf.bytes - NVL(t.bytes, 0), 0)/1024/1024 free,
					TO_CHAR(NVL(t.bytes / dtf.bytes * 100, 0), '990.00') "Usado (%)", 
					dts.contents,
					dts.extent_management, 
					dts.status
				FROM 
					sys.dba_tablespaces dts, 
					(select tablespace_name, sum(bytes) bytes 
					from dba_temp_files group by tablespace_name) dtf, 
						(select tablespace_name, sum(bytes_used) bytes 
						from v$temp_space_header group by tablespace_name) t 
	WHERE 
	dts.tablespace_name = dtf.tablespace_name(+) 
	AND dts.tablespace_name = t.tablespace_name(+) 
	AND dts.extent_management like 'LOCAL' 
	AND dts.contents like 'TEMPORARY'
	ORDER BY percent_used;
TTITLE OFF
set feedback on
set verify on
clear breaks
clear computes
clear columns
set linesize 100
set pagesize 24
set echo off