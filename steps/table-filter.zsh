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
description="Do arithmetics with the nth (n>0) field with multiple tables"

setupArgs() {
  opt -r in '' "Input table"
  optType in input table
  opt -r out '' "Output table"
  optType out output table

  opt -r infilt '' "Filter value table"
  optType infilt input table

  opt -r filt '' "Filter expression, like \$F eq \"train\""
}

main() {
  in::load \
  | uc/table-filter.pl "$filt" <(infilt::load) \
  | out::save
  return $?
}

source Mordio/mordio
