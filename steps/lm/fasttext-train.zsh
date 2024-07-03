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
description="Train a glove embedding"
dependencies=( "uc/lm/fasttext-train.py" )
importantconfig=(mincount window dim vocab)

setupArgs() {
  opt -r out '' "Output LM"
  optType out output modeldir

  opt -r in '' "Input text"
  optType in input text

  opt mincount 5 "min count to be included"
  opt window 6 "window size"
  opt vocab 50000 "vocabulary size"
  opt dim 250 "vector dimension"
}

main() {
  local dirTemp
  putTemp dirTemp

  local outThis
  out::putDir outThis

  in::loadValue > "$dirTemp/text"
  uc/lm/fasttext-train.py "$dim" "$vocab" "$mincount" "$window" "$dirTemp/text" "$outThis/model"
}

source Mordio/mordio
