/*
  Script para monitoramento de longops e recursos da maquina
*/

prompt == Uptime ======================================================================
!uptime

prompt == Longops =====================================================================

col USERNAME for a6
COLUMN message FORMAT A150 TRUNC
col DONE_TOTAL for A24
col ELAPSED for a14
col TIME_LEFT for a15
col USERNAME for a10
col OPNAME for a35
col TARGET for a35

set pages 900 lines 900

SELECT
  LPAD(ROUND(S.SOFAR / S.TOTALWORK * 100, 2), 6) || ' %' AS PCT_DONE,
  V.USERNAME,
  S.OPNAME,
  TO_CHAR(S.START_TIME, 'DD-MON HH24:MI:SS') AS STARTED_AT,
  ROUND(S.ELAPSED_SECONDS/60, 1) || ' min' AS ELAPSED,
  ROUND(S.TIME_REMAINING/60, 1) || ' min' AS TIME_LEFT,
  S.SOFAR || '/' || S.TOTALWORK AS DONE_TOTAL,
  S.MESSAGE
FROM
  V$SESSION_LONGOPS S
JOIN
  V$SESSION V ON S.SID = V.SID AND S.SERIAL# = V.SERIAL#
WHERE
  S.TOTALWORK > 0
  AND S.SOFAR < S.TOTALWORK
  AND V.STATUS = 'ACTIVE'
ORDER BY
  S.START_TIME DESC;

prompt == ASM Usage ===================================================================

SET LINESIZE 200
COL NAME FORMAT A15
COL TOTAL_GB FORMAT 999,999
COL FREE_GB FORMAT 999,999
COL USED_PCT FORMAT 999.99

SELECT
  NAME,
  ROUND(TOTAL_MB / 1024, 2) AS TOTAL_GB,
  ROUND(FREE_MB / 1024, 2) AS FREE_GB,
  ROUND((TOTAL_MB - FREE_MB) / TOTAL_MB * 100, 2) AS USED_PCT
FROM
  V$ASM_DISKGROUP
ORDER BY
  NAME;

prompt == Sess. Active ================================================================

@ss_active

quit
