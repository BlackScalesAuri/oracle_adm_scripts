#!/bin/bash

read -p "Email [vitor.francisco@flowti.com.br]: " v_email
v_email=${v_email:-"vitor.francisco@flowti.com.br"}
read -sp "Senha: " v_pass
echo
read -p "Nome do arquivo de saida: " v_output
read -p "Link: " v_link

curl -u ${v_email}:${v_pass} -o ${v_output} "${v_link}" > download_${v_output}.out 2>&1 &

tail -f download_${v_output}.out
