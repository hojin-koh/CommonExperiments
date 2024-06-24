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
description="Import china's word frequency list into dictionary from https://github.com/bedlate/cn-corpus"
dependencies=( "uc/prep/import-xls-table.py" "us/filter-china-freqword.pl" )

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
    curl -L -o "$in" 'https://github.com/bedlate/cn-corpus/raw/master/%E7%8E%B0%E4%BB%A3%E6%B1%89%E8%AF%AD%E8%AF%AD%E6%96%99%E5%BA%93%E8%AF%8D%E9%A2%91%E8%A1%A8.xls'
  fi

  if ! outraw::isReal || ! out::isReal; then
    err "Unreal table output not supported" 15
  fi

  local dirTemp
  putTemp dirTemp

  uc/prep/import-xls-table.py "$in" 1 8 s2twp.json 2 \
  | perl -CSAD -nle 'print $_ . "\tchina-freqword"' \
  > $dirTemp/table.full

  outraw::save < $dirTemp/table.full

  us/filter-china-freqword.pl < $dirTemp/table.full \
  | sort -u \
  | out::save
  return $?
}

source Mordio/mordio
