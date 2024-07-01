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
description="Train a gensim TF-IDF model (MIMO possible)"
dependencies=( "uc/lm/tfidf-train.py" )
importantconfig=(smart)

setupArgs() {
  opt -r out '()' "Output model"
  optType out output model
  opt -r outTable '()' "Output table"
  optType outTable output table

  opt -r in '()' "Input text"
  optType in input text
  opt -r vocab '()' "Input vocabulary model"
  optType vocab input model

  opt smart "(ltn)" "SMART IR designation when calculating TF-IDF"
}

main() {
  if [[ $#outTable != $#out ]]; then
    err "Output model and Output table must have the same number of parameters" 15
  fi

  if ! outTable::ALL::isReal; then
    err "Unreal table output not supported" 15
  fi

  computeMIMOStride out in vocab smart

  local dirTemp
  putTemp dirTemp

  local i
  for (( i=1; i<=$#in; i++ )); do
    computeMIMOIndex $i out in vocab smart

    in::loadValue $INDEX_in \
    | uc/lm/tfidf-train.py "${smart[$INDEX_smart]}" "${vocab[$INDEX_vocab]}" "$dirTemp/model$i" \
    | outTable::save $i
    if [[ $? != 0 ]]; then return 1; fi

    bzip2 -9 $dirTemp/model$i
    out::saveCopy $i $dirTemp/model$i.bz2
  done
}

source Mordio/mordio
