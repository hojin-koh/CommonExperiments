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
description="Merge counts or scores from multiple tables"
dependencies=( "uc/interpolate-count.py" )

setupArgs() {
  opt -r out '' "Output table"
  optType out output table

  opt -r in '()' "Input tables"
  optType in input table
  opt w '()' "Input weights"

  opt normalize '' "Whether to normalize total number to the sum of the 1st input"
}

main() {
  local i
  local param="uc/interpolate-count.py"
  if [[ "$normalize" == "true" ]]; then
    param+=" --normalize"
  fi
  for (( i=1; i<=${#in[@]}; i++ )); do
    param+=" ${w[$i]-1.0} <($(in::getLoader $i))"
  done

  if out::isReal; then
    eval "$param" | out::save
    return $?
  fi

  echo "$param" | out::save
  return $?
}

source Mordio/mordio
