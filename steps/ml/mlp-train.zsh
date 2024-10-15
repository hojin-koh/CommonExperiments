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
description="Train a random forest classification model (MIMO possible)"
dependencies=( "uc/ml/sklearn-train.py" )

setupArgs() {
  opt -r out '()' "Output RF model"
  optType out output model

  opt -r in '()' "Input feature"
  optType in input vector
  opt -r inLabel '()' "Input label"
  optType inLabel input table

  opt param '("{}")' "Hyperparameters to be passed to RF classifier"
}

main() {
  if ! out::ALL::isReal; then
    err "Unreal model output not supported" 15
  fi

  computeMIMOStride out in inLabel param

  local dirTemp
  putTemp dirTemp

  local i
  for (( i=1; i<=$#out; i++ )); do
    computeMIMOIndex $i out in inLabel param

    if [[ ${out[$i]} != *.skops.zst ]]; then
      err "Output model can only end in .skops.zst format" 16
    fi

    # NOTE: We currently assume all data can fit in memory!
    in::load $INDEX_in \
    | uc/ml/sklearn-train.py mlp ${param[$INDEX_param]} $dirTemp/model.skops.zst <(inLabel::load $INDEX_inLabel)
    if [[ $? != 0 ]]; then return 1; fi

    out::saveCopy $i $dirTemp/model.skops.zst
  done
}

source Mordio/mordio
