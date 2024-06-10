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
description="Import idiom list from moedict"
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
    processOne idioms "諺語" idioms 10
    processOne honorifics "稱謂" - 3
    processOne sports "球類" - 3
    processOne units "量詞" - 3
    processOne buntei "文體名" - 3
    processOne holy "節氣" - 2
  ) | sort -u \
  | out::save
  return $?
}

source Mordio/mordio
