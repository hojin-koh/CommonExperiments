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
description="Segment the text document into characters (MIMO)"
dependencies=( "uc/text-delete-nonnlp.pl" )
importantconfig=()

setupArgs() {
  opt -r in '()' "Input text"
  optType in input text
  opt -r out '()' "Output text"
  optType out output text
}

main() {
  if ! out::ALL::isReal; then
    err "Unreal table output not supported" 15
  fi

  if [[ $#in != $#out ]]; then
    err "Input and Output must have the same number of files" 15
  fi

  local dirTemp
  putTemp dirTemp

  local nr
  local i
  for (( i=1; i<=$#in; i++ )); do
    info "Processing file set $i/$#in: ${in[$i]}"
    getMeta in $i nRecord nr
    if [[ $nr -lt 500000 ]]; then
      in::load $i \
      | processSub \
      | lineProgressBar $nr \
      | out::save $i
      if [[ $? != 0 ]]; then return 1; fi
    else
      # Get a list of all text
      in::loadKey $i > "$dirTemp/all.list"

      in::load $i \
      | doParallelPipeText "$[nj/2]" "$nr" "$dirTemp/all.list" \
          "$dirTemp" \
          "processSub" \
      | out::save $i
      if [[ $? != 0 ]]; then return 1; fi
    fi
  done
  return $?
}

processSub() {
  uc/text-delete-nonnlp.pl \
  | bc/mmseg /dev/null /dev/null
}

source Mordio/mordio
