#!/usr/bin/env bash
set -euo pipefail

TARGET="$1"
DIR_COMMONEXP="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

mkdir -pv "$TARGET"

# Assuming zsh-Mordio is in ../zsh-Mordio
if [[ ! -h "$TARGET/Mordio" ]]; then
  ln -sTv "$DIR_COMMONEXP/../zsh-Mordio" "$TARGET/Mordio"
fi

# Link common scripts
if [[ ! -h "$TARGET/sc" ]]; then
  ln -sTv "$DIR_COMMONEXP/steps" "$TARGET/sc"
fi
if [[ ! -h "$TARGET/uc" ]]; then
  ln -sTv "$DIR_COMMONEXP/utils" "$TARGET/uc"
fi

# Link specific experiment scripts (if present)
# Usually, it is from the exp-specific link.sh calling this script
if [[ -n "${DIR_SPECIFICEXP-}" ]]; then
  EXPNAME="${DIR_SPECIFICEXP##*/}"
  if [[ ! -h "$TARGET/ss" ]]; then
    ln -sTv "$DIR_SPECIFICEXP/steps" "$TARGET/ss"
  fi
  if [[ ! -h "$TARGET/us" ]]; then
    ln -sTv "$DIR_SPECIFICEXP/utils" "$TARGET/us"
  fi
  if [[ ! -h "$TARGET/run" ]]; then
    ln -sTv "$DIR_SPECIFICEXP/run" "$TARGET/run"
  fi
  if [[ ! -h "$TARGET/Makefile" ]]; then
    ln -sTv "run/Makefile" "$TARGET/Makefile"
  fi
fi # End if specific experiment present



# Link the general raw corpora folder
if [[ ! -e "$TARGET/craw" ]]; then
  if [[ -d "$TARGET/../../corpus" ]]; then
    ln -sTv "../../corpus" "$TARGET/craw"
  else
    mkdir -pv "$TARGET/craw"
  fi
fi


# Experiment-specific data
if [[ -n "${DIR_SPECIFICEXP-}" ]]; then
  # Link the data folder
  if [[ ! -e "$TARGET/ds" ]]; then
    if [[ -d "$TARGET/../../data" ]]; then
      mkdir -pv "$TARGET/../../data/$EXPNAME"
      ln -sTv "../../data/$EXPNAME" "$TARGET/ds"
    else
      mkdir -pv "$TARGET/ds"
    fi
  fi

  # Link the results storage
  if [[ ! -e "$TARGET/rslt" ]]; then
    if [[ -d "$TARGET/../../rslt" ]]; then
      TGTNAME="$(basename "$TARGET")"
      mkdir -pv "$TARGET/../../rslt/$TGTNAME"
      ln -sTv "../../rslt/$TGTNAME" "$TARGET/rslt"
    else
      mkdir -pv "$TARGET/rslt"
    fi
  fi
fi # End if specific experiment present

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
  printf "'%s'" "$(readlink -f "$0")" >> "$TARGET/link.again.sh"
  printf " '%s'" "$(readlink -f "$1")" >> "$TARGET/link.again.sh"
  chmod 755 "$TARGET/link.again.sh"
fi

# Make "requirements.txt" for python scripts
(
if [[ -f "$TARGET/uc/requirements.txt" ]]; then
  echo "-r uc/requirements.txt"
fi
if [[ -f "$TARGET/us/requirements.txt" ]]; then
  echo "-r us/requirements.txt"
fi
) > "$TARGET/requirements.txt"
