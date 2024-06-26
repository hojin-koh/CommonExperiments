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
description="Splitting Chinese documents into sentences based on punctuation and newlines"
dependencies=( "uc/text-split-sent-zh.py" )
importantconfig=(sym thres min prefix)

setupArgs() {
  opt -r in '' "Unsplitted raw text"
  optType in input text
  opt -r out '' "Output text"
  optType out output text

  opt sym '()' "Additional symbols for sentence segmentation"
  opt thres 2 "Threshold on sentence length"
  opt min 0 "Minimum sentence length"
  opt prefix s "Prefix indicating a sentence"
}

main() {
  if ! out::isReal; then
    err "Unreal table output not supported" 15
  fi

  local nr
  getMeta in '' nRecord nr

  in::load \
    | lineProgressBar $nr \
    | python3 uc/text-split-sent-zh.py "$thres" "$min" "$prefix" "${sym[@]}" \
    | out::save
  return $?
}

source Mordio/mordio
