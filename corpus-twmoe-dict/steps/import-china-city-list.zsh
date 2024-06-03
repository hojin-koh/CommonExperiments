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
description="Import China city list from "

setupArgs() {
  opt -r in '' "Original json file"
  opt -r out '' "Output table"
  optType out output table
}

main() {
  if [[ ! -f "$in" ]]; then
    info "Downloading the data from github.com ..."
    curl -L -o "$in" 'https://github.com/small-dream/China_Province_City/raw/master/2022%E5%B9%B4%E6%9C%80%E6%96%B0%E4%B8%AD%E5%8D%8E%E4%BA%BA%E6%B0%91%E5%85%B1%E5%92%8C%E5%9B%BD%E5%8E%BF%E4%BB%A5%E4%B8%8A%E8%A1%8C%E6%94%BF%E5%8C%BA%E5%88%92%E4%BB%A3%E7%A0%81.json'
  fi

  us/parse-china-city-list.py < "$in" \
  | out::save
  return $?
}

source Mordio/mordio
