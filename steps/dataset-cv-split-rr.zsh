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
description="Get the nth dataset split spec for cross-validation"

setupArgs() {
  opt -r in '' "Input label table"
  optType in input table
  opt -r out '' "Output key table"
  optType out output table

  opt -r idSplit '' "The serial number (starting from 0) of this split"
  opt -r nTrain '' "How many parts of data are used as training set"
  opt -r nDev '' "How many parts of data are used as dev set, can be zero"
  opt -r nTest '' "How many parts of data are used as test set"
}

main() {
  in::load \
  | uc/dataset-cv-split-rr.py "$nTrain" "$nDev" "$nTest" "$idSplit" \
  | out::save
  return $?
}

source Mordio/mordio
