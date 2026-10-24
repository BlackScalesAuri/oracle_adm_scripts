#!/usr/bin/env bash
set -euo pipefail

# 1) Defina onde esta o repo
TARGET_DIR="${HOME}/scripts_vitor"
TARGET_DIAG="${HOME}/oradiag_oracle"
REPO_URL="https://codeload.github.com/BlackScalesAuri/oracle_adm_scripts/tar.gz/master"

# Pergunta [s/N]; aceita s/S/y/Y. Sem terminal (ex.: cron) responde N.
ask() {
  local resp
  read -r -p "$1 [s/N] " resp < /dev/tty || return 1
  case "$resp" in
    s|S|y|Y) return 0 ;;
    *)       return 1 ;;
  esac
}

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
  curl -sL "$REPO_URL" | tar xz --strip-components=1
elif command -v wget >/dev/null 2>&1; then
  echo "Usando wget para atualizar..."
  wget -qO- "$REPO_URL" | tar xz --strip-components=1
else
  echo "Erro: nem curl nem wget disponivel."
  exit 1
fi

echo "Atualizacao feita com sucesso em $(date '+%Y-%m-%d %H:%M:%S')"

# 4) Revalida os links de alert log (apos upgrade/migracao podem apontar para log antigo),
#    reaproveitando a logica do install.sh recem baixado
if [ -d "$TARGET_DIAG" ] && ask "Revalidar links de alert logs em $TARGET_DIAG?"; then
  bash "$TARGET_DIR/install.sh" --alert-links
fi
