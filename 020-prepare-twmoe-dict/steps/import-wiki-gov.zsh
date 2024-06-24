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
description="Import world country list, world capital list, and important city list"
dependencies=( "uc/prep/import-wikipedia-table.py" "uc/prep/import-wikipedia-li.py" "us/filter-wiki-gov.pl" )

setupArgs() {
  opt -r out '' "Output table"
  optType out output table
  opt -r outraw '' "Output table unfiltered"
  optType outraw output table
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
    uc/prep/import-wikipedia-li.py "$@" < "$in/$fname.html" \
    | perl -CSAD -nle "print \$_ . \"\\t$id\""
  else
    uc/prep/import-wikipedia-table.py "$@" < "$in/$fname.html" \
    | perl -CSAD -nle "print \$_ . \"\\t$id\""
  fi
}

main() {
  mkdir -p "$in"

  if ! outraw::isReal || ! out::isReal; then
    err "Unreal table output not supported" 15
  fi

  local dirTemp
  putTemp dirTemp

  (
    processOne "世界政區索引" country wiki-country table -1 "國家或地區" 0 1
    processOne "全球首都人口排名" capital wiki-capital table -1 "排名.*首都" 2
    processOne "各國第一大和第二大城市列表" bigcity wiki-bigcity table -1 "國家或地區" 1 2
    processOne "前首都列表" oldcity wiki-oldcity table -1 "古都" 0
    processOne "按人口排列的世界城市列表" citybypop wiki-citybypop table -1 "排名.*人口" 1
    processOne "世界城市市域人口排序列表" citybypop2 wiki-citybypop table -1 "排名.*人口" 1

    processOne "财富世界500强" comp500 wiki-fortune500 table -1 "排名.*上年" 2
    printf '%s\twiki-fortune500\n' 波克夏 方舟 派拉蒙 迪斯奈 迪士尼 皮克斯 環球 瑞士銀行 京阿尼 東電 美超微 超微
  ) > $dirTemp/table.full

  outraw::save < $dirTemp/table.full

  us/filter-wiki-gov.pl < $dirTemp/table.full \
  | sort -u \
  | out::save
  return $?
}

source Mordio/mordio
