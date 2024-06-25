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
description="Apply a mapping to a table (MIMO)"
dependencies=( "uc/table-apply-map.pl" "uc/reverse-mapping.pl" )
importantconfig=(merger)

setupArgs() {
  opt -r out '()' "Output table"
  optType out output table

  opt -r in '()' "Input table"
  optType in input table
  opt -r map '' "Input mapping table"
  optType map input table

  opt merger '"join \" \", @F"' "Merging expression in perl, like (reduce { \$a + \$b } 0, @F) / @F"
}

main() {
  if [[ $#out != $#in ]]; then
    err "Input and Output must have the same number of parameters" 15
  fi

  local i
  for (( i=1; i<=$#out; i++ )); do
    info "Processing file set $i/$#in: ${out[$i]}"
    local param="$(map::getLoader) | uc/reverse-mapping.pl"
    param+=" | uc/table-apply-map.pl ${(q+)merger} <($(in::getLoader $i))"

    if out::isReal $i; then
      eval "$param" | out::save $i
      if [[ $? != 0 ]]; then return $?; fi
    else
      echo "$param" | out::save $i
      if [[ $? != 0 ]]; then return $?; fi
    fi
  done


}

source Mordio/mordio
