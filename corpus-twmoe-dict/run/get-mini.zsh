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
description="Get the minimal dict"

DIR_DOWNLOAD="craw/download-dict-mini"
DIR="ds/mini-unnorm"
ADICT=()

main() {
  mkdir -p "$DIR_DOWNLOAD"

  # Taiwanese Minister of Education: Concised dictionary
  ADICT+=( $DIR/dict-twmoe-concised.zst )
  ss/import-twmoe-concised.zsh out="${ADICT[-1]}" in="$DIR_DOWNLOAD/twmoe-dict-concised.zip"

  # Taiwanese Minister of Education: Zhuyin from concised dictionary
  ADICT+=( $DIR/dict-twmoe-zhuyin.zst )
  ss/import-twmoe-zhuyin.zsh out="${ADICT[-1]}" in="$DIR_DOWNLOAD/twmoe-dict-concised.zip"

  # Taiwanese Minister of Education: Idioms dictionary
  ADICT+=( $DIR/dict-twmoe-idioms.zst )
  ss/import-twmoe-idioms.zsh out="${ADICT[-1]}" in="$DIR_DOWNLOAD/twmoe-dict-idioms.zip"

  # Taiwane moedict things
  ADICT+=( $DIR/dict-moedict.zst )
  ss/import-moedict.zsh out="${ADICT[-1]}" in="$DIR_DOWNLOAD/moedict"

  # Our custom number words
  ADICT+=( $DIR/dict-custom-number.zst )
  ss/generate-custom-numbers.zsh out="${ADICT[-1]}"

  # Taiwanese frequent words from OpenVanilla Bopomofo input method
  ADICT+=( $DIR/dict-openvanilla-bpmf.zst )
  ss/import-openvanilla-bpmf.zsh out="${ADICT[-1]}" in="$DIR_DOWNLOAD/openvanilla-bpmf.txt"

  # Chinese frequent words from some github
  ADICT+=( $DIR/dict-china-freqword.zst )
  ss/import-china-freqword.zsh out="${ADICT[-1]}" in="$DIR_DOWNLOAD/china-freqword.xls"


  sc/table-merge.zsh --set out="$DIR/merged-unnorm.zsh" \
    "in=${^ADICT[@]}"

}

source Mordio/mordio
