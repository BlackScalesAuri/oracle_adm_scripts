/*
Traz o consumo de UNDO por sessão
*/
@set

SELECT ss.sid,
       ss.serial#,
       ss.username,
       ss.module,
       ss.osuser,
       ss.logon_time,
       t.xidusn,
       t.ubafil,
       t.ubablk,
       t.used_ublk,
       t.start_time AS txn_start_time,
       t.status,
       ROUND (t.used_ublk * TO_NUMBER (x.VALUE) / 1024 / 1024, 2) || ' Mb'
          "Undo"
  FROM v$session ss, v$transaction t, v$parameter x
WHERE ss.saddr = t.ses_addr AND x.name = 'db_block_size';