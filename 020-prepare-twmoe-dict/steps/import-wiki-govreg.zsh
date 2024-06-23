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
description="Import some regional city list"
dependencies=( "us/parse-wikipedia-table.py" )

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
    processOne '日本行政區劃' jpall wiki-jp-area table -1 "ISO.*日本" 1 | sed -r 's/[都府]\t/\t/'
    processOne '東京都區部' jptokyo wiki-jp-tokyo table -1 "編號.*人口" 1
    processOne '日本城市人口排名' jpcity wiki-jp-city table 400 "順位.*人口" 2 \
    | sed -r 's/區部\t/\t/' | perl -CSAD -lne 'print unless /\p{Hiragana}|\p{Katakana}/'

    processOne '俄羅斯城市和城鎮人口列表' rucity wiki-ru-city table 50 "排名.*俄語" 0 # First one is a <th>, so city name is in 0
    processOne '韓國城市人口排序列表' krcity wiki-kr-city table 70 "排名.*城市" 3
    processOne '東南亞國協城市人口列表' seacity wiki-sea-city table -1 "順位.*人口" 1

    processOne '歐洲城市人口列表' eucity wiki-eu-city table -1 "城市名稱.*人口" 1
    processOne '大洋洲城市人口列表' ocecity wiki-oce-city table 24 "排名.*人口" 1 \
    | sed -r 's/惠靈頓/威靈頓/'
    processOne '按人口排列的加拿大城市列表' cacity wiki-ca-area table 30 "排名.*人口" 2 \
    | sed -r 's/省\t/\t/'
    processOne '按人口排列的加拿大城市列表' cacity wiki-ca-city table 30 "排名.*人口" 1
    processOne '美国各州最大城市列表' usstate wiki-us-state table -1 "州別.*城市" 0
    printf '%s\twiki-us-state\n' 加州 佛州 賓州 麻州 麻省 德州 明州 康州 威州 南卡 北卡 南達 北達 密蘇裡州
    processOne '美國城市人口排序列表' uscity wiki-us-city table 200 "排名.*人口" 1
    processOne '南美洲城市人口列表' sacity wiki-sa-city table -1 "城市.*人口" 1
  ) | sort -u \
  | out::save
  return $?
}

source Mordio/mordio
