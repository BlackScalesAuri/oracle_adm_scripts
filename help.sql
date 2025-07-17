SELECT
    COLUMN_VALUE
FROM
TABLE(SYS.DBMS_DEBUG_VC2COLL(
'chkasm2.sql           |    Checa uso de disco no ASM',
'datafile.sql          |    tras os comandos para aumentar o datafile',
'dropall.sql           |    Gera script para drop de todos os objetos de um owner',
'infopid.sql           |    Traz informacoes de sessao por PID',
'job_log.sql           |    Traz log de execução dos ultimos scheduled jobs',
'lock.sql              |    Traz sessoes e objetos em lock',
'mview.sql             |    Busca info. de view materializada e traz o comando para fazer o refresh manual',
'oi.sql                |    Script para validar objetos invalidos',
'rman_log.sql          |    Lista informação dos backups RMAN',
'set.sql               |    Seta formatacao das colunas',
'ss.sql                |    Lista Todas as sessões',
'ss_io.sql             |    Lista Sessões por I/O',
'ss_pid.sql            |    Traz o PID ou o SID por SID ou PID',
'temptb.sql            |    Traz info. da tbs temp',
'undotb.sql            |    Traz informacoes de undo',
'wait.sql              |    Traz informacoes de sessoes em wait',
'chktb.sql             |    Checa uso das tablespaces',
'db_link.sql           |    Traz informações de DB_LINK',
'grant_.sql            |    Consulta privilegios de um usuario',
'infosid.sql           |    Traz informacoes da sessao por SID',
'kill_dpjob.sql        |    Lista e mata sessão de datapump',
'maxshrink.sql         |    Mostra o tamanho que os datafiles podem ser diminuidos, pode se alterar a porcentagem do minimo espaço livre no script',
'obj.sql               |    Lista info. de objetos da instancia',
'reversa.sql           |    Traz a DDL de um objeto',
'scheduled_jobs.sql    |    Lista Scheduled Jobs',
'sql_id.sql            |    Traz SQL_TEXT e informacoes de execucao de um SQL_ID',
'ss_cpu.sql            |    Lista sessões por tempo de CPU',
'ss_mem.sql            |    Lista Sessões por UGA',
'ss_undo.sql           |    Traz o consumo de UNDO por sessão',
'trace_file.sql        |    Traz arquivo de trace de uma sessao',
'user_.sql             |    Traz informacoes de um usuario',
'segments_tb.sql       |    Tras o tamanho das tabela de uma determinada tablespace',
'job.sql               |    Lista info. de jobs cadastrados e Jobs/Scheduled jobs em execucao'
)) nome 
WHERE COLUMN_VALUE LIKE '%&1%'
ORDER BY 1;