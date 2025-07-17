@set
for PROFILE a40
for RESOURCE_NAME a40 
for LIMIT a50

select profile, RESOURCE_NAME, limit from dba_profiles where RESOURCE_NAME in('PASSWORD_LIFE_TIME', 'PASSWORD_REUSE_TIME');

PROMPT
PROMPT "EXECUTE OS COMANDOS ABAIXO PARA ALTERAR A PROFILE, DESBLOQUEAR E VALIDAR OS LOGINS: "
PROMPT

PROMPT alter profile DEFAULT limit PASSWORD_REUSE_TIME unlimited;;
PROMPT alter profile DEFAULT limit PASSWORD_LIFE_TIME  unlimited;;
PROMPT alter profile DEFAULT limit PASSWORD_REUSE_MAX unlimited;;

select 'ALTER USER ' || username || ' ACCOUNT UNLOCK;' cmd from dba_users where ACCOUNT_STATUS like '%LOCK%';

select 'ALTER USER ' || name || ' IDENTIFIED BY VALUES ' || trim(PASSWORD) || ';' cmd
    from user$ where name in (select username from dba_users where ACCOUNT_STATUS like '%EXPIRED%') and trim(PASSWORD) is not null;