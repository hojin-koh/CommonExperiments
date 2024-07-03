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
description="Extract vocabulary list by class (MIMO possible)"
dependencies=( "uc/lm/wlist-byclass.py" )
importantconfig=(uniq max)

setupArgs() {
  opt -r out '()' "Output table"
  optType out output table

  opt -r in '()' "Input text"
  optType in input text
  opt -r label '()' "Input label table"
  optType label input table

  opt uniq '(false)' "Whether to only extract class-unique vocabulary or not"
  opt max '(0)' "Maximum number of words per class, picked through frequency, 0 to disable"
}

main() {
  computeMIMOStride out in label uniq max

  local i
  for (( i=1; i<=$#out; i++ )); do
    computeMIMOIndex $i out in label uniq max
    info "Use unique mode: ${uniq[$INDEX_uniq]}"

    local param="$(in::getLoader $INDEX_in)"
    param+=" | uc/lm/wlist-byclass.py"
    if [[ ${uniq[$INDEX_uniq]} == true ]]; then
      param+=" --uniq"
    fi
    param+=" <($(label::getLoader $INDEX_label)) ${max[$INDEX_max]}"

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
