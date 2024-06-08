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
description="Import twmoe basic dictionary from https://language.moe.gov.tw/001/Upload/Files/site_content/M0001/respub/dict_concised_download.html"
dependencies=( "us/parse-twmoe-concised.py" )

setupArgs() {
  opt -r out '' "Output table"
  optType out output table
  opt -r in '' "Original data archive"
}

main() {
  if [[ ! -f "$in" ]]; then
    info "Downloading the data from language.moe.gov.tw ..."
    curl -L -o "$in" 'https://language.moe.gov.tw/001/Upload/Files/site_content/M0001/respub/download/dict_concised_2014_20240326.zip'
  fi

  if ! out::isReal; then
    err "Unreal table output not supported" 15
  fi

  info "Extracting to a temporary directory ..."
  local dirTemp
  putTemp dirTemp
  bsdtar xf "$in" -C "$dirTemp"

  us/parse-twmoe-concised.py "$dirTemp"/*.xlsx \
  | sort -u \
  | gawk '{print $1 "\ttwmoe-concised"}' \
  | out::save
  return $?
}

source Mordio/mordio
