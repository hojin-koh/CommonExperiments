#!/usr/bin/env bash
set -euo pipefail

TARGET="$1"
DIR_COMMONEXP="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

mkdir -pv "$TARGET"

# Assuming zsh-Mordio is in ../zsh-Mordio
if [[ ! -h "$TARGET/Mordio" ]]; then
  ln -sTv "$DIR_COMMONEXP/../zsh-Mordio" "$TARGET/Mordio"
fi

if [[ ! -h "$TARGET/sc" ]]; then
  ln -sTv "$DIR_COMMONEXP/steps" "$TARGET/sc"
fi
if [[ ! -h "$TARGET/uc" ]]; then
  ln -sTv "$DIR_COMMONEXP/utils" "$TARGET/uc"
fi

# Binary things
make -C "$DIR_COMMONEXP/src"
if [[ ! -h "$TARGET/bc" ]]; then
  ln -sTv "$DIR_COMMONEXP/bin" "$TARGET/bc"
fi

# Make a "relink" script
if [[ ! -x "$TARGET/link.again.sh" ]]; then
  rm -fv "$TARGET/link.again.sh"
  cat > "$TARGET/link.again.sh" <<EOF
#!/usr/bin/bash -v
set -euo pipefail

EOF
  printf '"%s"' "$(readlink -f "$0")" >> "$TARGET/link.again.sh"
  printf ' "%s"' "$@" >> "$TARGET/link.again.sh"
  chmod 755 "$TARGET/link.again.sh"
fi
