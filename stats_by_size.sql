/*
    Consulta e gera um script GATHER_STATS_BY_SIZE.sql ordenado por menor tamanho para serem coletados primeiro
    Nao considera owners/schemas de catalogo
*/

@set
SET LONG 10000
SET LINESIZE 7000
SET PAGESIZE 50000
SET TRIMSPOOL ON
COLUMN gather_stats_cmd FORMAT A700

spo GATHER_STATS_BY_SIZE.sql

WITH excluded_owners AS (
  SELECT 'SYS' owner FROM dual UNION ALL
  SELECT 'SYSTEM' FROM dual UNION ALL
  SELECT 'XDB' FROM dual UNION ALL
  SELECT 'SYSMAN' FROM dual UNION ALL
  SELECT 'WMSYS' FROM dual UNION ALL
  SELECT 'CTXSYS' FROM dual UNION ALL
  SELECT 'ORDDATA' FROM dual UNION ALL
  SELECT 'ORDSYS' FROM dual UNION ALL
  SELECT 'OLAPSYS' FROM dual UNION ALL
  SELECT 'DBSNMP' FROM dual UNION ALL
  SELECT 'MDSYS' FROM dual
),
tabelas AS (
  SELECT owner, table_name
  FROM   dba_tables
  WHERE  owner NOT IN (SELECT owner FROM excluded_owners)
    AND  owner NOT LIKE 'APEX\_%' ESCAPE '\'
),
table_data AS (
  SELECT owner, segment_name AS table_name,
         SUM(bytes)/1024/1024 AS size_mb
  FROM   dba_segments
  WHERE  segment_type = 'TABLE'
  GROUP  BY owner, segment_name
),
lob_data AS (
  SELECT l.owner, l.table_name,
         SUM(s.bytes)/1024/1024 AS size_mb
  FROM   dba_lobs l
  JOIN   dba_segments s
    ON   l.segment_name = s.segment_name
   AND   l.owner = s.owner
  GROUP  BY l.owner, l.table_name
),
index_data AS (
  SELECT i.table_owner AS owner, i.table_name,
         SUM(s.bytes)/1024/1024 AS size_mb
  FROM   dba_indexes i
  JOIN   dba_segments s
    ON   i.owner = s.owner
   AND   i.index_name = s.segment_name
  GROUP  BY i.table_owner, i.table_name
)
SELECT
  'EXEC DBMS_STATS.GATHER_TABLE_STATS(' ||
  'ownname=>''' || t.owner || ''',' ||
  'tabname=>''' || t.table_name || ''',' ||
  'estimate_percent=>100,' ||
  'block_sample=>FALSE,' ||
  'method_opt=>''FOR ALL COLUMNS SIZE AUTO'',' ||
  'degree=>NULL,' ||
  'granularity=>''ALL'',' ||
  'cascade=>TRUE,' ||
  'stattab=>NULL,' ||
  'statid=>NULL,' ||
  'no_invalidate=>TRUE);' AS gather_stats_cmd
FROM   tabelas t
LEFT JOIN table_data td ON t.owner = td.owner AND t.table_name = td.table_name
LEFT JOIN lob_data   ld ON t.owner = ld.owner AND t.table_name = ld.table_name
LEFT JOIN index_data id ON t.owner = id.owner AND t.table_name = id.table_name
ORDER BY
  NVL(td.size_mb,0) + NVL(ld.size_mb,0) + NVL(id.size_mb,0) ASC, t.owner, t.table_name;

spo off

prompt execute:
prompt 
prompt set echo on
prompt set feed on
prompt set serverout on
prompt set time on
prompt set timing on
prompt @GATHER_STATS_BY_SIZE.sql