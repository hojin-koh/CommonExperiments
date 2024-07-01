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
description="Predict output from an skops-formatted model (MIMO possible)"
dependencies=( "uc/ml/skops-vec-predict.py" )

setupArgs() {
  opt -r out '()' "Output probability table"
  optType out output table

  opt -r in '()' "Input feature"
  optType in input vector
  opt -r model '()' "Input model"
  optType model input model
}

main() {
  if ! out::ALL::isReal; then
    err "Unreal table output not supported" 15
  fi

  computeMIMOStride out in model

  local i
  for (( i=1; i<=$#out; i++ )); do
    computeMIMOIndex $i out in model

    in::load $INDEX_in \
    | uc/ml/skops-vec-predict.py "${model[$INDEX_model]}" \
    | out::save $i
    if [[ $? != 0 ]]; then return 1; fi
  done
}

source Mordio/mordio
