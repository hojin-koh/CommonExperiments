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
description="Post-process zh-wiki data as text"
dependencies=( "us/process-zhwiki.py" )

setupArgs() {
  opt -r out '' "Output text"
  optType out output text
  opt -r in '' "Input text"
  optType in input text
}

main() {
  if ! out::isReal; then
    err "Unreal text output not supported" 15
  fi

  local nr="$(in::getNR)"
  local dirTemp
  putTemp dirTemp

  # Get a list of all text
  in::loadKey > "$dirTemp/all.list"

  in::load \
  | doParallelPipeText "$nj" "$nr" "$dirTemp/all.list" \
      "$dirTemp" \
      "us/process-zhwiki.py" \
  | out::save
  return $?
}

source Mordio/mordio
