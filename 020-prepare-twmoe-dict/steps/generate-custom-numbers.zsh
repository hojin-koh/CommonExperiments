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
  if ! out::isReal; then
    err "Unreal table output not supported" 15
  fi

  (
  # Directions
  for d in 前 後 上 下 左 右; do
    echo "${d}方"
    echo "${d}邊"
    echo "${d}面"
    echo "${d}向"
    echo "${d}側"
    echo "${d}傾"
    echo "${d}偏"
    echo "${d}門"
    echo "${d}手"
  done
  for d in 左 右 東 西 南 北 東北 西北 東南 西南 北北東 北北西 東北東 西北西 南南東 南南西 西南西 西北西; do
    echo "${d}方"
    echo "${d}邊"
    echo "${d}面"
    echo "${d}向"
    echo "${d}向坡"
    echo "${d}側"
    echo "${d}風"
    echo "${d}傾"
    echo "${d}偏"
    echo "${d}轉"
    echo "${d}門"
    echo "${d}口"
    echo "${d}出口"
    echo "${d}路"
  done

  # Colors
  for c in 黑 墨 棕 褐 咖啡 紅 洋紅 朱紅 緋紅 朱 茜 粉 粉紅 桃 桃紅 橙 橘 橘紅 橘黃 赭 黃 綠 草綠 墨綠 翠綠 碧綠 藍 粉藍 藍綠 蔚藍 天藍 海藍 蒼藍 藍紫 青 靛 紫 桃紫 灰 白 米 金 銀 銀白 堇紫 堇; do
    if [[ $#c -gt 1 ]]; then
      echo "$c"
    fi
    echo "${c}色"
    echo "${c}光"
    echo "${c}布"
    for deg in 深 淺 淡; do
      echo "${deg}${c}色"
      echo "${deg}${c}光"
      echo "${deg}${c}布"
    done
  done


  for i in 一 二 三 四 五 六 七 八 九; do
    echo "十$i"
  done

  for i in 二 三 四 五 六 七 八 九; do
    echo "${i}十"
    for j in 一 二 三 四 五 六 七 八 九; do
      echo "${i}十$j"
    done
  done

  # https://resources.hkedcity.net/downloadResource.php?rid=1314569312&pid=991692700
  for i in 一 兩 三 四 五 六 七 八 九 十; do
    for t in 百 千 萬 億 兆 種 組 步 人 個 片 把 本 家 件 條 句 項 座 行 筆 篇 部 場 副 層 次 滴 份 台 頭 隻 支 棵 顆 塊 株 段 串; do
      echo "$i$t"
    done
  done

  for i in 一 兩; do
    for t in 端 面 邊 側 杯 群 聲 首 位 環 方 疊; do
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

  # Significant events
  echo "九二一"
  echo "九一一"
  echo "九么么"
  echo "三一一"
  echo "六四"

  # Misc
  echo "一一九"
  echo "么么九"
  echo "一一零"
  echo "十大建設"
  echo "之一"
  echo "一家人"
  echo "十項"
  ) | sort -u \
  | gawk '{print $1 "\tcustom-numbers"}' \
  | out::save
  return $?
}

source Mordio/mordio
