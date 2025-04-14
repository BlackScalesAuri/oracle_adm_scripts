/*
Lista todos os indices de uma tabela
*/

Col OWNER for a40 
Col INDEX_NAME for a40 
Col INDEX_TYPE for a40 
Col TABLE_NAME for a40 
Col UNIQUENESS for a40


SELECT 
    idx.OWNER,
    idx.TABLE_NAME,
    idx.INDEX_NAME,
    col.COLUMN_NAME,
    idx.UNIQUENESS
FROM 
    DBA_INDEXES idx
JOIN 
    DBA_IND_COLUMNS col
ON 
    idx.INDEX_NAME = col.INDEX_NAME
WHERE 
    idx.TABLE_NAME LIKE UPPER('&1')
ORDER BY 
    col.COLUMN_POSITION;


UNDEF 1