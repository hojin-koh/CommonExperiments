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
description="Get the variant and charfreq"

DIR_DOWNLOAD="craw/download-dict-mini"
DIR="ds"
PUB="mc/lexicon"
AFREQ=()


main() {

  # === Part 10: Get character frequency tables ===
  mkdir -p "$DIR_DOWNLOAD"

  AFREQ+=( $DIR/charfreq-twmoe.zst )
  ss/import-twmoe-charfreq.zsh out="${AFREQ[-1]}" in="$DIR_DOWNLOAD/twmoe-charfreq.zip"

  AFREQ+=( $DIR/twly-gazette.zst )
  ss/import-ly-gazette-charfreq.zsh out="${AFREQ[-1]}" in="$DIR_DOWNLOAD/ly-gazette.tsv"

  AFREQ+=( $DIR/charfreq-google.zst )
  ss/import-google-charfreq.zsh out="${AFREQ[-1]}" in="$DIR_DOWNLOAD/google-charfreq.gz"

  sc/table-interpolate.zsh --normalize out="$DIR/charfreq-unnorm.zsh" \
    w=0.1 in="${AFREQ[3]}" w=0.3 in="${AFREQ[2]}" w=0.6 in="${AFREQ[1]}"

  # === Part 20: Get the variant table and normalized frequency table ===

  INPUTVAR="$DIR_DOWNLOAD/twmoe-variants.txt"
  if [[ -f "craw/twmoe-variants-20191207.tar.zst" ]]; then
    INPUTVAR="craw/twmoe-variants-20191207.tar.zst"
  fi
  ss/import-twmoe-variants.zsh out="$PUB/tw-variants-v1.zst" infreq="$DIR/charfreq-unnorm.zsh" \
    in="$INPUTVAR" confusable="$DIR_DOWNLOAD/icu-confusable-20240412.txt"

  sc/normalize-unicode-key.zsh out="$PUB/tw-charfreq-v1.zst" --mode=interpolate \
    in="$DIR/charfreq-unnorm.zsh" conv="$PUB/tw-variants-v1.zst"

}

source Mordio/mordio
