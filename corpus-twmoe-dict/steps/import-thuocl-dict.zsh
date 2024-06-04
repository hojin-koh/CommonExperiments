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
description="Import THUOCL dictionaries from China: https://github.com/thunlp/THUOCL"

setupArgs() {
  opt -r in '' "Original input directory"
  opt -r out '' "Output table"
  optType out output table
}

main() {
  mkdir -p "$in"
  for t in food law medical lishimingren caijing; do
    if [[ ! -f "$in/$t.txt" ]]; then
      curl -L -o "$in/$t.txt" "https://raw.githubusercontent.com/thunlp/THUOCL/master/data/THUOCL_$t.txt"
    fi
  done

  (
    ( us/parse-thuocl-dict.py 10000 4 <"$in/food.txt")
    ( us/parse-thuocl-dict.py 100000 3 <"$in/law.txt")
    ( us/parse-thuocl-dict.py 2000 3 <"$in/medical.txt")
    ( us/parse-thuocl-dict.py 750 4 <"$in/lishimingren.txt")
    ( us/parse-thuocl-dict.py 11900 5 <"$in/caijing.txt")
  ) | out::save
  return $?
}

source Mordio/mordio
