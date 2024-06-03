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
description="Import Japan's and Tokyo's area list from https://zh.wikipedia.org/zh-tw/%E6%97%A5%E6%9C%AC%E8%A1%8C%E6%94%BF%E5%8D%80%E5%8A%83 and https://zh.wikipedia.org/zh-tw/%E6%9D%B1%E4%BA%AC%E9%83%BD%E5%8D%80%E9%83%A8"

setupArgs() {
  opt -r in1 '' "Original wikipedia html file"
  opt -r in2 '' "Original wikipedia html file"
  opt -r out '' "Output table"
  optType out output table
}

main() {
  if [[ ! -f "$in1" ]]; then
    info "Downloading the data from zh.wikipedia.org ..."
    curl -L -o "$in1" 'https://zh.wikipedia.org/zh-tw/%E6%97%A5%E6%9C%AC%E8%A1%8C%E6%94%BF%E5%8D%80%E5%8A%83'
  fi

  if [[ ! -f "$in2" ]]; then
    info "Downloading the data from zh.wikipedia.org ..."
    curl -L -o "$in2" 'https://zh.wikipedia.org/zh-tw/%E6%9D%B1%E4%BA%AC%E9%83%BD%E5%8D%80%E9%83%A8'
  fi

  cat "$in1" "$in2" \
  | us/parse-world-country-list.py \
  | sed -r 's/[都府]$//' \
  | out::save
  return $?
}

source Mordio/mordio
