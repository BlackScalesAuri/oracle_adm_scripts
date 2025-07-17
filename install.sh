#!/usr/bin/env bash
set -e

# destino dos scripts
TARGET="${HOME}/scripts"
mkdir -p "$TARGET" && cd "$TARGET"

if command -v curl >/dev/null; then
  curl -sL https://codeload.github.com/VgHy/oracle_adm_scripts/tar.gz/master \
    | tar xz --strip-components=1
elif command -v wget >/dev/null; then
  wget -qO- https://codeload.github.com/VgHy/oracle_adm_scripts/tar.gz/master \
    | tar xz --strip-components=1
else
  echo
  echo "Erro: curl ou wget nao encontrados."
  echo
  exit 1
fi


# cria o dir de destino
TARGET_DIAG="$HOME/diag_oracle"
mkdir -p "$TARGET_DIAG"

echo "Criando links em $TARGET_DIAG ..."

# varre os dirs /u01, /u02, /u03, /u04, /orabin, /orabin01 e /orabin02
for DIR in /u01 /u02 /u03 /u04 /orabin /orabin01 /orabin02 /oracle; do
  [ -d "$DIR" ] || continue
  find "$DIR" -type f -name 'alert_*.log' 2>/dev/null | while read -r log; do
    name=$(basename "$log")
    [ -e "$TARGET_DIAG/$name" ] || ln -s "$log" "$TARGET_DIAG/$name"
  done
done

echo "Links criados em $TARGET_DIAG"