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
description="Get all the dataset split spec for cross-validation (SIMO)"
dependencies=( "uc/dataset-cv-split.py" )
importantconfig=(nTrain nTest specSubTrain)

setupArgs() {
  opt -r in '' "Input label table"
  optType in input table
  opt -r out '()' "Output key table"
  optType out output table

  opt -r nTrain '' "How many parts of data are used as training set"
  opt -r nTest '' "How many parts of data are used as test set"
  opt specSubTrain '' "Subsets of training set spec in format name=frac:name=frac, like train=7:dev1=2:dev2=1"
  opt isRandom false "Whether to do pure random split, if false, do block split"
}

putCombination() {
  local nTotal=$1
  local nTest=$2

  # Calculate combinations using the formula: nTotal choose nTest
  local numerator=1
  local denominator=1
  local i
  for ((i=0; i<nTest; i++)); do
    numerator=$[numerator * (nTotal - i)]
    denominator=$[denominator * (i + 1)]
  done

  nComb=$[numerator / denominator]
}

main() {
  if ! out::ALL::isReal; then
    err "Unreal table output not supported" 15
  fi

  local nComb
  putCombination $[nTrain+nTest] $nTest
  if [[ $#out != $nComb ]]; then
    err "In this configuration, there must be exactly $nComb output tables" 15
  fi

  for (( i=1; i<=$nComb; i++ )); do
    in::load \
    | uc/dataset-cv-split.py "$isRandom" "$nTrain" "$nTest" $[i-1] "$specSubTrain" \
    | out::save $i
    if [[ $? != 0 ]]; then return 1; fi
  done
}

source Mordio/mordio
