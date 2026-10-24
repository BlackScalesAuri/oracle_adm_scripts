#!/usr/bin/env bash
set -euo pipefail

echo
echo "=== Iniciando instalacao do oracle_adm_scripts por Vitor Christovao ==="
echo

TARGET_DIR="$HOME/scripts_vitor"
TARGET_DIAG="${HOME}/oradiag_oracle"
BASH_PROFILE="${HOME}/.bash_profile"
REPO_URL="https://codeload.github.com/BlackScalesAuri/oracle_adm_scripts/tar.gz/master"
ALERT_SEARCH_DIRS=(/u01 /u02 /u03 /u04 /orabin /orabin01 /orabin02 /oracle)

# Pergunta [s/N]; aceita s/S/y/Y. Le do terminal para funcionar tambem dentro de loops com pipe.
ask() {
  local resp
  read -r -p "$1 [s/N] " resp < /dev/tty || return 1
  case "$resp" in
    s|S|y|Y) return 0 ;;
    *)       return 1 ;;
  esac
}

# Lista "pid sid" das instancias ativas (pmon de banco e de ASM)
running_instances() {
  ps -eo pid=,args= | awk '$2 ~ /^(ora|asm)_pmon_/ { sub(/^(ora|asm)_pmon_/, "", $2); print $1, $2 }'
}

# ORACLE_HOME da instancia: pelo executavel do pmon; sem permissao no /proc (ex.: ASM do
# usuario grid), pelo /etc/oratab, tentando tambem o SID sem o numero da instancia RAC
instance_home() {
  local pid=$1 sid=$2 exe s h
  exe=$(readlink -f "/proc/$pid/exe" 2>/dev/null || true)
  case "$exe" in
    */bin/oracle) echo "${exe%/bin/oracle}"; return ;;
  esac
  for s in "$sid" "$(echo "$sid" | sed 's/[0-9]*$//')"; do
    h=$(awk -F: -v s="$s" '$1 == s { print $2; exit }' /etc/oratab 2>/dev/null || true)
    if [ -n "$h" ]; then echo "$h"; return; fi
  done
}

# Item 1: pergunta ao proprio banco onde ele escreve (v$diag_info)
diag_trace_sql() {
  local sid=$1 home=$2 to=""
  [ -x "$home/bin/sqlplus" ] || return 0
  if command -v timeout >/dev/null; then to="timeout 30"; fi
  (
    unset TWO_TASK ORACLE_PDB_SID
    export ORACLE_SID="$sid" ORACLE_HOME="$home" LD_LIBRARY_PATH="$home/lib"
    $to "$home/bin/sqlplus" -s -L / as sysdba 2>/dev/null <<'EOF'
set heading off feedback off pagesize 0
select value from v$diag_info where name = 'Diag Trace';
EOF
  ) | awk 'NF { print $1; exit }' || true
}

# Item 2: sem SQL, procura alert_<SID>.log no ADR do ORACLE_BASE (ou nos diretorios padrao),
# do mais recente para o mais antigo
alert_candidates() {
  local sid=$1 home=$2 base=""
  if [ -x "$home/bin/orabase" ]; then
    base=$(ORACLE_HOME="$home" "$home/bin/orabase" 2>/dev/null || true)
  fi
  base=${base:-${ORACLE_BASE:-}}
  local dirs=("${ALERT_SEARCH_DIRS[@]}")
  if [ -n "$base" ] && [ -d "$base/diag" ]; then dirs=("$base/diag"); fi
  find "${dirs[@]}" -type f -path "*/diag/*/$sid/trace/alert_$sid.log" -printf '%T@ %p\n' 2>/dev/null \
    | sort -rn | cut -d' ' -f2- || true
}

# Item 3: mais de um candidato -> mostra por data de modificacao e deixa escolher (0 = pular)
choose_log() {
  local sid=$1; shift
  if [ $# -eq 1 ]; then echo "$1"; return; fi
  local i=1 f n
  echo "   Varios alert logs para $sid (mais recente primeiro):" >&2
  for f in "$@"; do
    printf '     %d) %s  [%s]\n' "$i" "$f" "$(date -r "$f" '+%Y-%m-%d %H:%M')" >&2
    i=$((i + 1))
  done
  read -r -p "   Escolha [1, 0 = pular]: " n < /dev/tty || n=1
  case "${n:-1}" in
    ''|*[!0-9]*) n=1 ;;
  esac
  n=${n:-1}
  if [ "$n" -ge 1 ] && [ "$n" -le $# ]; then echo "${!n}"; fi
}

# Cria o link dest -> log; se ja existir apontando para outro log (ou quebrado), oferece trocar
link_alert() {
  local log=$1 dest=$2 name cur
  name=$(basename "$dest")
  if [ -L "$dest" ]; then
    cur=$(readlink "$dest")
    if [ "$(readlink -f "$dest")" = "$(readlink -f "$log")" ]; then
      echo "   [OK] já existe: $name"
      return
    fi
    if [ -e "$dest" ]; then
      echo "   [!] $name aponta para outro log: $cur"
    else
      echo "   [!] link quebrado: $name -> $cur"
    fi
    if ask "   Apontar $name para $log?"; then
      if ln -sfn "$log" "$dest"; then echo "   [+] link atualizado: $name"; fi
    else
      echo "   [-] mantendo: $name"
    fi
  elif [ -e "$dest" ]; then
    echo "   [!] $dest existe e nao e link; pulando."
  elif ask "   Criar link $name -> $log?"; then
    if ln -s "$log" "$dest"; then echo "   [+] criado link: $name"; fi
  else
    echo "   [-] pulando: $name"
  fi
}

# 1) Criar pasta de scripts, baixar e extrair o repo
if ask "1) Criar pasta '$TARGET_DIR' e baixar/extrair oracle_adm_scripts nela?"; then
  echo "-> Criando pasta $TARGET_DIR..."
  mkdir -p "$TARGET_DIR"
  cd "$TARGET_DIR"
  echo "-> Iniciando download do repositorio..."
  if command -v curl >/dev/null; then
    curl -sL "$REPO_URL" | tar xz --strip-components=1
  elif command -v wget >/dev/null; then
    wget -qO- "$REPO_URL" | tar xz --strip-components=1
  else
    echo "Erro: nem curl nem wget encontrados. Abortando."
    exit 1
  fi
  echo "   Download e extracao concluidos em $TARGET_DIR."
else
  echo "   Pulando criacao de pasta e download do repositorio."
fi
echo

# 2) SQLPATH
if ask "2) Adicionar '$TARGET_DIR' como SQLPATH em ~/.bash_profile? !! NAO FAZER EM ODA/EXADATA !!"; then
  if [ ! -d "$TARGET_DIR" ]; then
    echo "   Aviso: $TARGET_DIR nao existe (passo 1 pulado?). Pulando SQLPATH."
  elif grep -q 'SQLPATH' "$BASH_PROFILE" 2>/dev/null; then
    echo "   Aviso: SQLPATH ja configurado em $BASH_PROFILE. Mantendo o atual."
  else
    echo "-> Atualizando $BASH_PROFILE..."
    {
      echo
      echo "# configurado pelo install.sh em $(date +'%Y-%m-%d %H:%M:%S')"
      echo "export SQLPATH=${TARGET_DIR}"
    } >> "$BASH_PROFILE"
    echo "   SQLPATH adicionado com sucesso."
  fi
else
  echo "   Pulando configuracao do SQLPATH."
fi
echo

# 3) Links para alert logs
if ask "3) Criar $TARGET_DIAG e links para os alert logs das instancias ativas?"; then
  echo "-> Criando pasta $TARGET_DIAG..."
  mkdir -p "$TARGET_DIAG"

  echo "-> Procurando instancias ativas (pmon)..."
  found=0
  # process substitution + fd 3: o loop roda no shell atual (found persiste) e nao compete com o ask()
  while read -r pid sid <&3; do
      found=1
      home=$(instance_home "$pid" "$sid")
      echo "-> Instancia $sid (pid $pid, ORACLE_HOME ${home:-desconhecido})"

      log=""
      dir=$(diag_trace_sql "$sid" "$home")
      if [ -n "$dir" ] && [ -f "$dir/alert_$sid.log" ]; then
        log="$dir/alert_$sid.log"
        echo "   via v\$diag_info: $log"
      else
        mapfile -t cands < <(alert_candidates "$sid" "$home")
        if [ ${#cands[@]} -gt 0 ]; then
          log=$(choose_log "$sid" "${cands[@]}")
          if [ -n "$log" ]; then echo "   via ADR/disco: $log"; fi
        else
          echo "   [x] alert_$sid.log nao encontrado."
        fi
      fi

      if [ -n "$log" ]; then
        link_alert "$log" "$TARGET_DIAG/alert_$sid.log"
      fi
  done 3< <(running_instances)

  if [ "$found" -eq 0 ]; then
    echo "   Nenhuma instancia ativa encontrada."
    if ask "   Buscar alert logs no disco mesmo assim? (pode trazer logs fora de uso)"; then
      # mais recente primeiro: em nomes repetidos o primeiro link fica com o log mais novo
      while read -r log <&3; do
          echo "   Arquivo encontrado: $log [$(date -r "$log" '+%Y-%m-%d %H:%M')]"
          link_alert "$log" "$TARGET_DIAG/$(basename "$log")"
      done 3< <(find "${ALERT_SEARCH_DIRS[@]}" -type f -path '*/diag/*/trace/alert_*.log' -printf '%T@ %p\n' 2>/dev/null \
                  | sort -rn | cut -d' ' -f2-)
    fi
  fi

  echo "-> Processo concluído. Links em $TARGET_DIAG."
else
  echo "-> Pulando criação de links de alert logs."
fi
