#!/bin/bash

read -p "Email: " v_email
read -sp "Senha: " v_pass
echo
read -p "Nome do arquivo de saida: " v_output
read -p "Link: " v_link

# Credenciais vao num arquivo temporario (mktemp cria com permissao 600) em vez da linha de
# comando, para nao aparecerem no ps; o arquivo e removido ao fim do download
v_cfg=$(mktemp)
v_user="${v_email}:${v_pass}"
v_user=${v_user//'\'/'\\'}
v_user=${v_user//'"'/'\"'}
printf 'user = "%s"\n' "$v_user" > "$v_cfg"

nohup bash -c 'curl -K "$1" -o "$2" "$3"; rm -f "$1"' _ "$v_cfg" "$v_output" "$v_link" > "download_${v_output}.out" 2>&1 &

tail -f "download_${v_output}.out"
