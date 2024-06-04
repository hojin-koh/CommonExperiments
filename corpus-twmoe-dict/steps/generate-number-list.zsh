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
description="Generate some Chinese basic number words for the dictionary"

setupArgs() {
  opt -r out '' "Output table"
  optType out output table
}

main() {
  (
  for i in 一 二 三 四 五 六 七 八 九; do
    echo "十$i"
    for j in 一 二 三 四 五 六 七 八 九; do
      echo "${i}十$j"
    done
  done

  # https://resources.hkedcity.net/downloadResource.php?rid=1314569312&pid=991692700
  for i in 一 兩 三 四 五 六 七 八 九; do
    for t in 百 千 萬 億 兆 種 組 步 人 個 片 把 本 家 件 條 句 項 座 行 筆 篇 部 場 副 層 次 滴 疊 份 台 頭 隻 支 棵 顆 塊 株 段 串 週 星期 年; do
      echo "$i$t"
    done
  done

  for i in 一 兩; do
    for t in 端 面 邊 側 杯 群 聲 首 位 環 方; do
      echo "$i$t"
    done
  done

  for i in 一 二 三 四 五 六 日; do
    echo "週$i"
    echo "周$i"
    echo "星期$i"
    echo "禮拜$i"
  done

  # Years
  for y in 一六 一七 一八 一九 二零; do
    for i in 一 二 三 四 五 六 七 八 九; do
      for j in 一 二 三 四 五 六 七 八 九; do
        echo "$y$i$j"
      done
    done
  done

  # Misc
  echo "一一九"
  echo "一一零"
  echo "十大建設"
  echo "之一"
  echo "一家人"
  echo "十項"
  ) | out::save
  return $?
}

source Mordio/mordio
