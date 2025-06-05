WITH progresso AS (
    SELECT 
        SUM(sofar)*8/1024/1024 AS gb_feitos
    FROM 
        v$session_longops
    WHERE 
        message LIKE '%&1%'
)
SELECT 
    gb_feitos AS "GB Copiados",
    3008 AS "Total GB",
    ROUND(gb_feitos/3008*100, 2) AS "% Concluido",
    ROUND((3008 - gb_feitos) / (gb_feitos / ((SYSDATE - TO_DATE('30/05/25 21:43:47', 'DD/MM/YY HH24:MI:SS')) * 24 * 60)), 2) AS "Min Restantes",
    TO_CHAR(SYSDATE + ((3008 - gb_feitos) / (gb_feitos / 
          ((SYSDATE - TO_DATE('30/05/25 21:43:47', 'DD/MM/YY HH24:MI:SS'))*24))/24), 'DD/MM/YYYY HH24:MI:SS') AS "Previsao Termino"
FROM 
    progresso;