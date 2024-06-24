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
description="Import some world-wide import people list"
dependencies=( "uc/prep/import-wikipedia-table.py" "uc/prep/import-wikipedia-li.py" "us/filter-wiki-ppl.pl" )

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
    processOne '全球富豪榜' forbesrich wiki-forbes-rich table -1 "名次.*年齡" 1 | sed -r 's/(及其)?家族\t/\t/'
    processOne '福布斯杂志全球最具影响力人物列表' forbespower wiki-forbes-power table -1 "排名.*人物" 1

    processOne '时代百大人物' times100 wiki-times-100 table -1 "人物.*年份" 0 \
    | perl -CSAD -lpe 'use utf8; s/^第.*世//'
    processOne '時代年度風雲人物' timesyearly wiki-times-yearly table -1 "年份.*獲選者" 2 \
    | grep -vE '(真相|地球|你|電腦|伊波拉|中產|自由|和平)'

    processOne '影响人类历史进程的100名人排行榜' hist100 wiki-history-100 table -1 "排名.*名稱" 2

    processOne '获奖最多音乐艺人列表' singeraward wiki-singer-award table -1 "姓名.*獎項" 0
    processOne '票房最高现场音乐艺人列表' singersell wiki-singer-sell table -1 "排名.*藝人名" 0 \
    | perl -CSAD -lpe 'use utf8; print; s/(樂團|合唱團)\t/\t/; print'
    processOne '最高電影票房演員列表' moviesell wiki-movie-sell table -1 "排名.*票房" 1

    printf '%s\twiki-people-custom\n' 黃仁勳 梁見後 劉德音 海英俊 蘇姿丰 黃土水 劉玄德 孔明 隴中 五府王爺 保生大帝 金日成 金正日 金永南

    declare -A yearWiki
    yearWiki[2024]=82947213
    yearWiki[2021]=66321771
    yearWiki[2018]=50194252
    for t in "${(k)yearWiki[@]}"; do
      ts="${yearWiki[$t]}"
      processOne "各国领导人列表|$ts" leader$t wiki-leader-$t table -1 "法定全稱.*名" 1 2 4 5 \
      | grep -vE '(委員會|書記|總統|兼|代表|主席|先生)' \
      | perl -CSAD -lpe 'use utf8; s/马/馬/g'
    done
    processOne "各国领导人列表|36063804" leader2015 wiki-leader-2015 table -1 "法定全稱.*名" 1 2 3 4 \
    | grep -vE '(委員會|書記|總統|兼|代表|主席|先生)'
    processOne "各国领导人列表|24253784" leader2012 wiki-leader-2012 table -1 "法定全稱.*名" 1 2 3 4 \
    | grep -vE '(委員會|書記|總統|兼|代表|主席|先生)'
    processOne "各国领导人列表|5862757" leader2007 wiki-leader-2007 table -1 "法定全稱.*名" 2 3 4 5 \
    | grep -vE '(委員會|書記|總統|兼|代表|主席|先生)'
  ) > $dirTemp/table.full

  outraw::save < $dirTemp/table.full

  us/filter-wiki-ppl.pl < $dirTemp/table.full \
  | sort -u \
  | out::save
  return $?
}

source Mordio/mordio
