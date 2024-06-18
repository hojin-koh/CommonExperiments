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
description="Train a random forest classification model"
dependencies=( "uc/ml/sklearn-train.py" )

setupArgs() {
  opt -r out '' "Output RF model"
  optType out output model

  opt -r in '' "Input feature"
  optType in input vector
  opt -r inLabel '' "Input label"
  optType inLabel input table

  #opt inDev '' "Input development set feature"
  #optType inDev input vector
  #opt inDevLabel '' "Input development set label"
  #optType inDevLabel input table
}

main() {
  if ! out::isReal; then
    err "Unreal table output not supported" 15
  fi

  if [[ $out != *.zst ]]; then
    err "Output model can only end in .zst format" 16
  fi

  local dirTemp
  putTemp dirTemp

  # NOTE: We currently assume all data can fit in memory!
  in::load \
  | uc/ml/sklearn-train.py rf '{}' $dirTemp/model.onnx.zst <(inLabel::load) 

  out::saveCopy $dirTemp/model.onnx.zst
}

source Mordio/mordio
