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
description="Import world country list from https://zh.wikipedia.org/zh-tw/%E5%90%84%E5%9B%BD%E9%A6%96%E9%83%BD%E5%88%97%E8%A1%A8"

setupArgs() {
  opt -r in '' "Original wikipedia html file"
  opt -r out '' "Output table"
  optType out output table
}

main() {
  if [[ ! -f "$in" ]]; then
    info "Downloading the data from zh.wikipedia.org ..."
    curl -L -o "$in" 'https://zh.wikipedia.org/zh-tw/%E5%90%84%E5%9B%BD%E9%A6%96%E9%83%BD%E5%88%97%E8%A1%A8'
  fi

  us/parse-world-capital-list.py < "$in" \
  | out::save
  return $?
}

source Mordio/mordio
