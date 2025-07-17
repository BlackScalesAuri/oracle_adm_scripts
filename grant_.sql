/*
Consulta privilegios de um usuario
*/

set verify off

COL "PRIVILEGIO" format a15
COL "TABELA"     format a33
COL "CHAVE"      format a15
COL "OWNER"      format a17
COL "ROLE"       format a67

--Seleciona todos os grants de objeto.
PROMPT
PROMPT ==PERMISSOES DA TAB_PRIVS==============================================================
PROMPT
SELECT 
	GRANTEE    "CHAVE",
	PRIVILEGE  "PRIVILEGIO",
	OWNER      "OWNER",
	TABLE_NAME "TABELA",
	GRANTABLE  "ADM"
FROM
	DBA_TAB_PRIVS
WHERE
	GRANTEE = upper('&&1')
ORDER BY
	OWNER,
	TABELA;

COL "PRIVILEGIO" format a67
--seleciona todos os grants de sistema
PROMPT
PROMPT ==PERMISSOES DA SYS_PRIVS==============================================================
PROMPT
SELECT
	GRANTEE      "CHAVE",
	PRIVILEGE    "PRIVILEGIO",
	ADMIN_OPTION "ADM"
FROM
	DBA_SYS_PRIVS
WHERE 
	GRANTEE = upper('&1');

--seleciona todas os grants de roles
PROMPT
PROMPT ==PERMISSOES DA ROLE_PRIVS=============================================================
PROMPT
SELECT
	GRANTEE      "CHAVE",
	GRANTED_ROLE "ROLE",
	ADMIN_OPTION "ADM"
FROM
	DBA_ROLE_PRIVS
WHERE
	GRANTEE = upper('&1');

CLEAR COL
UNDEF 1