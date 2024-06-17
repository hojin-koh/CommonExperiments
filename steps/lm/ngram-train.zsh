#!/usr/bin/env zsh
# Copyright 2020-2024, Hojin Koh
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
description="Train an n-gram LM"

setupArgs() {
  opt -r in '' "Input text"
  optType in input text
  opt -r out '' "Output LM"
  optType out output model

  # TODO: vocab

  opt order 3 "n-gram order"
  opt mincount '()' "Mininum count to be included in the LM, 1 if unspecified"
}

main() {
  if [[ $out != *.bz2 ]]; then
    err "Output model can only end in .bz2 format" 16
  fi

  local dirTemp
  putTemp dirTemp

  # Construct the awk command-line to prune counts
  local i
  local filt=""
  for i in {1..$order}; do
    if [[ -n $filt ]]; then
      filt+=" || "
    fi
    filt+="(NF-1 == $i && \$NF >= ${mincount[i]-1})"
    true
  done
  info "mincount filter: $filt"

  in::loadValue \
  | estimate-ngram -verbose 0 -o "$order" -t /dev/stdin -wc /dev/stdout \
  | gawk "$filt" \
  | estimate-ngram -o "$order" -c /dev/stdin -wl $dirTemp/lm.bz2
  local rslt=$?

  out::saveCopy $dirTemp/lm.bz2

  return $rslt
}

source Mordio/mordio
