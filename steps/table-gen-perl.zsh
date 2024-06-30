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
description="Generate a new table based on ids of another table and a perl conversion rule (MIMO possible)"
dependencies=()
importantconfig=(rule)

setupArgs() {
  opt -r out '()' "Output table"
  optType out output table
  
  opt -r rule '()' "Perl conversion rule"
  opt -r in '()' "Input table"
  optType in input table
}

main() {
  if ! out::ALL::isReal; then
    err "Unreal table output not supported" 15
  fi

  computeMIMOStride out in rule

  local nr
  local i
  for (( i=1; i<=$#out; i++ )); do
    computeMIMOIndex $i out in rule
    info "ID conversion rule: ${rule[$INDEX_rule]}"
    getMeta in $INDEX_in nRecord nr

    if out::isReal $i; then
      in::load $INDEX_in \
      | perl -CSAD -nle "${rule[$INDEX_rule]}" \
      | lineProgressBar $nr \
      | out::save $i
      if [[ $? != 0 ]]; then return 1; fi
    else
      (
        in::getLoader $INDEX_in
        printf " | perl -CSAD -nle '%s'" "${rule[$INDEX_rule]}"
      ) | out::save $i
      if [[ $? != 0 ]]; then return 1; fi
    fi
  done
}

source Mordio/mordio
