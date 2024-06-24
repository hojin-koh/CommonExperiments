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
  local DIR=ds/ppn-unnorm
  local ADICTRAW=()
  local ADICT=()
  mkdir -p $DIR_DOWNLOAD

  # THUOCL word lists
  ADICTRAW+=( $DIR/dict-thuocl-raw.zst )
  ADICT+=( $DIR/dict-thuocl.zst )
  ss/import-thuocl-dict.zsh out=${ADICT[-1]} outraw=${ADICTRAW[-1]} \
    in=$DIR_DOWNLOAD/thuocl

  # Moedict proper nouns
  ADICTRAW+=( $DIR/ppn-moedict-raw.zst )
  ADICT+=( $DIR/ppn-moedict.zst )
  ss/import-moedict-ppn.zsh out=${ADICT[-1]} outraw=${ADICTRAW[-1]} \
    in=$DIR_DOWNLOAD/moedict

  # TW area list
  ADICTRAW+=( $DIR/tw-area-list.zst )
  ADICT+=( $DIR/tw-area-list.zst )
  ss/import-tw-area-list.zsh out=${ADICT[-1]} \
    in=$DIR_DOWNLOAD/tw-area-list.py

  # CN city list
  ADICTRAW+=( $DIR/china-city-list.zst )
  ADICT+=( $DIR/china-city-list.zst )
  ss/import-china-city-list.zsh out=${ADICT[-1]} \
    in=$DIR_DOWNLOAD/china-city-list.json

  # Wikipedia world geography list
  ADICTRAW+=( $DIR/wiki-geo-raw.zst )
  ADICT+=( $DIR/wiki-geo.zst )
  ss/import-wiki-geo.zsh out=${ADICT[-1]} outraw=${ADICTRAW[-1]} \
    in=$DIR_DOWNLOAD/wiki-geo

  # Wikipedia world country/city list
  ADICTRAW+=( $DIR/wiki-gov-raw.zst )
  ADICT+=( $DIR/wiki-gov.zst )
  ss/import-wiki-gov.zsh out=${ADICT[-1]} outraw=${ADICTRAW[-1]} \
    in=$DIR_DOWNLOAD/wiki-gov

  # Wikipedia regional city list
  ADICTRAW+=( $DIR/wiki-gov-reg-raw.zst )
  ADICT+=( $DIR/wiki-gov-reg.zst )
  ss/import-wiki-govreg.zsh out=${ADICT[-1]} outraw=${ADICTRAW[-1]} \
    in=$DIR_DOWNLOAD/wiki-gov

  # Wikipedia world people list
  ADICTRAW+=( $DIR/wiki-ppl-raw.zst )
  ADICT+=( $DIR/wiki-ppl.zst )
  ss/import-wiki-ppl.zsh out=${ADICT[-1]} outraw=${ADICTRAW[-1]} \
    in=$DIR_DOWNLOAD/wiki-ppl

  # TODO: Taiwan-specific lists
  # TODO: Japan-specific lists
  # TODO: US-specific lists

  sc/table-merge.zsh --set out=$DIR/merged-unnorm-raw.zsh \
    in="${^ADICTRAW[@]}"

  sc/table-merge.zsh --set out=$DIR/merged-unnorm.zsh \
    in="${^ADICT[@]}"

}

source Mordio/mordio
