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
description="Import world important city list from https://zh.wikipedia.org/zh-tw/%E6%8C%89%E4%BA%BA%E5%8F%A3%E6%8E%92%E5%88%97%E7%9A%84%E4%B8%96%E7%95%8C%E5%9F%8E%E5%B8%82%E5%88%97%E8%A1%A8 and https://zh.wikipedia.org/zh-tw/%E4%B8%96%E7%95%8C%E5%9F%8E%E5%B8%82%E5%B8%82%E5%9F%9F%E4%BA%BA%E5%8F%A3%E6%8E%92%E5%BA%8F%E5%88%97%E8%A1%A8"

setupArgs() {
  opt -r in1 '' "Original wikipedia html file"
  opt -r in2 '' "Original wikipedia html file"
  opt -r out '' "Output table"
  optType out output table
}

main() {
  if [[ ! -f "$in1" ]]; then
    info "Downloading the data from zh.wikipedia.org ..."
    curl -L -o "$in1" 'https://zh.wikipedia.org/zh-tw/%E4%B8%96%E7%95%8C%E5%9F%8E%E5%B8%82%E5%B8%82%E5%9F%9F%E4%BA%BA%E5%8F%A3%E6%8E%92%E5%BA%8F%E5%88%97%E8%A1%A8'
  fi

  if [[ ! -f "$in2" ]]; then
    info "Downloading the data from zh.wikipedia.org ..."
    curl -L -o "$in2" 'https://zh.wikipedia.org/zh-tw/%E6%8C%89%E4%BA%BA%E5%8F%A3%E6%8E%92%E5%88%97%E7%9A%84%E4%B8%96%E7%95%8C%E5%9F%8E%E5%B8%82%E5%88%97%E8%A1%A8'
  fi

  cat "$in1" "$in2" \
  | us/parse-world-country-list.py \
  | out::save
  return $?
}

source Mordio/mordio
