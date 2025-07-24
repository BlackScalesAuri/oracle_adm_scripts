#!/usr/bin/env bash
# Monitora load medio 1min de dois hosts via SSH
# Limpa tela e imprime host:load em verde se load <= threshold, em vermelho se load > threshold

THRESHOLD=$1
HOST1=$2
HOST2=$3

if [ -z "$THRESHOLD" ] || [ -z "$HOST1" ] || [ -z "$HOST2" ]; then
  echo "Uso: $0 <LOAD_MAXIMO> <HOST1> <HOST2>"
  exit 1
fi

trap 'echo; echo Monitor interrompido.; exit 0' INT

while true; do
  LOAD1=$(ssh "$HOST1" "awk '{print \$1}' /proc/loadavg")
  LOAD2=$(ssh "$HOST2" "awk '{print \$1}' /proc/loadavg")

  clear
  
  # Host1
  if (( $(echo "$LOAD1 > $THRESHOLD" | bc -l) )); then
    echo -e "\e[31m$HOST1: $LOAD1\e[0m"
  else
    echo -e "\e[32m$HOST1: $LOAD1\e[0m"
  fi

  # Host2
  if (( $(echo "$LOAD2 > $THRESHOLD" | bc -l) )); then
    echo -n -e "\e[31m$HOST2: $LOAD2\e[0m"
  else
    echo -n -e "\e[32m$HOST2: $LOAD2\e[0m"
  fi

  sleep 1
done
