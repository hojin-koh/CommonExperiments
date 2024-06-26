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
description="Segment the text document into words (MIMO possible)"
dependencies=( "uc/text-delete-nonnlp.pl" )
importantconfig=()

setupArgs() {
  opt -r in '()' "Input text"
  optType in input text
  opt -r out '()' "Output text"
  optType out output text

  opt -r dict '()' "Word dictionary table"
  optType dict input table
  opt -r freq '()' "Char frequency table"
  optType freq input table
}

main() {
  if ! out::ALL::isReal; then
    err "Unreal table output not supported" 15
  fi

  computeMIMOStride out in dict freq

  local dirTemp
  putTemp dirTemp

  local nr
  local i
  for (( i=1; i<=$#out; i++ )); do
    computeMIMOIndex $i out in dict freq
    getMeta in $INDEX_in nRecord nr
    if [[ $nr -lt 500000 ]]; then
      in::load $INDEX_in \
      | processSub $INDEX_dict $INDEX_freq \
      | lineProgressBar $nr \
      | out::save $i
      if [[ $? != 0 ]]; then return 1; fi
    else
      # Get a list of all text
      in::loadKey $INDEX_in > "$dirTemp/all.list"

      in::load $INDEX_in \
      | doParallelPipeText "$[nj/2]" "$nr" "$dirTemp/all.list" \
          "$dirTemp" \
          "processSub $INDEX_dict $INDEX_freq" \
      | out::save $i
      if [[ $? != 0 ]]; then return 1; fi
    fi
  done
}

processSub() {
  local idxDict=$1
  local idxFreq=$2
  uc/text-delete-nonnlp.pl \
  | bc/mmseg <(dict::loadKey $idxDict) <(freq::load $idxFreq)
}

source Mordio/mordio
