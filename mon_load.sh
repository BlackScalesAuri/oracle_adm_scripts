#!/usr/bin/env bash
# Monitora load médio de $LOCALHOST + N hosts via SSH
# Cores: verde (OK), vermelho (acima do limite), amarelo (erro)
# Última linha sem quebra de linha

THRESHOLD=$1
shift

if [ -z "$THRESHOLD" ]; then
  echo "Uso: $0 <LOAD_MAXIMO> [HOST1] [HOST2] ..."
  exit 1
fi

trap 'echo; echo Monitor interrompido.; exit 0' INT

LOCALHOST=$(hostname)
HOSTS=("$LOCALHOST" "$@")
TOTAL=${#HOSTS[@]}

while true; do
  clear

  for i in "${!HOSTS[@]}"; do
    HOST=${HOSTS[$i]}
    IS_LAST=$(( i == TOTAL - 1 ))

    if [ "$HOST" = "$LOCALHOST" ]; then
      LOAD=$(awk '{print $1}' /proc/loadavg)
    else
      LOAD=$(ssh -o ConnectTimeout=3 "$HOST" "awk '{print \$1}' /proc/loadavg" 2>/dev/null)
    fi

    if [ -z "$LOAD" ]; then
      LINE="\e[33m$HOST: indisponível\e[0m"
    elif (( $(echo "$LOAD > $THRESHOLD" | bc -l) )); then
      LINE="\e[31m$HOST: $LOAD\e[0m"
    else
      LINE="\e[32m$HOST: $LOAD\e[0m"
    fi

    if [ "$IS_LAST" -eq 1 ]; then
      echo -n -e "$LINE"
    else
      echo -e "$LINE"
    fi
  done

  sleep 1
done
