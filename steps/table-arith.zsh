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
description="Do arithmetics with the nth (n>0) field with multiple tables (MIMO possible)"

setupArgs() {
  opt -r in '()' "Input tables"
  optType in input table
  opt -r out '()' "Output table"
  optType out output table

  opt nth '(2)' "The field index of the value to be used from tables. 1 is the key, 2 is typically the first value."
  opt -r arith '()' "Arithemetic expression, like \$F[1]-\$F[2]"
}

main() {
  computeMIMOStride in out nth arith

  local params=()
  local paramsPost=()
  local i
  for (( i=1; i<=$#in; i++ )); do
    computeMIMOIndex $i in out nth arith

    if [[ $INDEX_out -gt $#params ]]; then
      params[$INDEX_out]="paste -d\$'\t' <($(in::getLoaderKey $i))"
      paramsPost[$INDEX_out]=" | uc/table-arith.pl '${arith[$INDEX_arith]}'"
    fi
    params[$INDEX_out]+=" <($(in::getLoader $i) | cut -d\$'\t' -f${nth[$INDEX_nth]})"
  done

  for (( i=1; i<=$#out; i++ )); do
    if out::isReal $i; then
      eval "${params[$i]}${paramsPost[$i]}" | out::save $i
      if [[ $? != 0 ]]; then return 1; fi
    else
      echo "${params[$i]}${paramsPost[$i]}" | out::save $i
      if [[ $? != 0 ]]; then return 1; fi
    fi
  done
}

source Mordio/mordio
