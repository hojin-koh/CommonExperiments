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
description="Predict output from a BERT-based model (MIMO possible)"
dependencies=( "uc/lm/bertclass-predict.py" )

setupArgs() {
  opt -r out '()' "Output probability table"
  optType out output table

  opt -r in '()' "Input text"
  optType in input text
  opt -r model '()' "Input model"
  optType model input modeldir
}

main() {
  if ! out::ALL::isReal; then
    err "Unreal table output not supported" 15
  fi

  computeMIMOStride out in model

  local nr
  local i
  for (( i=1; i<=$#out; i++ )); do
    computeMIMOIndex $i out in model

    getMeta in $INDEX_in nRecord nr

    in::load $INDEX_in \
    | uc/lm/bertclass-predict.py "${model[$INDEX_model]}" \
    | lineProgressBar $nr \
    | out::save $i
    if [[ $? != 0 ]]; then return 1; fi
  done
}

source Mordio/mordio
