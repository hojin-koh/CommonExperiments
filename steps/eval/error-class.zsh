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
description="Compute per-entry error reate for classification, optionally append weight to it (MIMO possible)"
dependencies=( "uc/eval/error-class.pl" )

setupArgs() {
  opt -r out '()' "Output error table"
  optType out output table
  opt -r outAvg '()' "Output average table"
  optType outAvg output table
  opt -r outTag '()' "Tag of output average"

  opt -r in '()' "Input predict table"
  optType in input table
  opt -r label '()' "Input label table"
  optType label input table

  opt weight '()' "Input optional weight table"
  optType weight input table
}

main() {
  if [[ $#outAvg != $#out ]]; then
    err "Output average and Output table must have the same number of parameters" 15
  fi

  if [[ $#outTag != $#out ]]; then
    err "Output average and Output table must have the same number of parameters" 15
  fi

  if ! outAvg::ALL::isReal; then
    err "Unreal table output for the average part not supported" 15
  fi

  computeMIMOStride out in label weight

  local i
  for (( i=1; i<=$#out; i++ )); do
    computeMIMOIndex $i out in label weight

    local param="$(in::getLoader $INDEX_in)"
    param+=" | uc/eval/error-class.pl <($(label::getLoader $INDEX_label))"
    if [[ $#weight -gt 0 ]]; then
      param+=" <($(weight::getLoader $INDEX_weight))"
    fi

    if out::isReal $i; then
      eval "$param" | out::save $i
      if [[ $? != 0 ]]; then return 1; fi
    else
      echo "$param" | out::save $i
      if [[ $? != 0 ]]; then return 1; fi
    fi

    (
      printf '%s\t' "${outTag[$i]}"
      eval "$param" | bc/bserr \
    ) | outAvg::save $i
    if [[ $? != 0 ]]; then return 1; fi
  done

}

source Mordio/mordio
