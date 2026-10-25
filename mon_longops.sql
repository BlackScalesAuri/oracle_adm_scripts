/*
    Progresso e previsao de termino de uma operacao longa pelo v$session_longops
    Uso: @mon_longops <parte da message> <total em GB> '<inicio DD/MM/YY HH24:MI:SS>'
*/
WITH progresso AS (
    SELECT
        SUM(sofar)*8/1024/1024 AS gb_feitos
    FROM
        v$session_longops
    WHERE
        message LIKE '%&&1%'
)
SELECT
    gb_feitos AS "GB Copiados",
    &&2 AS "Total GB",
    ROUND(gb_feitos/&&2*100, 2) AS "% Concluido",
    ROUND((&&2 - gb_feitos) / (gb_feitos / ((SYSDATE - TO_DATE('&&3', 'DD/MM/YY HH24:MI:SS')) * 24 * 60)), 2) AS "Min Restantes",
    TO_CHAR(SYSDATE + ((&&2 - gb_feitos) / (gb_feitos /
          ((SYSDATE - TO_DATE('&&3', 'DD/MM/YY HH24:MI:SS'))*24))/24), 'DD/MM/YYYY HH24:MI:SS') AS "Previsao Termino"
FROM
    progresso;

undef 1 2 3
