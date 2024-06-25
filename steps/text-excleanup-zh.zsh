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
description="Do some pretty terrible cleanups to reduce English/symbol noise in text (MIMO)"
dependencies=( "uc/text-excleanup-zh.pl" )
importantconfig=()

setupArgs() {
  opt -r in '()' "Input text"
  optType in input text
  opt -r out '()' "Output table"
  optType out output table
}

main() {
  if ! out::ALL::isReal; then
    err "Unreal table output not supported" 15
  fi

  if [[ $#in != $#out ]]; then
    err "Input and Output must have the same number of files" 15
  fi

  local nr
  local i
  for (( i=1; i<=$#in; i++ )); do
    info "Processing file set $i/$#in: ${in[$i]}"
    getMeta in $i nRecord nr
    in::load $i \
    | uc/text-excleanup-zh.pl \
    | lineProgressBar $nr \
    | out::save $i
    if [[ $? != 0 ]]; then return 1; fi
  done
}

source Mordio/mordio
