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
description="Randomly sample an amount of lines from a table without replacement (MIMO possible)"
dependencies=( "uc/dataset-pick-random.py" )
importantconfig=(n)

setupArgs() {
  opt -r out '()' "Output table"
  optType out output table

  opt -r in '()' "Input tables"
  optType in input table
  opt label '()' "Input label tables"
  optType label input table

  opt -r n '()' "Number of entries to pick"
}

main() {
  computeMIMOStride out in label n

  local i
  local param
  for (( i=1; i<=$#out; i++ )); do
    computeMIMOIndex $i out in label n

    param=$(in::getLoader $INDEX_in)
    param+=" | uc/dataset-pick-random.py '${n[$INDEX_n]}'"
    if [[ $#label -gt 0 ]]; then
      param+=" <($(label::getLoader $INDEX_label))"
    fi

    if out::isReal $i; then
      eval "$param" | out::save $i
      if [[ $? != 0 ]]; then return 1; fi
    else
      printf "%s" "$param" | out::save $i
      if [[ $? != 0 ]]; then return 1; fi
    fi
  done
}

source Mordio/mordio
