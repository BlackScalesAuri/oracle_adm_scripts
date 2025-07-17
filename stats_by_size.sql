/*
    Consulta e gera um script GATHER_STATS_BY_SIZE.sql ordenado por menor tamanho para serem coletados primeiro
    Nao considera owners/schemas de catalogo
*/

@set
SET LONG 10000
SET LINESIZE 7000
SET PAGESIZE 100000
SET TRIMSPOOL ON
COLUMN gather_stats_cmd FORMAT A700

spo GATHER_STATS_BY_SIZE.sql

WITH excluded_owners AS (
  SELECT 'SYS' FROM DUAL UNION ALL
  SELECT 'SYSTEM' FROM DUAL UNION ALL
  SELECT 'XDB' FROM DUAL UNION ALL
  SELECT 'SYSMAN' FROM DUAL UNION ALL
  SELECT 'WMSYS' FROM DUAL UNION ALL
  SELECT 'CTXSYS' FROM DUAL UNION ALL
  SELECT 'ORDDATA' FROM DUAL UNION ALL
  SELECT 'ORDSYS' FROM DUAL UNION ALL
  SELECT 'OLAPSYS' FROM DUAL UNION ALL
  SELECT 'DBSNMP' FROM DUAL UNION ALL
  SELECT 'APEX_%' FROM DUAL UNION ALL
  SELECT 'MDSYS' FROM DUAL UNION ALL
),
tabelas AS (
  SELECT owner, table_name
  FROM dba_tables
  WHERE owner NOT IN (SELECT * FROM excluded_owners)
),
table_data AS (
  SELECT owner, segment_name AS table_name, SUM(bytes)/1024/1024 AS size_mb
  FROM dba_segments
  WHERE segment_type = 'TABLE'
  GROUP BY owner, segment_name
),
lob_data AS (
  SELECT l.owner, l.table_name, SUM(s.bytes)/1024/1024 AS size_mb
  FROM dba_lobs l
  JOIN dba_segments s
    ON l.segment_name = s.segment_name AND l.owner = s.owner
  GROUP BY l.owner, l.table_name
),
index_data AS (
  SELECT i.table_owner AS owner, i.table_name, SUM(s.bytes)/1024/1024 AS size_mb
  FROM dba_indexes i
  JOIN dba_segments s
    ON i.owner = s.owner AND i.index_name = s.segment_name
  GROUP BY i.table_owner, i.table_name
)
SELECT
  'EXEC DBMS_STATS.GATHER_TABLE_STATS(' ||
  'ownname => ''' || t.owner || ''', ' ||
  'tabname => ''' || t.table_name || ''', ' ||
  'estimate_percent => 80, ' ||
  'block_sample => FALSE, ' ||
  'method_opt => ''for all columns size auto'', ' ||
  'degree => NULL, ' ||
  'granularity => ''ALL'', ' ||
  'cascade => TRUE, ' ||
  'stattab => NULL, ' ||
  'statid => NULL, ' ||
  'no_invalidate => TRUE);'
  AS gather_stats_cmd
FROM
  tabelas t
  LEFT JOIN table_data td ON t.owner = td.owner AND t.table_name = td.table_name
  LEFT JOIN lob_data ld    ON t.owner = ld.owner AND t.table_name = ld.table_name
  LEFT JOIN index_data id  ON t.owner = id.owner AND t.table_name = id.table_name
ORDER BY
  ROUND(NVL(td.size_mb, 0) + NVL(ld.size_mb, 0) + NVL(id.size_mb, 0), 2) ASC, t.owner, t.table_name;

prompt execute:
prompt 
prompt @GATHER_STATS_BY_SIZE.sql