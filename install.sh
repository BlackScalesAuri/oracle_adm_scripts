#!/usr/bin/env bash
set -euo pipefail

echo
echo "=== Iniciando instalacao do oracle_adm_scripts por Vitor Christovao ==="
echo

TARGET_DIR="$HOME/scripts_vitor"
TARGET_DIAG="${HOME}/oradiag_oracle"
BASH_PROFILE="${HOME}/.bash_profile"

# 1) Criar pasta de scripts
read -p "1) Criar pasta de scripts em '$HOME/scripts_vitor'? [y/N] " resp
if [ "$resp" = "y" ] || [ "$resp" = "Y" ]; then
  echo "-> Criando pasta $TARGET_DIR..."
  mkdir -p "$TARGET_DIR"
  cd "$TARGET_DIR"
  echo "   Pasta criada e acessada."
else
  echo "   Pulando criacao de pasta de scripts."
fi

# 2) Baixar e extrair o repo
read -p "2) Baixar e extrair oracle_adm_scripts no destino atual? [y/N] " resp
if [ "$resp" = "y" ] || [ "$resp" = "Y" ]; then
  echo "-> Iniciando download do repositorio..."
  if command -v curl >/dev/null; then
    curl -sL https://codeload.github.com/BlackScalesAuri/oracle_adm_scripts/tar.gz/master | tar xz --strip-components=1
  elif command -v wget >/dev/null; then
    wget -qO- https://codeload.github.com/BlackScalesAuri/oracle_adm_scripts/tar.gz/master | tar xz --strip-components=1
  else
    echo "Erro: nem curl nem wget encontrados. Abortando."
    exit 1
  fi
  echo "   Download e extracao concluidos."
else
  echo "   Pulando download do repositorio."
fi
echo

read -p "3) Criar $TARGET_DIAG e links para alert_*.log? [y/N] " resp
if [ "$resp" = "y" ] || [ "$resp" = "Y" ]; then
  echo "-> Criando pasta $TARGET_DIAG..."
  mkdir -p "$TARGET_DIAG"

  echo "-> Varredura para alert logs..."
  find /u01 /u02 /u03 /u04 /orabin /orabin01 /orabin02 /oracle -type f -name 'alert_*.log' 2>/dev/null | while read -r log; do

      name=$(basename "$log")
      dest="$TARGET_DIAG/$name"

      if [ -e "$dest" ]; then
        echo "   [OK] já existe: $name"
      else
        echo "   Arquivo encontrado: $log"
        # força o read a ler do terminal, não do pipe
        read -p "   Criar este link simbólico? [y/N] " aws < /dev/tty
        if [ "$aws" = "y" ] || [ "$aws" = "Y" ]; then
          ln -s "$log" "$dest" && echo "   [+] criado link: $name"
        else
          echo "   [-] pulando: $name"
        fi
      fi

  done

  echo "-> Processo concluído. Links em $TARGET_DIAG."
else
  echo "-> Pulando criação de links de alert logs."
fi



# 4) Atualizar .bash_profile com SQLPATH
read -p "4) Adicionar '$TARGET_DIR' como SQLPATH em ~/.bash_profile? [y/N] !! NAO FAZER EM ODA/EXADATA !!" resp
if [ "$resp" = "y" ] || [ "$resp" = "Y" ]; then
  echo "-> Atualizando $BASH_PROFILE..."
  if grep -q 'SQLPATH' "$BASH_PROFILE" 2>/dev/null; then
    echo "   Erro: SQLPATH ja configurado em $BASH_PROFILE."
    exit 1
  else
    {
      echo
      echo "# configurado pelo install.sh em $(date +'%Y-%m-%d %H:%M:%S')"
      echo "export SQLPATH=${TARGET_DIR}"
    } >> "$BASH_PROFILE"
    echo "   SQLPATH adicionado com sucesso."
  fi
else
    echo "   Pulando criacao de pasta de scripts."
fi