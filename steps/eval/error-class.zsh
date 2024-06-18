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
description="Compute per-entry error reate for classification, optionally append weight to it"
dependencies=( "uc/eval/error-class.pl" )

setupArgs() {
  opt -r out '' "Output error table"
  optType out output table

  opt -r in '' "Input predict table"
  optType in input table
  opt -r label '' "Input label table"
  optType label input table

  opt weight '' "Input optional weight table"
  optType weight input table
}

main() {
  local param="$(in::getLoader)"
  param+=" | uc/eval/error-class.pl <($(label::getLoader))"
  if [[ -n $weight ]]; then
    param+=" <($(weight::getLoader))"
  fi

  if out::isReal; then
    eval "$param" | out::save
    return $?
  fi

  echo "$param" | out::save
  return $?
}

source Mordio/mordio