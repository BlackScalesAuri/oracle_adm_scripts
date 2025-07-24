
SET LINES 220 PAGES 100 TRIMSPOOL ON wrap on
ALTER SESSION SET nls_date_format='YYYY-MM-DD HH24:MI:SS';

COLUMN session_id       FORMAT 999999
COLUMN inst_id          FORMAT 999
COLUMN resumable_status FORMAT A9
COLUMN session_status   FORMAT A8
COLUMN total_min        FORMAT 99990
COLUMN wait_min         FORMAT 99990
COLUMN error_number     FORMAT 999999
COLUMN error_parameter1 FORMAT A35
COLUMN program          FORMAT A22
COLUMN module           FORMAT A20
COLUMN machine          FORMAT A18
COLUMN username         FORMAT A15
COLUMN sql_text         FORMAT A75
COLUMN name             FORMAT A30

SELECT r.session_id,
       s.inst_id,
       r.status,
       SUBSTR(q.sql_text,1,75) AS sql_text,
       r.name,
       r.error_number,
       r.error_msg AS error_parameter1
FROM   dba_resumable r
JOIN   gv$session s ON s.sid = r.session_id
LEFT   JOIN gv$sql q ON q.sql_id = s.sql_id AND q.inst_id = s.inst_id
ORDER  BY status, r.start_time DESC;