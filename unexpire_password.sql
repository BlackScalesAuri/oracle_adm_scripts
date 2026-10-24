@set
col PROFILE for a40
col RESOURCE_NAME for a40 
col LIMIT for a50

select profile, RESOURCE_NAME, limit from dba_profiles where RESOURCE_NAME in('PASSWORD_LIFE_TIME', 'PASSWORD_REUSE_TIME');

PROMPT
PROMPT "EXECUTE OS COMANDOS ABAIXO PARA ALTERAR A PROFILE, DESBLOQUEAR E VALIDAR OS LOGINS: "
PROMPT

PROMPT alter profile DEFAULT limit PASSWORD_REUSE_TIME unlimited;;
PROMPT alter profile DEFAULT limit PASSWORD_LIFE_TIME  unlimited;;
PROMPT alter profile DEFAULT limit PASSWORD_REUSE_MAX unlimited;;

select 'ALTER USER ' || username || ' ACCOUNT UNLOCK;' cmd from dba_users where ACCOUNT_STATUS like '%LOCK%';

-- 11g+: hash novo (S:/T:) fica em spare4; o hash 10g (password) pode nao existir no 12c+
select 'ALTER USER ' || name || ' IDENTIFIED BY VALUES ''' || ltrim(rtrim(spare4 || ';' || trim(PASSWORD), ';'), ';') || ''';' cmd
    from user$ where name in (select username from dba_users where ACCOUNT_STATUS like '%EXPIRED%')
    and (spare4 is not null or trim(PASSWORD) is not null);