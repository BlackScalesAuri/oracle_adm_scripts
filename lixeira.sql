/*
	Lista lixeira e limpa se confirmado
*/
prompt == OBJETOS NA LIXEIRA =================================================================

select rownum, OWNER, OBJECT_NAME, ORIGINAL_NAME, TYPE, DROPTIME, SPACE from dba_recyclebin;

ACCEPT VAR_LIMPA PROMPT 'DESEJA LIMPAR A LIXEIRA? (S/SIM) : '

-- necessario privilégio DROP ANY TABLE para executar o purge em outro usuario;
DECLARE
w_sql varchar2(500);
cursor c_obj1h is
	select owner, object_name, original_name from dba_recyclebin
	where type = 'TABLE' and can_purge = 'YES';

begin
	IF(Upper('&VAR_LIMPA') = 'SIM' OR Upper('&VAR_LIMPA') = 'S')THEN
		for r_obj1h in c_obj1h
		loop
		w_sql := '';
		w_sql := 'PURGE TABLE '||chr(34)||r_obj1h.owner||chr(34)||'.'||chr(34)||r_obj1h.object_name||chr(34);
		dbms_output.put_line(W_SQL);
		execute immediate w_sql;
		end loop;
	END IF;
end;
/

UNDEF VAR_LIMPA