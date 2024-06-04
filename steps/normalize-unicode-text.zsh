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
description="Normalize unicode in the keys of a table"

setupArgs() {
  opt -r in '' "Input text"
  optType in input text
  opt -r conv '' "Input character mapping table"
  optType conv input table
  opt -r out '' "Output text"
  optType out output text
}

main() {
  in::load \
  | uc/normalizeUnicode.py <(conv::load) text \
  | out::save
  return $?
}

source Mordio/mordio
