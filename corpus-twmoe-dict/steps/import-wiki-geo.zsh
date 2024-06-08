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
description="Import world geographic features"
dependencies=( "us/parse-wikipedia-table.py" "us/parse-wikipedia-li.py" )

setupArgs() {
  opt -r out '' "Output table"
  optType out output table
  opt -r in '' "Original wikipedia html file directory"
}

processOne() {
  local title="${1%%|*}"
  local oldid="${1##*|}"
  local fname="$2"
  local id="$3"
  local dtype="$4"
  shift; shift; shift; shift;

  if [[ "$oldid" == "$title" ]]; then
    oldid=""
  fi

  if [[ ! -f "$in/$fname.html" ]]; then
    info "Downloading the data from zh.wikipedia.org ..."
    curl --get -L -o "$in/$fname.html" "https://zh.wikipedia.org/w/index.php" \
      --data-urlencode 'variant=zh-tw' \
      --data-urlencode "title=$title" \
      --data-urlencode "oldid=$oldid"
  fi
  if grep "重定向到" "$in/$fname.html" >/dev/null; then
    err "File $in/$fname.html is a redirection page, please find the correct title" 15
  fi
  if [[ "$dtype" == "list" ]]; then
    us/parse-wikipedia-li.py "$@" < "$in/$fname.html" | gawk '{print $1 "'"\t$id"'"}'
  else
    us/parse-wikipedia-table.py "$@" < "$in/$fname.html" | gawk '{print $1 "'"\t$id"'"}'
  fi
}

main() {
  mkdir -p "$in"

  (
    processOne '世界海洋列表' ocean wiki-ocean list -1 '.*(海|灣|海峽)$'
    printf '%s\twiki-ocean\n' 北極海 北冰洋 南冰洋 太平洋 大西洋 印度洋 寧靜海 大堡礁

    processOne '海峽列表' strait wiki-strait list -1 '.*(海峽)$'

    processOne '山脉列表' ridge wiki-ridge list -1 '.*(山脈|山系|高原|嶺)$' \
    | perl -CSAD -lpe 'use utf8; print; s/(山山脈|山脈)\t/山\t/; print'
    printf '%s\twiki-ridge\n' 富士山 羅臼岳 谷川岳 岩手山 雲仙岳 奧林帕斯山

    processOne '海溝列表' trench wiki-trench table -1 '海溝.*大洋' 0
    processOne '世界長河列表' river wiki-river table -1 '排序.*名稱' 1 3 4
    printf '%s\twiki-river\n' 幼發拉底河

    processOne '湖泊面積列表' lake wiki-lake table -1 '名稱.*水量' 1
  ) | sort -u \
  | out::save
  return $?
}

source Mordio/mordio
