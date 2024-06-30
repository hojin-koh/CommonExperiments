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
description="Reverse a mapping to construct a value->key mapping table (MIMO possible)"
dependencies=( "uc/reverse-mapping.pl" )
importantconfig=()

setupArgs() {
  opt -r in '()' "Input table"
  optType in input table
  opt -r out '()' "Output table"
  optType out output table
}

main() {
  computeMIMOStride out in

  local i
  for (( i=1; i<=$#out; i++ )); do
    computeMIMOIndex $i out in
    if out::isReal $i; then
      in::load $INDEX_in \
      | uc/reverse-mapping.pl \
      | out::save $i
      if [[ $? != 0 ]]; then return 1; fi
    else
      (
        in::getLoader $INDEX_in
        printf " | uc/reverse-mapping.pl"
      ) | out::save $i
      if [[ $? != 0 ]]; then return 1; fi
    fi
  done

}

source Mordio/mordio
