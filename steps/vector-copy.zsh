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
description="Copy vectors and put them together, without doing any checks (MIMO Possible)"
dependencies=()
importantconfig=()

setupArgs() {
  opt -r out '()' "Output vector"
  optType out output vector
  opt -r in '()' "Input vectors"
  optType in input vector
}

main() {
  computeMIMOStride in out

  local params=()
  local i
  for (( i=1; i<=$#in; i++ )); do
    computeMIMOIndex $i in out

    if [[ $INDEX_out -gt $#params ]]; then
      params[$INDEX_out]=""
    fi
    params[$INDEX_out]+="$(in::getLoader $i) ; "
  done

  for (( i=1; i<=$#out; i++ )); do
    if out::isReal $i; then
      eval "${params[$i]}" | out::save $i
      if [[ $? != 0 ]]; then return 1; fi
    else
      echo "${params[$i]}" | out::save $i
      if [[ $? != 0 ]]; then return 1; fi
    fi
  done
}

source Mordio/mordio
