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
description="Import THUOCL dictionaries from China: https://github.com/thunlp/THUOCL"
dependencies=( "uc/prep/import-text-wordfreq.py" "us/filter-thuocl.pl" )

setupArgs() {
  opt -r out '' "Output table"
  optType out output table
  opt -r outraw '' "Output table unfiltered"
  optType outraw output table
  opt -r in '' "Original input directory"
}

processOne() {
  local id="$1"
  shift;

  if [[ ! -f "$in/$id.txt" ]]; then
    info "Downloading the data from github.com/THUOCL ..."
    curl -L -o "$in/$id.txt" "https://raw.githubusercontent.com/thunlp/THUOCL/master/data/THUOCL_$id.txt"
  fi
  uc/prep/import-text-wordfreq.py "$@" < "$in/$id.txt" \
  | perl -CSAD -nle "print \$_ . \"\\tthuocl-$id\""
}

main() {
  mkdir -p "$in"

  if ! outraw::isReal || ! out::isReal; then
    err "Unreal table output not supported" 15
  fi

  local dirTemp
  putTemp dirTemp

  (
    processOne food 10000 4 s2twp.json
    processOne law 100000 3 s2twp.json
    processOne medical 2000 3 s2twp.json
    processOne lishimingren 750 4 s2twp.json
    processOne caijing 11900 5 s2twp.json
  ) > $dirTemp/table.full

  outraw::save < $dirTemp/table.full

  us/filter-thuocl.pl < $dirTemp/table.full \
  | sort -u \
  | out::save
  return $?
}

source Mordio/mordio
