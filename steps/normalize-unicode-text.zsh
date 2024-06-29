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
description="Normalize unicode in the text (MIMO possible)"
dependencies=( "uc/normalize-unicode.py" )
importantconfig=()

setupArgs() {
  opt -r in '()' "Input text"
  optType in input text
  opt -r conv '()' "Input character mapping table"
  optType conv input table
  opt -r out '()' "Output text"
  optType out output text
}

main() {
  if ! out::ALL::isReal; then
    err "Unreal table output not supported" 15
  fi

  computeMIMOStride out in conv

  local dirTemp
  putTemp dirTemp

  local nr
  local i
  for (( i=1; i<=$#out; i++ )); do
    computeMIMOIndex $i out in conv
    getMeta in $INDEX_in nRecord nr
    if [[ $nr -lt 500000 ]]; then
      in::load $INDEX_in \
      | processSub $INDEX_conv \
      | lineProgressBar $nr \
      | out::save $i
      if [[ $? != 0 ]]; then return 1; fi
    else
      # Get a list of all text
      in::loadKey $INDEX_in > "$dirTemp/all.list"

      in::load $INDEX_in \
      | doParallelPipeText "$nj" "$nr" "$dirTemp/all.list" \
      "$dirTemp" \
      "processSub $INDEX_conv" \
      | out::save $i
      if [[ $? != 0 ]]; then return 1; fi
    fi
  done # End for each set
}

processSub() {
  local idx=$1
  uc/normalize-unicode.py <(conv::load $idx) text
}

source Mordio/mordio
