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
description="Get inclsion rate or oov rate vector from wlist (MIMO possible)"
dependencies=( "uc/lm/wlist-inc.py" )
importantconfig=(uniq count oov)

setupArgs() {
  opt -r out '()' "Output vector"
  optType out output vector

  opt -r in '()' "Input text"
  optType in input text
  opt -r wlist '()' "Input word list"
  optType wlist input table

  opt uniq '(false)' "Whether to count only each word once per utterance"
  opt count '(false)' "Use raw count instead of normalizing by utterance length"
  opt oov '(false)' "Output oov rate instead of inclusion rate"
}

main() {
  computeMIMOStride out in wlist oov count uniq

  local i
  for (( i=1; i<=$#out; i++ )); do
    computeMIMOIndex $i out in wlist oov count uniq
    info "Use uniq=${uniq[$INDEX_uniq]} count=${count[$INDEX_count]} oov=${oov[$INDEX_oov]}"

    local param="$(in::getLoader $INDEX_in)"
    param+=" | uc/lm/wlist-inc.py"
    if [[ ${uniq[$INDEX_uniq]} == true ]]; then
      param+=" --uniq"
    fi
    if [[ ${count[$INDEX_count]} == true ]]; then
      param+=" --count"
    fi
    if [[ ${oov[$INDEX_oov]} == true ]]; then
      param+=" --oov"
    fi
    param+=" <($(wlist::getLoader $INDEX_wlist))"

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
