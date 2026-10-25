#!/bin/sh

### Para Acompanhar a coleta.
# cat mon_032023.csv | column -t -s $'\t' | less
# watch -n 120 "cat mon_032023.csv | column -t -s $'\t' | tail -n $(($LINES - 2))"

### Linhas crontab
# * * * * * sh /home/oracle/scripts/Hypercare/monitora.sh

# Variaveis
export vDtTime=$(date +"%d-%m-%Y %T")
export date=$(date +"%m%Y")
export pbyinstance=()
export sbyinstance=()
export tbyinstance=()

# Instancias a monitorar
export instances=( "orcl1" "orcl2" )

# Diretorio os scripts
export mon_dir=/home/oracle/coleta_19c/
export mon_file_log=$mon_dir/mon_$date.csv
export mon_file_detailed=$mon_dir/mon_sql_$date
export mon_file_hypercare=$mon_dir/mon_hypercare_$date

# Env Oracle
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1
export PATH=$ORACLE_HOME/bin:$HOME/bin:$PATH:/bin:/usr/bin:/usr/sbin:/sbin
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib
export CLASSPATH=$ORACLE_HOME/jre:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib

function get_active_sessions (){
if [ ! $(pidof "ora_pmon_$1" ) ]; then
    echo "BD $1 desligado"
else
export ORACLE_SID=$1
sativas=$($ORACLE_HOME/bin/sqlplus -S / as sysdba << EOF
    set pagesize 100 linesize 400 pause off verify off head off feedback 6
    select count(1)
        from gv\$session s, gv\$process p
        where s.username is not null
        and s.paddr = p.addr
        and s.status = 'ACTIVE'
        and s.inst_id = p.inst_id
        and nvl(p.pname,'XYZABC') not like 'O%';
    exit
EOF
)
echo $sativas
fi
}

function get_total_sessions (){
if [ ! $(pidof "ora_pmon_$1" ) ]; then
    echo "BD $1 desligado"
else
export ORACLE_SID=$1
sativas=$($ORACLE_HOME/bin/sqlplus -S / as sysdba << EOF
    set pagesize 100 linesize 400 pause off verify off head off feedback 6
    select count(1) from gv\$session;
    exit
EOF
)
echo $sativas
fi
}


if ! [ -e $mon_file_log ]; then
  echo -n -e HORA COLETA'\t'LOAD 1'\t'LOAD 5'\t'LOAD 15'\t'CPU%'\t'IOWait'\t'Memoria%'\t'Proc Oracle'\t'Proc Ativo'\t'Proc Inativos >> $mon_file_log
  for inst in ${instances[@]}; do
    echo -n -e '\t'Proc. ${inst}'\t'Sess. ativas ${inst}'\t'Sess. totais ${inst} >> $mon_file_log
  done
  # Quebra de linha
  echo >> $mon_file_log 
fi

# Faz a coleta dos loads 1, 5, 15 e 
# dos processos ativos e inativos.
vLoad1=$(cut -d' ' -f1 < /proc/loadavg)
vLoad5=$(cut -d' ' -f2 < /proc/loadavg)
vLoad15=$(cut -d' ' -f3 < /proc/loadavg)
vPtot=$(cut -d' ' -f4 < /proc/loadavg)
vPativo=${vPtot%/*}
vPinatv=${vPtot#*/}

# %CPU, IOWait e Memoria
vCpuPct=$(top -bn1|grep "Cpu(s)"|sed "s/.*, *\([0-9.]*\)%* id.*/\1/"|awk '{print 100 - $1"%"}')
vIOWait=$(top -bn2| awk -F"," '/Cpu/{if(p==0){p=1}else{split($5,a,"%");print a[1]}}')
vMem=$(free | grep Mem | awk '{print $3/$2 * 100.0}')

# Faz leitura dos processos rodando num arquivo auxiliar
ps axHr > $mon_dir/prunning.log

# Faz a contagem de processo de background e por instancia
vPora=$(grep -c "ora_" $mon_dir/prunning.log)
for i in ${!instances[@]}; do
  pbyinstance[$i]=$(grep -c "oracle${instances[i]}" $mon_dir/prunning.log)
done

# Apaga o arquivo auxiliar
rm $mon_dir/prunning.log

for i in ${!instances[@]}; do
  sbyinstance[$i]=$(get_active_sessions "${instances[i]}")
  tbyinstance[$i]=$(get_total_sessions "${instances[i]}")
done;

echo -n -e $vDtTime'\t'$vLoad1'\t'$vLoad5'\t'$vLoad15'\t'$vCpuPct'\t'$vIOWait'\t'$vMem'\t'$vPora'\t'$vPativo'\t'$vPinatv>> $mon_file_log
for i in ${!instances[@]}; do
  echo -n -e '\t'${pbyinstance[i]}'\t'${sbyinstance[i]}'\t'${tbyinstance[i]} >> $mon_file_log
done

# Quebra de linha
echo >> $mon_file_log 

# Loga informações das sessões ativas.
for i in ${!instances[@]}; do
  export ORACLE_SID=${instances[i]}
  $ORACLE_HOME/bin/sqlplus -S / as sysdba @$mon_dir/ss_mon.sql >> $mon_file_detailed.$ORACLE_SID
done;

echo "\`\`\`---------- " $vDtTime " ----------" >> $mon_file_hypercare.log
echo "Load1  : $vLoad1"  >> $mon_file_hypercare.log
echo "CPU%   : $vCpuPct" >> $mon_file_hypercare.log
echo "IOWait : $vIOWait" >> $mon_file_hypercare.log
echo "MEM%   : $vMem"    >> $mon_file_hypercare.log
echo "-------------------------------------------\`\`\`" >> $mon_file_hypercare.log

