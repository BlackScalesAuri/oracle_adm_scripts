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

WITH segmentos AS (
    SELECT
        owner,
        segment_name,
        segment_type,
        SUM(bytes)/1024/1024 AS size_mb
    FROM dba_segments
    WHERE segment_type IN ('TABLE','INDEX','LOBSEGMENT','LOB PARTITION')
    GROUP BY owner, segment_name, segment_type
),
tabela_raw AS (
    SELECT
        t.owner,
        t.table_name,
        NVL(s_tab.size_mb,0) AS table_mb,
        NVL(s_lob.size_mb,0) AS lob_mb,
        NVL(s_idx.size_mb,0) AS idx_mb
    FROM dba_tables t
    LEFT JOIN segmentos s_tab
           ON s_tab.owner = t.owner
          AND s_tab.segment_name = t.table_name
          AND s_tab.segment_type = 'TABLE'
    LEFT JOIN dba_lobs l
           ON l.owner = t.owner
          AND l.table_name = t.table_name
    LEFT JOIN segmentos s_lob
           ON s_lob.owner = l.owner
          AND s_lob.segment_name = l.segment_name
          AND s_lob.segment_type IN ('LOBSEGMENT','LOB PARTITION')
    LEFT JOIN dba_indexes i
           ON i.table_owner = t.owner
          AND i.table_name  = t.table_name
    LEFT JOIN segmentos s_idx
           ON s_idx.owner = i.owner
          AND s_idx.segment_name = i.index_name
          AND s_idx.segment_type = 'INDEX'
    WHERE t.owner NOT IN (
        'SYS','SYSTEM','XDB','SYSMAN','WMSYS','CTXSYS','ORDDATA',
        'ORDSYS','OLAPSYS','DBSNMP','MDSYS'
    )
),
consolidado AS (
    SELECT
        owner,
        table_name,
        SUM(table_mb) AS total_table_mb,
        SUM(lob_mb)   AS total_lob_mb,
        SUM(idx_mb)   AS total_idx_mb,
        ROW_NUMBER() OVER (
            PARTITION BY owner, table_name
            ORDER BY 1
        ) AS rn
    FROM tabela_raw
    GROUP BY owner, table_name
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
WHERE rn = 1
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