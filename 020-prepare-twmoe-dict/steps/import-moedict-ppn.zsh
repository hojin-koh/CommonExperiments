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
description="Import some proper noun from moedict"
dependencies=( "us/parse-moedict.py" )

setupArgs() {
  opt -r out '' "Output table"
  optType out output table
  opt -r in '' "Original moedict html directory"
}

processOne() {
  local id="$1"
  local filter="$2"
  shift; shift;

  if [[ ! -f "$in/$id.txt" ]]; then
    info "Downloading the data from moedict.tw ..."
    curl -L -o "$in/$id.txt" "https://www.moedict.tw/=$filter"
  fi
  us/parse-moedict.py "$@" < "$in/$id.txt" | gawk '{print $1 "'"\tmoedict-$id"'"}'
}

main() {
  mkdir -p "$in"

  if ! out::isReal; then
    err "Unreal table output not supported" 15
  fi

  (
    processOne stars "星名" - 4
    processOne signs "星座名" - 4
    processOne microbes "微生物" - 5
    processOne plants "植物名" - 5
    processOne animals "動物名" - 5
    processOne instruments "樂器名" - 5
    processOne weapons "武器名" - 5
    processOne disease "病名" - 7
  ) | sort -u \
  | out::save
  return $?
}

source Mordio/mordio
