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
description="Do arithmetics with the nth (n>0) field with multiple tables"

setupArgs() {
  opt -r in '()' "Input tables"
  optType in input table
  opt -r out '' "Output table"
  optType out output table

  opt nth 2 "The field index of the value to be used from tables. 1 is the key, 2 is typically the first value."
  opt -r arith '' "Arithemetic expression, like \$F[1]-\$F[2]"
}

main() {
  local i
  local fdKey
  local fdThis
  exec {fdKey}< <(in::load 1 | cut -d$'\t' -f1)
  local fds=( $fdKey )
  local param="/dev/fd/$fdKey"
  for (( i=1; i<=${#in[@]}; i++ )); do
    exec {fdThis}< <(in::load $i | cut -d$'\t' -f$nth)
    fds+=( $fdThis )
    param+=" /dev/fd/$fdThis"
  done

  paste -d$'\t' "${(z)param}" \
  | uc/table-arith.pl "$arith" \
  | out::save
  local rslt=$?

  for fd in "${fds[@]}"; do
    exec {fd}<&-
  done
  return $rslt
}

source Mordio/mordio
