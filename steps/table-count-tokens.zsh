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
description="Count how many tokens is in the first field (MIMO)"
dependencies=( "uc/count-tokens.pl" )
importantconfig=(normk)

setupArgs() {
  opt -r in '()' "Input table"
  optType in input table
  opt -r out '()' "Output table"
  optType out output table

  opt normk '' "Normalize count to between 0-1 with this number as k>0: 2*atan(loglikehood/k)/PI"
}

main() {
  if [[ $#in != $#out ]]; then
    err "Input and Output must have the same number of files" 15
  fi

  local i
  for (( i=1; i<=$#in; i++ )); do
    info "Processing file set $i/$#in: ${out[$i]}"
    if out::isReal $i; then
      in::load $i \
      | uc/count-tokens.pl \
      | if [[ -n $normk ]]; then uc/num/atan-feats.pl -$normk; else cat; fi \
      | out::save $i
      if [[ $? != 0 ]]; then return $?; fi
    else
      (
        in::getLoader $i
        printf " | uc/count-tokens.pl"
        if [[ -n $normk ]]; then
          printf " | uc/num/atan-feats.pl $normk"
        fi
      ) | out::save $i
      if [[ $? != 0 ]]; then return $?; fi
    fi
  done
}

source Mordio/mordio
