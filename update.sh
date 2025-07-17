#!/usr/bin/env bash
set -euo pipefail

# 1) Defina onde esta o repo
TARGET_DIR="${HOME}/scripts_vitor"

# 2) Verifica se o diretorio existe
if [ ! -d "$TARGET_DIR" ]; then
  echo "Erro: diretorio $TARGET_DIR nao encontrado."
  exit 1
fi

cd "$TARGET_DIR"

echo "=== Iniciando atualizacao em $TARGET_DIR ==="

# 3) Baixa e extrai direto por curl ou wget, sobrescrevendo o conteudo
if   command -v curl >/dev/null 2>&1; then
  echo "Usando curl para atualizar..."
  curl -sL https://codeload.github.com/VgHy/oracle_adm_scripts/tar.gz/master \
    | tar xz --strip-components=1
elif command -v wget >/dev/null 2>&1; then
  echo "Usando wget para atualizar..."
  wget -qO- https://codeload.github.com/VgHy/oracle_adm_scripts/tar.gz/master \
    | tar xz --strip-components=1
else
  echo "Erro: nem curl nem wget disponivel."
  exit 1
fi

echo "Atualizacao aplicada com sucesso em $(date '+%Y-%m-%d %H:%M:%S')"
