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
description="Main run script of the experiment corpus-twmoe-dict"

DIR="ds"
PUB="dl"
ADICT=()

main() {
  # Variants and character frequency
  srun/get-vars.zsh

  # Minimal general-purpose dictionary
  ADICT+=( "$DIR/mini-unnorm/merged-unnorm.zsh" )
  srun/get-mini.zsh

  # Minimal proper-noun dictionary
  ADICT+=( "$DIR/mini-unnorm/ppn-unnorm.zsh" )
  srun/get-ppnmini.zsh

  # Merge the two mini parts of the dictionary
  sc/table-merge.zsh --set out="$DIR/tw-mini-unnorm.zsh" \
    "in=${^ADICT[@]}"

  sc/normalize-unicode-key.zsh out="$PUB/tw-dict-v1-mini.zst" --mode=merge \
    in="$DIR/tw-mini-unnorm.zsh" conv="$PUB/tw-variants.zst"

}

source Mordio/mordio
