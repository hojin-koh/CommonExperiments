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
description="Make a gensim-compatible vocab list through gensim"

setupArgs() {
  opt -r out '' "Output vocabulary"
  optType out output model

  opt -r in '' "Input text"
  optType in input text
  opt mincount 5 "min count to be included"
  opt vocab 25000 "vocab size"
}

main() {
  local dirTemp
  putTemp dirTemp

  in::loadValue \
  | bc/glove/vocab_count -verbose 1 \
      -min-count $mincount -max-vocab $vocab > "$dirTemp/vocab"

  (
    gawk '{n+=$2} END {print n+1}' < "$dirTemp/vocab"
    printf '1\t%s\t1\n' "<unk>"
    gawk '{print (NR+1) "\t" $1 "\t" $2}' < "$dirTemp/vocab"
  ) | out::save
}

source Mordio/mordio
