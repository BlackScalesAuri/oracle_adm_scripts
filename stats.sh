## SH para coleta de estatisticas em CDB/PDB, chamada stats.sh <SID> <PDB> <PORCENTAGEM_COLETA>

# valida se foram informados 3 parametros
if [ $# -ne 3 ]; then
    echo
    echo "Erro: faltam parametros."
    echo "Uso: $0 <SID> <PDB> <PORCENTAGEM_COLETA>"
    echo
    exit 1
fi

nohup sqlplus / as sysdba << EOF >> coleta_${1}.log &
set time on
set timing on
set feed on

PROMPT '-- CDB --> Coletando DICTIONARY_STATS'
exec DBMS_STATS.GATHER_DICTIONARY_STATS();

PROMPT '-- CDB --> Coletando SYSTEM_STATS'
exec DBMS_STATS.GATHER_SYSTEM_STATS();

PROMPT '-- CDB --> Coletando FIXED_OBJECTS_STATS'
exec DBMS_STATS.GATHER_FIXED_OBJECTS_STATS();

PROMPT '-- CDB --> Coletando DATABASE_STATS'
BEGIN
DBMS_STATS.GATHER_DATABASE_STATS(
    ESTIMATE_PERCENT => 100
    ,block_sample => FALSE
    ,method_opt => 'for all columns size AUTO'
    ,degree => 4
    ,granularity => 'ALL'
    ,cascade => TRUE
    ,stattab => null
    ,statid => null
    ,options => 'GATHER'
    ,statown => null
    ,gather_sys => TRUE
    ,NO_INVALIDATE => TRUE
    ,gather_temp => TRUE
    ,gather_fixed => FALSE
    ,stattype => 'ALL'
);
END;
/

alter session set container=${2};

PROMPT '-- PDB --> Coletando DICTIONARY_STATS'
exec DBMS_STATS.GATHER_DICTIONARY_STATS();

PROMPT '-- PDB --> Coletando SYSTEM_STATS'
exec DBMS_STATS.GATHER_SYSTEM_STATS();

PROMPT '-- PDB --> Coletando FIXED_OBJECTS_STATS'
exec DBMS_STATS.GATHER_FIXED_OBJECTS_STATS();

PROMPT '-- PDB --> Coletando DATABASE_STATS'
BEGIN
DBMS_STATS.GATHER_DATABASE_STATS(
    ESTIMATE_PERCENT => ${3}
    ,block_sample => FALSE
    ,method_opt => 'for all columns size AUTO'
    ,degree => 4
    ,granularity => 'ALL'
    ,cascade => TRUE
    ,stattab => null
    ,statid => null
    ,options => 'GATHER'
    ,statown => null
    ,gather_sys => TRUE
    ,NO_INVALIDATE => TRUE
    ,gather_temp => TRUE
    ,gather_fixed => FALSE
    ,stattype => 'ALL'
);
end;
/
PROMPT '---------> FIM DA COLETA'

exit
EOF
