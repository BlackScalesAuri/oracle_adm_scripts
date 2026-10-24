/*
Traz SQL_TEXT e informacoes de execucao de um SQL_ID
*/
@set
set long 9999999999999999
col SQL_FULLTEXT for a9999
select
   s.SQL_FULLTEXT from gv$sqlarea s
where sql_id='&&1';


undef 1