#!/usr/bin/env bash
set -euo pipefail

TARGET="$1"
DIR_SPECIFICEXP="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

source "$DIR_SPECIFICEXP/../link.sh" "$@"

# Link the corpus folder
if [[ ! -h "$TARGET/dl" ]]; then
  if [[ -d "$TARGET/../../data" ]]; then
    mkdir -pv "$TARGET/../../data/common-lexicon"
    ln -sTv "../../data/common-lexicon" "$TARGET/dl"
  else
    mkdir -pv "$TARGET/dl"
  fi
fi

