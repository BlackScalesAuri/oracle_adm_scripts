/*
    Checa uso das tablespaces
*/
set pages 900 lines 900

COLUMN DUMMY NOPRINT
COLUMN "PCT_USED" FORMAT 999.99            HEADING "%|Used"
COLUMN "NAME"     FORMAT A16               HEADING "Tablespace Name"
COLUMN "BYTES"    FORMAT 9,999,999,999,999 HEADING "Total Mbytes"
COLUMN "USED"     FORMAT 9,999,999,999,999 HEADING "Used MB"
COLUMN "FREE"     FORMAT 9,999,999,999,999 HEADING "Free MB"

SET FEEDBACK OFF
SET TERMOUT OFF

COLUMN 1 NEW_VALUE 1
SELECT '' "1" FROM DUAL WHERE ROWNUM = 0;
SELECT decode('&1', '', '', '&1') "1" FROM DUAL;

SET FEEDBACK ON
SET TERMOUT ON

SELECT
    a.tablespace_name,
    a.bytes Bytes,
    (a.bytes - b.bytes) Used,
    b.bytes Free,
    ROUND(((a.bytes-b.bytes)/a.bytes)*100,2) Pct_used
FROM (SELECT tablespace_name, SUM(bytes/1024/1024) BYTES
        FROM dba_data_files GROUP BY tablespace_name) a,
     (SELECT tablespace_name, SUM(bytes/1024/1024) BYTES
        FROM dba_free_space GROUP BY tablespace_name) b
WHERE a.tablespace_name=b.tablespace_name
    AND a.tablespace_name like '%&1%'
ORDER BY ROUND(((a.bytes-b.bytes)/a.bytes)*100,2) DESC;

CLEAR COL
UNDEF 1