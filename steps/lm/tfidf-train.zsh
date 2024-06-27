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
description="Train a gensim TF-IDF model"
dependencies=( "uc/lm/tfidf-train.py" )
importantconfig=(smart)

setupArgs() {
  opt -r out '' "Output model"
  optType out output model
  opt -r outTable '' "Output table"
  optType outTable output table

  opt -r in '' "Input text"
  optType in input text
  opt -r vocab '' "Input vocabulary model"
  optType vocab input model

  opt smart "ltn" "SMART IR designation when calculating TF-IDF"
}

main() {
  local dirTemp
  putTemp dirTemp

  in::loadValue \
  | uc/lm/tfidf-train.py "$smart" "$vocab" "$dirTemp/model" \
  | outTable::save
  local rtn=$?

  bzip2 -9 $dirTemp/model
  out::saveCopy $dirTemp/model.bz2
  return $rtn
}

source Mordio/mordio
