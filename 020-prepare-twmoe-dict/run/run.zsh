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

setupArgs() {
  opt stage '0' "Experiment stage"
}

main() {
  local DIR=ds
  local PUB=mc/lexicon
  local ADICTRAW=()
  local ADICT=()

  # Minimal general-purpose dictionary
  if [[ $stage -le 100 ]]; then
    ADICTRAW+=( $DIR/mini-unnorm/merged-unnorm-raw.zsh )
    ADICT+=( $DIR/mini-unnorm/merged-unnorm.zsh )
    srun/get-mini.zsh
  fi

  # Minimal proper-noun dictionary
  if [[ $stage -le 120 ]]; then
    ADICTRAW+=( $DIR/ppn-unnorm/merged-unnorm-raw.zsh )
    ADICT+=( $DIR/ppn-unnorm/merged-unnorm.zsh )
    srun/get-ppnmini.zsh
  fi

  # Merge the two mini parts of the dictionary
  sc/table-merge.zsh --set out=$DIR/tw-mini-unnorm.zsh \
    in="${^ADICT[@]}"

  sc/table-merge.zsh --set out=$DIR/tw-mini-unnorm-raw.zsh \
    in="${^ADICTRAW[@]}"

  sc/normalize-unicode-key.zsh out=$PUB/tw-dict-mini-v1.zst --mode=merge \
    in=$DIR/tw-mini-unnorm.zsh conv=$PUB/tw-variants-v1.zst

  sc/normalize-unicode-key.zsh out=$PUB/tw-dict-mini-v1-raw.zst --mode=merge \
    in=$DIR/tw-mini-unnorm-raw.zsh conv=$PUB/tw-variants-v1.zst
}

source Mordio/mordio
