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

-- tabela, LOBs e indices somados em CTEs separadas: juntar tudo num join so multiplica as linhas
-- (ex.: 2 LOBs x 3 indices contaria a tabela 6 vezes)
WITH segmentos AS (
    SELECT
        owner,
        segment_name,
        SUM(bytes)/1024/1024 AS size_mb
    FROM dba_segments
    WHERE segment_type IN ('TABLE','TABLE PARTITION','TABLE SUBPARTITION',
                           'INDEX','INDEX PARTITION','INDEX SUBPARTITION',
                           'LOBSEGMENT','LOB PARTITION','LOB SUBPARTITION')
    GROUP BY owner, segment_name
),
lobs AS (
    SELECT l.owner, l.table_name, SUM(s.size_mb) AS size_mb
    FROM dba_lobs l
    JOIN segmentos s
      ON s.owner = l.owner
     AND s.segment_name = l.segment_name
    GROUP BY l.owner, l.table_name
),
indices AS (
    SELECT i.table_owner AS owner, i.table_name, SUM(s.size_mb) AS size_mb
    FROM dba_indexes i
    JOIN segmentos s
      ON s.owner = i.owner
     AND s.segment_name = i.index_name
    GROUP BY i.table_owner, i.table_name
),
consolidado AS (
    SELECT
        t.owner,
        t.table_name,
        NVL(s_tab.size_mb,0) AS total_table_mb,
        NVL(s_lob.size_mb,0) AS total_lob_mb,
        NVL(s_idx.size_mb,0) AS total_idx_mb
    FROM dba_tables t
    LEFT JOIN segmentos s_tab
           ON s_tab.owner = t.owner
          AND s_tab.segment_name = t.table_name
    LEFT JOIN lobs s_lob
           ON s_lob.owner = t.owner
          AND s_lob.table_name = t.table_name
    LEFT JOIN indices s_idx
           ON s_idx.owner = t.owner
          AND s_idx.table_name = t.table_name
    WHERE t.owner NOT IN (
        'SYS','SYSTEM','XDB','SYSMAN','WMSYS','CTXSYS','ORDDATA',
        'ORDSYS','OLAPSYS','DBSNMP','MDSYS'
    )
)
SELECT
    'EXEC DBMS_STATS.GATHER_TABLE_STATS(' ||
    'ownname=>''' || owner || ''',' ||
    'tabname=>''' || table_name || ''',' ||
    'estimate_percent=>100,' ||
    'block_sample=>FALSE,' ||
    'method_opt=>''FOR ALL COLUMNS SIZE AUTO'',' ||
    'degree=>NULL,' ||
    'granularity=>''ALL'',' ||
    'cascade=>TRUE,' ||
    'stattab=>NULL,' ||
    'statid=>NULL,' ||
    'no_invalidate=>TRUE);' AS gather_stats_cmd
FROM consolidado
ORDER BY
      total_table_mb
    + total_lob_mb
    + total_idx_mb,
    owner,
    table_name;



spo off

prompt execute:
prompt 
prompt set echo on
prompt set feed on
prompt set serverout on
prompt set time on
prompt set timing on
prompt @GATHER_STATS_BY_SIZE.sql