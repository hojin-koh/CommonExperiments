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
description="Segment the text document into characters"

setupArgs() {
  opt -r in '' "Input text"
  optType in input text
  opt -r out '' "Output text"
  optType out output text
}

main() {
  local nr="$(in::getNR)" # TODO: parallelize if nr > like 500000

  in::load \
  | uc/dropNonNLPNoise.pl \
  | bc/mmseg /dev/null /dev/null \
  | lineProgressBar $nr \
  | out::save
  return $?
}

source Mordio/mordio
