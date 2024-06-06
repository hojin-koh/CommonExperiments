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
description="Train an n-gram LM"

setupArgs() {
  opt -r in '' "Input text"
  optType in input text
  opt -r out '' "Output LM"
  optType out output arpa

  opt order 3 "n-gram order"
}

main() {
  local dirTemp
  putTemp dirTemp

  in::load \
  | cut -d$'\t' -f2- \
  | estimate-ngram -verbose 0 -o "$order" -t /dev/stdin -wl "$dirTemp/lm.gz"
  out::save "$dirTemp/lm.gz"
  return $?
}

source Mordio/mordio
