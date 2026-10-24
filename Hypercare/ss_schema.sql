set pages 900 lines 900
select Status, Schema, Qtd, to_char(Hora,'cc dd/mm/yyyy hh24:mi:ss') data
from teikobkp.MON_SESS_19C order by 4;

create table TEIKOBKP.MON_SESS_19C 
   (Status varchar(15),
    Schema varchar(50),
    Qtd number(10),
    Hora date);

export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1
export PATH=$ORACLE_HOME/bin:$HOME/bin:$PATH:/bin:/usr/bin:/usr/sbin:/sbin
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib
export CLASSPATH=$ORACLE_HOME/jre:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib

export ORACLE_SID=producao2

sqlplus / as sysdba << EOF 
INSERT INTO TEIKOBKP.MON_SESS_19C (Status, Schema, Qtd, Hora)
  SELECT 'INATIVA', username, count(1), sysdate
   from gv\$session where STATUS='INACTIVE' group by username;
commit;
INSERT INTO TEIKOBKP.MON_SESS_19C (Status, Schema, Qtd, Hora)
  SELECT 'ATIVA', username, count(1), sysdate
   from gv\$session where STATUS='ACTIVE' group by username;
commit;
EOF
