/*
        Lista sessões em lock
*/
@set
prompt === Sessoes em lock ==========================================================================================================================================

COL "INST: BLOCKER"  FOR A15
COL "INST: BLOCKED"  FOR A15
COL SID              FOR A9     HEADING 'SID'
COL "SERIAL#"        FOR 999999 HEADING 'SERIAL#'
COL INST_ID          FOR 9999   HEADING 'INST|ID'
COL USERNAME         FOR A15    HEADING 'USERNAME'
COL OBJECT_NAME      FOR A25    HEADING 'OBJECT_NAME'
COL SQL_ID           FOR A13    HEADING 'SQL_ID'
COL INST_LOCK        FOR A6     HEADING 'INST|LOCK'
COL SID_LOCK         FOR A6     HEADING 'SID|LOCK'
COL LOCK_CTIME       FOR A6     HEADING 'LOCK|CTIME'
COL INST_WAIT        FOR A6     HEADING 'INST|WAIT'
COL SID_WAIT         FOR A6     HEADING 'SID|WAIT'
COL WAIT_CTIME       FOR A6     HEADING 'WAIT|CTIME'
COL WAITER_LOCK_TYPE FOR A22  
COL WAITER_MODE_REQ  FOR A19
 
SELECT 
        INST_LOCK||'   : '||SID_LOCK as  "Inst: Blocker",
        INST_WAIT||'   : '||SID_WAIT  as "Inst: Blocked",
        LOCK_CTIME_HOUR,
        WAIT_CTIME_HOUR,
        WAITER_LOCK_TYPE,
        WAITER_MODE_REQ
from
(
SELECT LH.INST_ID INST_LOCK, LH.SID SID_LOCK, ROUND(LH.CTIME/60/60,2) LOCK_CTIME_HOUR,
       LW.INST_ID INST_WAIT, LW.SID SID_WAIT, ROUND(LW.CTIME/60/60,2) WAIT_CTIME_HOUR,
       DECODE (lh.TYPE,
               'MR', 'Media_recovery',
               'RT', 'Redo_thread',
               'UN', 'User_name',
               'TX', 'Transaction',
               'TM', 'Dml',
               'UL', 'PLSQL User_lock',
               'DX', 'Distrted_Transaxion',
               'CF', 'Control_file',
               'IS', 'Instance_state',
               'FS', 'File_set',
               'IR', 'Instance_recovery',
               'ST', 'Diskspace Transaction',
               'IV', 'Libcache_invalidation',
               'LS', 'LogStaartORswitch',
               'RW', 'Row_wait',
               'SQ', 'Sequence_no',
               'TE', 'Extend_table',
               'TT', 'Temp_table',
               'Nothing-'
              ) waiter_lock_type,
       DECODE (lw.request,
               0, 'None',
               1, 'NoLock',
               2, 'Row-Share',
               3, 'Row-Exclusive',
               4, 'Share-Table',
               5, 'Share-Row-Exclusive',
               6, 'Exclusive',
               'Nothing-'
              ) WAITER_MODE_REQ
FROM   GV$LOCK LW, GV$LOCK LH
WHERE  LH.ID1 = LW.ID1
AND    LH.ID2 = LW.ID2
AND    LH.REQUEST = 0
AND    LW.LMODE = 0
AND    (LH.ID1, LH.ID2) IN (
                           SELECT ID1, ID2
                           FROM   GV$LOCK
                           WHERE  REQUEST = 0
                           INTERSECT
                           SELECT ID1, ID2
                           FROM   GV$LOCK
                           WHERE  LMODE = 0)
)  T1
,  GV$SESSION T2
,  GV$SESSION T3
WHERE  (T1.INST_LOCK = T2.INST_ID AND T1.SID_LOCK = T2.SID)
AND    (T1.INST_WAIT = T3.INST_ID AND T1.SID_WAIT = T3.SID)
ORDER BY LOCK_CTIME_HOUR DESC,SID_LOCK;

prompt === LOCKTREE =================================================================================================================================================
/* 
        Baseado no script locktree.sql de Guy Harrison
*/

WITH 
SESSIONS AS
   (SELECT DISTINCT 
           INST_ID, SID, SERIAL#, USERNAME, BLOCKING_SESSION, ROW_WAIT_OBJ#, SQL_ID
      FROM GV$SESSION),
LOCKS AS
(
    SELECT DISTINCT LH.INST_ID INST_LOCK, LH.SID SID_LOCK, LH.CTIME LOCK_CTIME,
           LW.INST_ID INST_WAIT, LW.SID SID_WAIT, LW.CTIME WAIT_CTIME,
           DECODE (LH.TYPE,
                   'MR', 'Media_recovery',
                   'RT', 'Redo_thread',
                   'UN', 'User_name',
                   'TX', 'Transaction',
                   'TM', 'Dml',
                   'UL', 'PLSQL User_lock',
                   'DX', 'Distrted_Transaxion',
                   'CF', 'Control_file',
                   'IS', 'Instance_state',
                   'FS', 'File_set',
                   'IR', 'Instance_recovery',
                   'ST', 'Diskspace Transaction',
                   'IV', 'Libcache_invalidation',
                   'LS', 'LogStaartORswitch',
                   'RW', 'Row_wait',
                   'SQ', 'Sequence_no',
                   'TE', 'Extend_table',
                   'TT', 'Temp_table',
                   'Nothing-'
                  ) WAITER_LOCK_TYPE,
           DECODE (LW.REQUEST,
                   0, 'None',
                   1, 'NoLock',
                   2, 'Row-Share',
                   3, 'Row-Exclusive',
                   4, 'Share-Table',
                   5, 'Share-Row-Exclusive',
                   6, 'Exclusive',
                   'Nothing-'
                  ) WAITER_MODE_REQ
    FROM   GV$LOCK LW, GV$LOCK LH
    WHERE  LH.ID1 = LW.ID1
    AND    LH.ID2 = LW.ID2
    AND    LH.REQUEST = 0
    AND    LW.LMODE = 0
    AND    (LH.ID1, LH.ID2) IN (
                               SELECT ID1, ID2
                               FROM   GV$LOCK
                               WHERE  REQUEST = 0
                               INTERSECT
                               SELECT ID1, ID2
                               FROM   GV$LOCK
                               WHERE  LMODE = 0)
    )
SELECT 
       DISTINCT LPAD(' ', 3*(LEVEL-1))||SID SID,
       SERIAL#,
       INST_ID,
       USERNAME,
       OBJECT_NAME, 
       SQL_ID,
       INST_LOCK,
       SID_LOCK,
       LOCK_CTIME,
       INST_WAIT,
       SID_WAIT,
       WAIT_CTIME,
       WAITER_LOCK_TYPE,
       WAITER_MODE_REQ
FROM
(
    SELECT DISTINCT SID,
           SERIAL#,
           INST_ID,
           USERNAME,
           OBJECT_NAME, 
           SQL_ID,
           BLOCKING_SESSION,
           DECODE(BLOCKING_SESSION, NULL, NULL, L.INST_LOCK) INST_LOCK,
           DECODE(BLOCKING_SESSION, NULL, NULL, L.SID_LOCK) SID_LOCK,
           DECODE(BLOCKING_SESSION, NULL, NULL, L.LOCK_CTIME) LOCK_CTIME,
           DECODE(BLOCKING_SESSION, NULL, NULL, L.INST_WAIT) INST_WAIT,
           DECODE(BLOCKING_SESSION, NULL, NULL, L.SID_WAIT) SID_WAIT,
           DECODE(BLOCKING_SESSION, NULL, NULL, L.WAIT_CTIME) WAIT_CTIME,
           DECODE(BLOCKING_SESSION, NULL, NULL, L.WAITER_LOCK_TYPE) WAITER_LOCK_TYPE,
           DECODE(BLOCKING_SESSION, NULL, NULL, L.WAITER_MODE_REQ) WAITER_MODE_REQ
      FROM SESSIONS S
      JOIN LOCKS L ON (L.INST_LOCK = S.INST_ID AND L.SID_LOCK = S.SID) OR (L.INST_WAIT = S.INST_ID AND L.SID_WAIT = S.SID)
      LEFT OUTER JOIN DBA_OBJECTS 
           ON (OBJECT_ID = ROW_WAIT_OBJ#)
     WHERE SID IN (SELECT BLOCKING_SESSION FROM SESSIONS)
        OR BLOCKING_SESSION IS NOT NULL
)
CONNECT BY PRIOR SID = BLOCKING_SESSION
START WITH BLOCKING_SESSION IS NULL
ORDER SIBLINGS BY LOCK_CTIME, WAIT_CTIME;
