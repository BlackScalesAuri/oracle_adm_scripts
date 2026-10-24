SELECT 'Buffer hit ratio:' "Param",
    ROUND((1-(sum(decode(name,'physical reads',value,0))/
        (sum(decode(name,'db block gets',value,0))+
        (sum(decode(name,'consistent gets',value,0)))))
    )* 100,2) "Valor",
    ' >= 90 ' "Esperado"
FROM v$SYSSTAT
UNION ALL
SELECT
    'Dictionary Hit Ratio:' "Param",
    ROUND((1-(sum(getmisses)/sum(gets)))*100,2) "Valor",
    ' >= 95 ' "Esperado"
FROM gv$rowcache
UNION ALL
SELECT 
    'Hard Parse Ratio:' "Param",
    ROUND((b.value/a.value)*100,2) "Valor",
    ' < 1.6 ' "Esperado"
FROM v$sysstat a, v$sysstat b
WHERE a.name = 'parse count (total)'
AND b.name = 'parse count (hard)'
UNION ALL
SELECT
    'Latch Hit Ratio: ' "Param",
    ROUND((SELECT SUM(gets) - SUM(misses) FROM V$LATCH) / 
        (SELECT SUM(gets) FROM V$LATCH)*100, 2) "Valor",
    ' >= 90 ' "Esperado"    
FROM DUAL
UNION ALL
SELECT 
    'Library Hit Ratio: ' "Param",
    ROUND(Sum(pins) / (Sum(Pins) + sum(Reloads))*100, 2) "Valor",
    ' >= 90 ' "Esperado"    
FROM V$LibraryCache
UNION ALL
select 
    'PGA Hit Ratio: ' "Param",
    round(value,2) "PGA Hit Ratio",
    ' >= 90 ' "Esperado"    
from sys.v_$pgastat
where name = 'cache hit percentage'
UNION ALL
select 
    'Redolog Wait Ratio: ' "Param",
    ROUND(100*(
        (SELECT value FROM v$sysstat WHERE name='redo entries')-
        (SELECT value FROM v$sysstat WHERE name='redo log space requests'))/
        (SELECT value FROM v$sysstat WHERE name='redo entries'),2) "Valor",
    ' >= 90 ' "Esperado"    
from dual
UNION ALL
select 
    'Shared Pool Used: (todo)' "Param",
    0 "Param",
    ' < 99 ' "Esperado"    
from dual
UNION ALL
SELECT 'Sorts in Mem Ratio: ' "Param",
    ROUND((SELECT SUM(value) FROM V$SYSSTAT WHERE name = 'sorts (memory)') / 
        (SELECT SUM(value) FROM V$SYSSTAT     WHERE name IN ('sorts (memory)', 'sorts (disk)')) * 100, 2) "Valor",
        ' >= 98 ' "Esperado"
FROM DUAL
UNION ALL
select 
    'Work area executions multipass (TODO)' "Param",
    0 "Param",
    ' < 99 ' "Esperado"    
from dual;