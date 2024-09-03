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
description="Convert probability list produced by prediction scripts to one single label (MIMO POssible)"
dependencies=( "uc/eval/probs-to-label.pl" )

setupArgs() {
  opt -r out '()' "Output label table"
  optType out output table

  opt -r in '()' "Input predict table"
  optType in input table
}

main() {
  if [[ $#in != $#out ]]; then
    err "Input and output table must have the same number of parameters" 15
  fi

  local i
  for (( i=1; i<=$#out; i++ )); do
    local param="$(in::getLoader $i)"
    param+=" | uc/eval/probs-to-label.pl"

    if out::isReal $i; then
      eval "$param" | out::save $i
      if [[ $? != 0 ]]; then return 1; fi
    else
      echo "$param" | out::save $i
      if [[ $? != 0 ]]; then return 1; fi
    fi
  done
}

source Mordio/mordio
