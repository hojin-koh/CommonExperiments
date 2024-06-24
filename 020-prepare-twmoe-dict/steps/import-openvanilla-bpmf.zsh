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
description="Import OpenVanilla Bopomofo word frequency list into dictionary from https://github.com/openvanilla/McBopomofo"
dependencies=( "uc/prep/import-text-wordfreq.py" "us/filter-openvanilla.pl" )

setupArgs() {
  opt -r out '' "Output table"
  optType out output table
  opt -r outraw '' "Output table unfiltered"
  optType outraw output table
  opt -r in '' "Original data archive"
}

main() {
  if [[ ! -f "$in" ]]; then
    info "Downloading the data from github.com ..."
    curl -L -o "$in" 'https://raw.githubusercontent.com/openvanilla/McBopomofo/master/Source/Data/phrase.occ'
  fi

  if ! outraw::isReal || ! out::isReal; then
    err "Unreal table output not supported" 15
  fi

  local dirTemp
  putTemp dirTemp

  uc/prep/import-text-wordfreq.py 1000 3 s2twp.json <"$in" \
  | perl -CSAD -nle 'print $_ . "\topenvanilla-bpmf"' \
  > $dirTemp/table.full

  outraw::save < $dirTemp/table.full

  us/filter-openvanilla.pl < $dirTemp/table.full \
  | sort -u \
  | out::save
  return $?
}

source Mordio/mordio
