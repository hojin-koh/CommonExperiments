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
description="Filter a table through another table and a perl expression"
dependencies=( "uc/table-filter.pl" )

setupArgs() {
  opt -r out '' "Output table"
  optType out output table

  opt -r in '' "Input table"
  optType in input table
  opt -r infilt '' "Filter value table"
  optType infilt input table

  opt filt '1 == 1' "Filter expression, like \$F eq \"train\""
}

main() {
  local param="$(in::getLoader)"
  param+=" | uc/table-filter.pl ${(q+)filt} <($(infilt::getLoader))"

  if out::isReal; then
    eval "$param" | out::save
    return $?
  fi

  echo "$param" | out::save
  return $?
}

source Mordio/mordio
