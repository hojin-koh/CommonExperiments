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
description="Count how many tokens is in the first field"
dependencies=( "uc/count-tokens.pl" )

setupArgs() {
  opt -r in '' "Input table"
  optType in input table
  opt -r out '' "Output table"
  optType out output table
}

main() {
  if out::isReal; then
    in::load \
    | uc/count-tokens.pl \
    | out::save
    return $?
  fi

  (
    in::getLoader
    printf " | uc/count-tokens.pl"
  ) | out::save
  return $?
}

source Mordio/mordio
