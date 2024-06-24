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

OUT=ds

main() {
  local DIR_DOWNLOAD=craw/download-dict-mini
  local DIR=ds/mini-unnorm
  local ADICTRAW=()
  local ADICT=()
  mkdir -p $DIR_DOWNLOAD

  # Taiwanese Minister of Education: Concised dictionary
  ADICTRAW+=( $DIR/dict-twmoe-concised-raw.zst )
  ADICT+=( $DIR/dict-twmoe-concised.zst )
  ss/import-twmoe-concised.zsh out=${ADICT[-1]} outraw=${ADICTRAW[-1]} \
    in=$DIR_DOWNLOAD/twmoe-dict-concised.zip

  # Taiwanese Minister of Education: Zhuyin from concised dictionary
  ADICTRAW+=( $DIR/dict-twmoe-zhuyin-raw.zst )
  ADICT+=( $DIR/dict-twmoe-zhuyin.zst )
  ss/import-twmoe-zhuyin.zsh out=${ADICT[-1]} outraw=${ADICTRAW[-1]} \
    in=$DIR_DOWNLOAD/twmoe-dict-concised.zip

  # Taiwanese Minister of Education: Idioms dictionary
  ADICTRAW+=( $DIR/dict-twmoe-idioms-raw.zst )
  ADICT+=( $DIR/dict-twmoe-idioms.zst )
  ss/import-twmoe-idioms.zsh out=${ADICT[-1]} outraw=${ADICTRAW[-1]} \
    in=$DIR_DOWNLOAD/twmoe-dict-idioms.zip

  # Taiwanese moedict things
  ADICTRAW+=( $DIR/dict-moedict-raw.zst )
  ADICT+=( $DIR/dict-moedict.zst )
  ss/import-moedict.zsh out=${ADICT[-1]} outraw=${ADICTRAW[-1]} \
    in=$DIR_DOWNLOAD/moedict

  # Our custom number words
  ADICTRAW+=( $DIR/dict-custom-number.zst )
  ADICT+=( $DIR/dict-custom-number.zst )
  ss/generate-custom-numbers.zsh out=${ADICT[-1]}

  # Chinese frequent words from some github
  ADICTRAW+=( $DIR/dict-china-freqword-raw.zst )
  ADICT+=( $DIR/dict-china-freqword.zst )
  ss/import-china-freqword.zsh out=${ADICT[-1]} outraw=${ADICTRAW[-1]} \
    in=$DIR_DOWNLOAD/china-freqword.xls

  # Taiwanese frequent words from OpenVanilla Bopomofo input method
  ADICTRAW+=( $DIR/dict-openvanilla-bpmf-raw.zst )
  ADICT+=( $DIR/dict-openvanilla-bpmf.zst )
  ss/import-openvanilla-bpmf.zsh out=${ADICT[-1]} outraw=${ADICTRAW[-1]} \
    in=$DIR_DOWNLOAD/openvanilla-bpmf.txt

  sc/table-merge.zsh --set out=$DIR/merged-unnorm-raw.zsh \
    in="${^ADICTRAW[@]}"

  sc/table-merge.zsh --set out=$DIR/merged-unnorm.zsh \
    in="${^ADICT[@]}"
}

source Mordio/mordio
