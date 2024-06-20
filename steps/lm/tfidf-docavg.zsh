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
description="Extract average TF-IDF for each document"
dependencies=( "uc/lm/tfidf-docavg.py" )

setupArgs() {
  opt -r out '' "Output table"
  optType out output table

  opt -r in '' "Input text"
  optType in input text
  opt -r model '' "Output LM"
  optType model input model
  opt -r vocab '' "Input vocabulary model"
  optType vocab input model
}

main() {
  if ! out::isReal; then
    err "Unreal table output not supported" 15
  fi

  local nr="$(in::getNR)"
  in::load \
  | uc/lm/tfidf-docavg.py "$model" "$vocab" \
  | lineProgressBar $nr \
  | out::save
  return $?
}

source Mordio/mordio
