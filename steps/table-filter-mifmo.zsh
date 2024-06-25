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
description="Filter a table through another table and a perl expression (MifMO)"
dependencies=( "uc/table-filter.pl" )
importantconfig=(filt)

setupArgs() {
  opt -r out '()' "Output table"
  optType out output table

  opt -r in '' "Input table"
  optType in input table
  opt -r infilt '()' "Filter value table"
  optType infilt input table

  opt filt '1 == 1' "Filter expression, like \$F eq \"train\""
}

main() {
  if [[ $#out != $#infilt ]]; then
    err "Input filter and Output must have the same number of parameters" 15
  fi

  local i
  for (( i=1; i<=$#out; i++ )); do
    info "Processing file set $i/$#infilt: ${infilt[$i]}"
    local param="$(in::getLoader)"
    param+=" | uc/table-filter.pl ${(q+)filt} <($(infilt::getLoader $i))"

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
