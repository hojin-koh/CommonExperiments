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
description="Compute average error rate and 95% confidence interval"

setupArgs() {
  opt -r out '' "Output summary table"
  optType out output table

  opt -r in '' "Input error table"
  optType in input table
  opt -r tag '' "Name of this experiment"
}

main() {
  if ! out::isReal; then
    err "Unreal table output not supported" 15
  fi

  info "Experiment name: $tag"
  (
  printf '%s\t' "$tag"
  in::load | bc/bserr
  ) | out::save
  return $?
}

source Mordio/mordio
